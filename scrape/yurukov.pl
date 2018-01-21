#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my $user = getpwuid($<);

my $DIR = "/home/$user/hourly_data/";
my $INIT_FILE = $DIR . "hourly_data.csv";
my $NEW_FILE = $DIR . "new_entries.csv";
my $URL = "http://opendata.yurukov.net/pollution/data/sofia_airpollution_week.csv";

mkdir $DIR unless -d $DIR;

if ( -f $INIT_FILE ) {
	my $scrape = `wget -O $NEW_FILE --quiet $URL`;
} else {
	my $scrape = `wget -O $INIT_FILE --quiet $URL`;
}

if ( -f $NEW_FILE ) {
	open (my $r_h, '<', $NEW_FILE);
	my @lines = <$r_h>;
	close $r_h;
	splice @lines, 0, ($#lines - 5);
	open (my $w_h, '>>', $INIT_FILE);
	s/\R\z// for @lines;
	for my $entry (0 .. $#lines) {
		print $w_h "\n" if $entry == 0;
		print $w_h $lines[$entry];
		print $w_h "\n" unless $entry == $#lines;
	}
}

