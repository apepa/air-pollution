#!/usr/bin/perl

use strict;
use warnings;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

my $user = getpwuid($<);
mkdir "/home/$user/data" unless -d "home/$user/data/";

my $date = join '-', ( ($year + 1900), ($mon + 1), ($mday) );
my $LUFTDATEN = "http://archive.luftdaten.info/";
my $FULL_URL = $LUFTDATEN . $date . "/";
my $ERR_LOG = "/home/$user/crawl.log";
my $PATH = "/home/$user/data";

# Predefine some log messages
my $l_predef = {
	1 => "Files for $date do not exist on the server",
	2 => "Files for $date found on server",
	3 => "Attempting to download .csv files for $date"
};

sub f_check {
	my $f_status = `/usr/bin/curl -s4 $FULL_URL`;
	return $f_status;
}

sub l {
	my ( $msg, $level ) = @_;
	$level = 0 unless defined ( $level );
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

	# Convert timestamp to logging format
	my $ts = sprintf ( "%04d%02d%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec );

	open ( my $l_handle, '>>', $ERR_LOG );
	print $l_handle "$ts [$level] $msg\n";
}

sub scrape {
	my ( $FULL_URL, $PATH ) = @_;
	my $scrape = `wget -r -np -nH -A "csv" -P $PATH -e robots=off --cut-dirs 3 --random-wait --quiet $FULL_URL`;
	my @files = <$PATH/*>;
	my $count = @files;
	return $count;
}

if ( f_check() =~ 'not found' ) {
	l ( $l_predef->{1} );
} elsif ( f_check () =~ 'csv' ) {
	l ( $l_predef->{2} );
	l ( $l_predef->{3} );
	my $scrape_count = scrape ( $FULL_URL, $PATH );
	l ( "Downloaded $scrape_count files in $PATH" );
}
