#!/usr/bin/perl

print <<EOF;
panelHorizontalStripes
panelText:''
panelText:'This is the DateTimePanel'
panelText:''
panelButton:'Sync Time with NTP' message:[['ntpdate' 'pool.ntp.org']|runCommandWithSudoAndReturnOutput|asString|showAlert]
EOF

