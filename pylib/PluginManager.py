"""Plugin manager replacement for yapsy.

This module provides a simple plugin manager that mimics the basic
functionality of yapsy.PluginManager and yapsy.IPlugin for use in the MTT
project.
"""

import inspect
import os
import pkgutil
import sys
from typing import List, Optional


class IPlugin:
    """Base class for all plugins.
    
    Plugins should inherit from this class to be discovered by the PluginManager.
    """
    pass


class PluginInfo:
    """Information about a loaded plugin.
    
    This mimics the yapsy.PluginInfo object to maintain compatibility.
    """
    
    def __init__(self, name: str, plugin_object: IPlugin, plugin_type: str = "Default"):
        self.name = name
        self.object = plugin_object
        self.type = plugin_type
        
    def __str__(self):
        return f"PluginInfo(name={self.name}, type={self.type})"
        
    __repr__ = __str__


class PluginManager:
    """Simple plugin manager for discovering and loading plugins.
    
    This class provides a subset of the yapsy.PluginManager API:
    - setPluginPlaces()
    - collectPlugins()
    - getPlugins() / getAllPlugins()
    - getPluginsByCategory() (simplified)
    """
    
    def __init__(self, categories_filter: Optional[dict] = None, 
                 plugin_info_extractor: Optional[object] = None):
        """Initialize the plugin manager.
        
        Args:
            categories_filter: Ignored, kept for API compatibility.
            plugin_info_extractor: Ignored, kept for API compatibility.
        """
        self.plugins: List[PluginInfo] = []
        self.plugin_places: List[str] = []
        self.categories_filter = categories_filter or {}
        self.plugin_info_extractor = plugin_info_extractor
        
    def setPluginPlaces(self, plugin_places: List[str]) -> None:
        """Set the directories where plugins are located.
        
        Args:
            plugin_places: List of directory paths to search for plugins.
        """
        if isinstance(plugin_places, str):
            self.plugin_places = [plugin_places]
        else:
            self.plugin_places = list(plugin_places)
            
    def setPluginInfoExtractor(self, extractor) -> None:
        """Set the plugin info extractor (ignored, for compatibility).
        
        Args:
            extractor: Ignored.
        """
        self.plugin_info_extractor = extractor
        
    def collectPlugins(self) -> None:
        """Collect plugins from the configured plugin places.
        
        This searches for Python modules in the plugin directories and
        loads any classes that inherit from IPlugin.
        """
        self.plugins = []
        
        for plugin_dir in self.plugin_places:
            if not os.path.isdir(plugin_dir):
                continue
                
            # Add the plugin directory to sys.path so we can import modules from it
            if plugin_dir not in sys.path:
                sys.path.insert(0, plugin_dir)
                
            # Iterate over all modules in the plugin directory
            for importer, modname, ispkg in pkgutil.iter_modules([plugin_dir]):
                # Skip packages for simplicity
                if ispkg:
                    continue
                    
                try:
                    # Load the module
                    module = importer.find_module(modname).load_module(modname)
                except Exception:
                    # Skip modules that fail to load
                    continue
                    
                # Search for plugin classes in the module
                for name in dir(module):
                    obj = getattr(module, name)
                    # Check if it's a class that inherits from IPlugin (but not IPlugin itself)
                    if (inspect.isclass(obj) and 
                        issubclass(obj, IPlugin) and 
                        obj is not IPlugin):
                        try:
                            # Instantiate the plugin
                            plugin_instance = obj()
                            # Use the class name as the plugin name
                            plugin_info = PluginInfo(
                                name=obj.__name__,
                                plugin_object=plugin_instance,
                                plugin_type="Default"
                            )
                            self.plugins.append(plugin_info)
                        except Exception:
                            # Skip plugins that fail to instantiate
                            continue
                            
        # Remove plugin directories from sys.path to avoid pollution
        for plugin_dir in self.plugin_places:
            if plugin_dir in sys.path:
                sys.path.remove(plugin_dir)
                
    def getPlugins(self) -> List[PluginInfo]:
        """Get all collected plugins.
        
        Returns:
            List of PluginInfo objects.
        """
        return self.plugins
        
    def getAllPlugins(self) -> List[PluginInfo]:
        """Get all collected plugins (alias for getPlugins).
        
        Returns:
            List of PluginInfo objects.
        """
        return self.plugins
        
    def getPluginsByCategory(self, category: str) -> List[PluginInfo]:
        """Get plugins by category.
        
        This simplified version returns all plugins if category is "Default",
        otherwise returns an empty list.
        
        Args:
            category: The category to filter by.
            
        Returns:
            List of PluginInfo objects in the specified category.
        """
        if category == "Default":
            return self.plugins
        return []


# For backward compatibility, expose the classes at module level
__all__ = ['IPlugin', 'PluginInfo', 'PluginManager']