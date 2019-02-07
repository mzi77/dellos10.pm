package dellos10;
# 
# Dell NOs10 support module
# 
# Derived from dell.pm module 
#
# Contact martin.zidek@gmail.com
#
# RANCID - Really Awesome New Cisco confIg Differ
#
# Code tested and working fine on Dell S3048-ON running 10.4.1.2
#
# dellos10.pm
#
use 5.010;
use strict 'vars';
use warnings;
no warnings 'uninitialized';
require(Exporter);
our @ISA = qw(Exporter);

use rancid 3.2;

our $proc;
our $found_version;

@ISA = qw(Exporter rancid main);
#XXX @Exporter::EXPORT = qw($VERSION @commandtable %commands @commands);

# load-time initialization
sub import {
    $timeo = 300;		# clogin timeout in seconds (some of these
				# devices are remarkably slow to read config)

    0;
}

# post-open(collection file) initialization
sub init {
    $proc = "";
    $found_version = 0;

    # add content lines and separators
    ProcessHistory("","","","!RANCID-CONTENT-TYPE: Dell NOS10\n\n");

    0;
}


# main loop of input of device output
sub inloop {
    my($INPUT, $OUTPUT) = @_;
    my($cmd, $rval,$prevline);
# hacked
#$clean_run = 1;

TOP: while(<$INPUT>) {
	tr/\015//d;
	# XXX this match is not correct for DELL
	#if (/[>#]\s?exit$/) {
	if (/^Error:/) {
	    print STDOUT ("$host clogin error: $_");
	    print STDERR ("$host clogin error: $_") if ($debug);
	    $clean_run = 0;
	    last;
	}
	while (/^.+(#|\$)\s*($cmds_regexp)\s*$/) {
	    $cmd = $2;
	    # - D-Link prompts end with '#'.
	    if ($_ =~ m/^.+#/) {
		$prompt = '.+#.*';
	    }
	    print STDERR ("HIT COMMAND:$_") if ($debug);
	    if (! defined($commands{$cmd})) {
	        print STDERR "$host: found unexpected command - \"$cmd\"\n";
		$clean_run = 0;
	        last TOP;
	    }
	    $rval = &{$commands{$cmd}}($INPUT, $OUTPUT, $cmd);
	    delete($commands{$cmd});
	    if ($rval == -1) {
		$clean_run = 0;
	        last TOP;
	    }
	}
       if (/.+#exit/) {
	    print STDERR ("exit found $_") if ($debug);
	    $clean_run = 1;
	    last;
	}
}
}

# This routine parses "show version"
sub GetSystem {
    my($INPUT, $OUTPUT, $cmd) = @_;
    print STDERR "    In GetSystem: $_" if ($debug);

    while (<$INPUT>) {
	tr/\015//d;
	next if /^\s*$/;
	last if (/$prompt/);

    	print STDERR "  GetSystem  line: \"$_\"" if ($debug);
	#next if (/^system up time:/i);
	#next if (/^\s*Virus-DB: .*/);
	#next if (/^\s*Extended DB: .*/);
	#next if (/^\s*IPS-DB: .*/);
	#next if (/^FortiClient application signature package:/);
	ProcessHistory("","","","!$_");
    }
    ProcessHistory("SYSTEM","","","\n");
    return(0);
}

#sub GetFile {
#    my($INPUT, $OUTPUT, $cmd) = @_;
#    print STDERR "    In GetFile: $_" if ($debug);
#
#    while (<$INPUT>) {
#	last if (/$prompt/);
#    }
#    ProcessHistory("FILE","","","\n");
#    return(0);
#}

sub GetConf {
    my($INPUT, $OUTPUT, $cmd) = @_;
    my($password_counter) = (0);
    print STDERR "    In GetConf: $_" if ($debug);
    print STDERR "    Prompt: \"$prompt\"" if ($debug);

    while (<$INPUT>) {
	tr/\015//d;
	next if /^\s*$/;
	last if (/$prompt/);

    	print STDERR "  GetConf  line: \"$_\"" if ($debug);
	# filter variabilities between configurations.  password encryption
	# upon each display of the configuration.
	#if (/^\s*(set [^\s]*)\s(Enc\s[^\s]+)(.*)/i && $filter_pwds > 0 ) {
	#    ProcessHistory("ENC","","","#$1 ENC <removed> $3\n");
	#    next;
	#}
	# if filtering passwords, note that we're on an opening account line
        # next two lines will be passwords
	#if (/^create account / && $filter_pwds > 0 ) {
        #      $password_counter = 2;
	#      ProcessHistory("","","","#$_");
        #      next;
	#}
	#elsif ($password_counter > 0) {
        #      $password_counter--;
	#      ProcessHistory("","","","#<removed>\n");
        #      next;
	#}
	ProcessHistory("","","","$_");
    }
    $found_end = 1;
    return(1);
}

1;
