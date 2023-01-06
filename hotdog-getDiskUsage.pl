#!/usr/bin/perl

$pct = undef;

$output = `df .`;
if ($output =~ m/([0-9]+)\%/) {
    $pct = $1 / 100.0;
}

if ($output =~ m/([0-9]+)\s+[0-9]+\%/) {
    $available = $1;
}

print "pct:$pct available:$available\n";

