#!/usr/bin/env perl
#
# Copyright (c) 2005-2006 The Trustees of Indiana University.
#                         All rights reserved.
# Copyright (c) 2006-2012 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2009      High Performance Computing Center Stuttgart, 
#                         University of Stuttgart.  All rights reserved.
# $COPYRIGHT$
# 
# Additional copyrights may follow
# 
# $HEADER$
#

package MTT::MPI::Install::OMPI;

use strict;
use Data::Dumper;
use MTT::DoCommand;
use MTT::Messages;
use MTT::FindProgram;
use MTT::Values;
use MTT::Files;
use MTT::Common::GNU_Install;
use MTT::Common::Cmake;
use MTT::Values::Functions::MPI::OMPI;

#--------------------------------------------------------------------------

sub Install {
    my ($ini, $section, $config) = @_;
    my $x;
    my $result_stdout;
    my $result_stderr;

    # Prepare $ret

    my $ret;
    $ret->{test_result} = MTT::Values::FAIL;
    $ret->{exit_status} = 0;
    $ret->{installdir} = $config->{installdir};
    $ret->{bindir} = "$ret->{installdir}/bin";
    $ret->{libdir} = "$ret->{installdir}/lib";

    # Get some OMPI-module-specific config arguments

    my $tmp;
    $tmp = Value($ini, $section, "ompi_make_all_arguments");
    $config->{make_all_arguments} = $tmp
        if (defined($tmp));

    # JMS: compiler name may have come in from "compiler_name"in
    # Install.pm.  So if we didn't define one for this module, use the
    # default from "compiler_name".  Note: to be deleted someday
    # (i.e., only rely on this module's compiler_name and not use a
    # higher-level default, per #222).
    $tmp = Value($ini, $section, "ompi_compiler_name");
    $config->{compiler_name} = $tmp
        if (defined($tmp));
    return 
        if (!MTT::Util::is_valid_compiler_name($section, 
                                               $config->{compiler_name}));
    # JMS: Same as above
    $tmp = Value($ini, $section, "ompi_compiler_version");
    $config->{compiler_version} = $tmp
        if (defined($tmp));

    $tmp = Value($ini, $section, "ompi_configure_arguments");
    $tmp =~ s/\n|\r/ /g;
    $config->{configure_arguments} = $tmp
        if (defined($tmp));

    $tmp = Logical($ini, $section, "ompi_make_check");
    $config->{make_check} = $tmp
        if (defined($tmp));

    $tmp = Logical($ini, $section, "ompi_autogen");
    $config->{autogen} = $tmp
        if (defined($tmp));

    $tmp = Value($ini, $section, "ompi_before_make_all");
    $config->{before_make_all} = $tmp
        if (defined($tmp));
        
    # Run configure / make all / make check / make install

    my $gnu = {
        configdir => $config->{configdir},
        configure_arguments => $config->{configure_arguments},
        compiler_name => $config->{compiler_name},
        vpath => "no",
        installdir => $config->{installdir},
        bindir => $config->{bindir},
        libdir => $config->{libdir},
        autogen => $config->{autogen},
        make_all_arguments => $config->{make_all_arguments},
        make_check => $config->{make_check},
        stdout_save_lines => $config->{stdout_save_lines},
        stderr_save_lines => $config->{stderr_save_lines},
        merge_stdout_stderr => $config->{merge_stdout_stderr},
        before_make_all => $config->{before_make_all},
    };

    my $install;
    if (MTT::Util::is_running_on_windows() && $config->{compiler_name} eq "microsoft") {
        $install = MTT::Common::Cmake::Install($gnu);
    } else {
        $install = MTT::Common::GNU_Install::Install($gnu);
    }

    foreach my $k (keys(%{$install})) {
        $ret->{$k} = $install->{$k};
    }
    return $ret
        if (exists($ret->{fail}));

    # Set which bindings were compiled

    $ret->{c_bindings} = 1;
    Debug("Have C bindings: 1\n");

    my $func = \&MTT::Values::Functions::MPI::OMPI::find_bindings;
    $ret->{cxx_bindings} = &{$func}($ret->{bindir}, $ret->{libdir}, "cxx");
    Debug("Have C++ bindings: $ret->{cxx_bindings}\n"); 

    # OMPI 1.7 (and higher) refer to "bindings:mpif.h".  Prior
    # versions refer to "bindings:f77".
    my $tmp;
    $tmp = &{$func}($ret->{bindir}, $ret->{libdir}, "f77");
    $tmp = &{$func}($ret->{bindir}, $ret->{libdir}, "mpif.h")
        if (!$tmp);
    $ret->{mpifh_bindings} = $ret->{f77_bindings} = $tmp;
    Debug("Have mpif.h bindings: $ret->{mpifh_bindings}\n"); 

    # OMPI 1.7 (and higher) refer to "bindings:use_mpi".  Prior
    # versions refer to "bindings:f90".
    $tmp = &{$func}($ret->{bindir}, $ret->{libdir}, "f90");
    $tmp = &{$func}($ret->{bindir}, $ret->{libdir}, "use_mpi")
        if (!$tmp);
    $ret->{usempi_bindings} = $ret->{f90_bindings} = $tmp;
    Debug("Have \"use mpi\" bindings: $ret->{usempi_bindings}\n"); 

    # OMPI 1.7 (and higher) have "bindings:use_mpi_f08".  Prior
    # versions do not have the mpi_f08 interface at all.
    $ret->{usempif08_bindings} = 
        &{$func}($ret->{bindir}, $ret->{libdir}, "use_mpi_f08");
    Debug("Have \"use mpi_f08\" bindings: $ret->{usempif08_bindings}\n"); 

    # Calculate bitness (must be processed *after* installation)

    my $func = \&MTT::Values::Functions::MPI::OMPI::find_bitness;
    $config->{bitness} = &{$func}($ret->{bindir}, $ret->{libdir});

    # Write out the OMPI cleanup script and be done.

    if ((0 != write_cleanup_script("$ret->{installdir}/bin")) 
        and (! $MTT::DoCommand::no_execute)) {
        $ret->{test_result} = MTT::Values::FAIL;
        $ret->{exit_status} = $x->{exit_status};
        $ret->{message} = "Failed to create cleanup script!";
    } else {
        $ret->{test_result} = MTT::Values::PASS;
        $ret->{result_message} = "Success";
        $ret->{exit_status} = $x->{exit_status};
        Debug("Build was a success\n");
    }

    return $ret;
} 

# Write out a script that's capable of cleaning up OMPI jobs
sub write_cleanup_script {
    my $bindir = shift;
    my $file = "$bindir/mtt_ompi_cleanup.pl";
    unlink($file);

    # Create the script and be paranoid about the permissions.

    my $u = umask;
    umask(0777);
    if (!open(FILE, ">$file")) {
        umask($u);
        return 1;
    }
    chmod(0755, $file);
    print FILE '#!/usr/bin/env perl
    
# This script is automatically generated by MTT/MPI/Install/OMPI.pm.  
# Manual edits will be lost.

# Helper cleanup script to kill all orteds on a node (except the one
# that spawed this script, so that the mpirun that started this script
# can complete normally), and remove all session directories.
';

    close(FILE);
    umask($u);
    return 0;
}


1;
