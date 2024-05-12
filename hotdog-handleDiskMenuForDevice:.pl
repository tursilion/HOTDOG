#!/usr/bin/env perl

$device = shift @ARGV;
if (not $device) {
    die('specify device');
}

@lines = `hotdog-listDisks.pl`;
chomp @lines;
@lines = grep { m/\bfstype:[a-zA-Z0-9]+/ } @lines;

foreach $line (@lines) {
    if ($line !~ m/\bdevice:$device\b/) {
        next;
    }

    $fstype = '';
    if ($line !~ m/\bfstype:([a-zA-Z0-9]+)/) {
        next;
    }
    $fstype = $1;

    if ($line =~ m/\bmountpoint:([^\s]+)/) {
        $mountpoint = $1;

        $quotedDevice = $device;
        $quotedDevice =~ s/\\/\\\\/g;
        $quotedDevice =~ s/"/\\"/g;
        $quotedMountpoint = $mountpoint;
        $quotedMountpoint =~ s/\\/\\\\/g;
        $quotedMountpoint =~ s/"/\\"/g;
        $text = "The device '$quotedDevice' is mounted at '$quotedMountpoint'.";
        $cmd = sprintf('hotdog radio OK Cancel %s %s %s %s',
            qq{"$text"},
            'nothing 1 "Do Nothing"',
            'view 0 View',
            'unmount 0 Unmount');
        $result = `$cmd`;
        chomp $result;
        if ($result eq 'view') {
            chdir $mountpoint;
            system('hotdog', 'nav', '.');
        } elsif ($result eq 'unmount') {
            system('hotdog-unmountDevice.pl', $mountpoint);
        }
        exit 0;
    } else {
        system('hotdog-mountDevice.pl', $device, $fstype);
        exit 0;
    }
}

