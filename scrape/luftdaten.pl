#!/usr/bin/perl

use strict;
use warnings;

use DateTime;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();


my $user = getpwuid($<);
mkdir "/home/$user/data" unless -d "home/$user/data/";

my $date_dash = DateTime->now->subtract(days => 1)->date;

my $LUFTDATEN = "http://archive.luftdaten.info/";
my $LUFTDATEN_URL = $LUFTDATEN . $date_dash . "/";
my $LUFTDATEN_PATH = "/home/$user/data_luftdaten";

my $ERR_LOG = "/home/$user/crawl.log";

sub f_check {
	my ( $FULL_URL ) = @_;
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

### LUFTDATEN ###

if ( f_check( $LUFTDATEN_URL ) =~ 'not found' ) {
	l ( "Files for $date_dash do not exist on the luftdaten server" );
} elsif ( f_check ( $LUFTDATEN_URL ) =~ 'csv' ) {
	l ( "Files for $date_dash found on the luftdaten server" );
	l ( "Attempting to download .csv files for $date_dash" );
	my $scrape_count = scrape ( $LUFTDATEN_URL, $LUFTDATEN_PATH );
	l ( "Downloaded $scrape_count files in $LUFTDATEN_PATH" );
}

