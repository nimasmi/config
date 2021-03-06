#! /usr/bin/env perl
# TTS - track your time.
# Copyright (c) 2014 Felicity Tarnell.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely. This software is provided 'as-is', without any express or implied
# warranty.
#
# ---
#
# This script will import entries from TTS into Bling, the Torchbox internal
# billing system.  It is provided here as an example of processing the TTS
# state file with Perl.
#
# All uninvoiced entries will be imported into the specified project.  You
# will need to manually move these to the correct client project in the
# Bling web interface.  After being imported, entries will be marked as
# invoiced.

use warnings;
use strict;
use LWP::UserAgent;
use URI::Escape qw/uri_escape/;
use POSIX qw/strftime/;
use Term::ReadKey;
use JSON;

my $base_url = "https://bling.torchbox.com";
my $project_id = 1333;  # Torchbox: Billing Agent default project
my $type_id = 7; # Technical programming.
            # 8 = Web development.
            # 3 = Project management.
            # 10 = System Administration

sub get_project_id {
    my $_ = shift;

    #return $project_id if /\[nt\]/;

    return 1651 if /^Gs/;   # Grantshot support retainor
    return 1391 if /^Ps/;   # PrimarySite support retainer
    return 663  if /^Bk/;   # Break from work
    return 54   if /^Tb/;   # Torchbox internal
    return 310  if /^Mt/;   # Meetings
    return 1002 if /^Tv/;   # Travel
    return 1506 if /^Pp/;   # Pinpoint
    # return 1695 if /^Fl/;   # Future Leaders

    # return 6    if /^Battersea/;    # BDH: Retainer and support
    # return 1332 if /^CLIC Sargent/; # CLIC Sargent: Ad-hoc support
    # return 1102 if /^CSP/;      # CSP: Retainer and support
    # return 565  if /^JRF/;      # JRF: Ad-hoc support
    # return 1108 if /^Nuffield/;     # Nuffield: Ad-hoc support
    # return 257  if /^Oxford/;       # Oxford: Ongoing support
    # return 425  if /^Torchbox/;     # Torchbox: Sysadmin
    # return 1509 if /^WRAP/;     # WRAP: Corporate digital support
    # return 1514 if /^WDC/;      # WDC: Ad-hoc support

    return $project_id;
}

my $inf = $ENV{'HOME'} . "/.rttts";
my $tmpf = $inf . ".tmp";

open INF, "<$inf" or die "Can't open $inf: $!";
open TMPF, ">$tmpf" or die "Can't open $tmpf: $!";

print "WARNING: Make sure TTS is *NOT* running!\n\n";

print "Bling username: ";
my $username = <STDIN>;
ReadMode 'noecho';
print "Bling password: ";
my $password = ReadLine 0;
ReadMode 'normal';
print "\n";

chomp($username);
chomp($password);

my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
$ua->agent("TTS-bling-importer/1.0");

while (<INF>) {
    if (/^#/) {
        print TMPF $_;
        next;
    }

    chomp($_);
    # Entry format is:
    # starttime secs flags Entry description...
    my ($start, $secs, $flags, $desc) = split /\s+/, $_, 4;

    if ($flags =~ /i/) {
        print TMPF "$_\n";
        next;
    }


    my $blingtime = strftime("%Y/%m/%d", localtime($start));
    my $req = HTTP::Request->new(POST => $base_url . "/api/bling/add/");
    $req->content_type('application/x-www-form-urlencoded');
    $req->content('username=' . uri_escape($username) .
            '&password=' . uri_escape($password) .
            '&project_id=' . uri_escape(get_project_id($desc)) .
            '&task_id=' .
            '&type_id=' . uri_escape($type_id) .
            '&date=' . uri_escape($blingtime) .
            '&time=' . uri_escape(int($secs / 60)) .
            '&time_client=' . uri_escape(int($secs / 60)) .
            '&details=' . uri_escape($desc));

    my $res = $ua->request($req);

    if ($res->is_success) {
        my $resp = decode_json($res->content);
        if (defined($resp->{description})) {
            print "Failed to Bling [$desc]: " . $resp->{description} . "\n";
        } else {
            if ($flags eq "-") {
                $flags = "i";
            } else {
                $flags .= 'i';
            }
            print "Blinged: $desc\n";
        }
    } else {
        print "Failed to Bling [$desc]: " . $res->status_line . "\n";
    }

    print TMPF "$start $secs $flags $desc\n";
}

close INF;
close TMPF;

rename ($tmpf, $inf) or die "Can't rename $inf to $tmpf: $!";
