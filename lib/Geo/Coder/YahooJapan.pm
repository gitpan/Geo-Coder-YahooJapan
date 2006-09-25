package Geo::Coder::YahooJapan;

use 5.008004;
use strict;
use warnings;

use LWP::Simple;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Geo::Coder::YahooJapan ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	lookup
);

our $VERSION = '0.02';

# Preloaded methods go here.

my $entry_point = 'http://api.map.yahoo.co.jp/MapsService/V1/search';

use Data::Dumper;

sub lookup {
	my $address = shift;
	my $opts = shift;

	$address or return undef;

	defined $opts->{num} or $opts->{num} = 10;
	defined $opts->{prop} or $opts->{prop} = 'widget';
	$address =~ s/([\W])/ sprintf "%%%02X", ord($1) /ge;

	my $params = {
		prop => $opts->{prop},
		b => 1,
		n => int $opts->{num},
		ac => "",
		st => "",
		p => $address
	};
	
	my $q = join "&", ( map { "$_=" . $params->{$_} } (keys %$params) );
	my $url = "$entry_point?$q";
	my $response = get( $url );

	$response or return undef;
	
	my @items = ();
	@_ = split m|<item>|, $response;
	scalar @_ == 0 and return undef;

	while ( $response =~ m|<item>(.+?)</item>|sg ) {
		my $item_content = $1;

		my $result = {};
		while ( $item_content =~ m|<(\w+)>(.+?)</\1>|g ) {
			$result->{$1} = $2;
		}
		push @items, $result;
	}

	return {
		latitude => $items[0]->{latitude},
		longitude => $items[0]->{longitude},
		hits => scalar @items,
		items => \@items
	};
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Geo::Coder::YahooJapan - a simple wrapper for Yahoo Japan Geocoder API

=head1 SYNOPSIS

  use Geo::Coder::YahooJapan;
  my $r = lookup("神奈川県川崎市中原区井田2-21-6");
  my ($lat, $lng) = ( $r->{latitude}, $r->{longitude} ); # coordinate in TOKYO.

  use Location::GeoTool;
  my $tokyo = Location::GeoTool->create_coord($lat, $lng, 'tokyo', 'degree');
  my $wgs = $tokyo->datum_wgs84;
  my $wgs->format_degree;
  
  # coordinate in WGS87.
  ($lat, $lng) = ($wgs->lat, $wgs->long);

  # if address is ambiguous and the server returns multiple items
  my $r = lookup("東京都渋谷区東");
  # $r->{latitude} and $r->{longitude} contains coordinate of first item.
  my ($lat, $lng) = ( $r->{latitude}, $r->{longitude} );

  # $r->{hits} has the number of candidates.
  if ( $r->{hits} > 1 ) {
  	# and $r->{items} contains each candidates infomation.
  	foreach ( $r->{items} ) {
		print join "\t", ( $_->{title}, $_->{latitude}, $_->{longitude} );
		print "\n";
	}
  }

=head1 DESCRIPTION

Geo::Coder::YahooJapan is a wrapper for Yahoo Japan Geocoder API that is used by the
official Yahoo Japan's local search widget
L<http://widgets.yahoo.co.jp/gallery/detail.html?wid=10> .
The API returns coordinates in TOKYO datum. if you need the coordinates in WGS84,
you need to convert them with Location::GeoTool etc.

=head3 lookup(address, opts)

Lookup is an only method in this package that returns coordinate information
in an hash reference. When address is not enough precise, the server returns multiple candidates.
These candidatse are found in $response->{items}. You can determine geocoding result has multiple candidates or not by seeing $response->{hits}.

You can specify the address in UTF8, SHIFT_JIS, EUC_JP. But the API server does not understand ISO-2022-JP, so you need convert into other character set if your address is written in ISO-2022-JP.
In $opts->{num}, you can specify the number of candidates you want to receive when multiple items are found. Default value is 10.

=head1 DEPENDENCIES

using L<LWP::Simple> to make a request to the API server.

=head1 SEE ALSO

L<Location::GeoTool> can convert coordination systems.

=head1 AUTHOR

KUMAGAI Kentaro E<lt>ku0522a+cpan@gmail.comE<gt>

=cut
