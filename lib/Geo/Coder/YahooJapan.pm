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

our $VERSION = '0.01';

# Preloaded methods go here.

my $entry_point = 'http://api.map.yahoo.co.jp/MapsService/V1/search';

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
	
	my $result = undef;
	while ( $response =~ m|<(\w+)>(.+?)</\1>|g ) {
		$result or $result = {};
		$result->{$1} = $2;
	}
	return $result;
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
  ($lat, $lng) = ($wgs->lat, #wgs->long);

=head1 DESCRIPTION

Geo::Coder::YahooJapan is a wrapper for Yahoo Japan Geocoder API that is used by the
official Yahoo Japan's local search widget
L<http://widgets.yahoo.co.jp/gallery/detail.html?wid=10> .
The API returns coordinates in TOKYO datum. if you need the coordinates in WGS84,
you need to convert them with Location::GeoTool etc.

=head3 lookup(address)

lookup is an only method in this package that returns coordinate information
in an hash reference.
Maybe you can specify the address in any character set you like.
The API server accepts UTF8, SHIFT_JIS, EUC_JP.


=head1 DEPENDENCIES

using L<LWP::Simple> to make a request to the API server.

=head1 SEE ALSO

L<Location::GeoTool> can convert coordination systems.

=head1 AUTHOR

KUMAGAI Kentaro <lt>ku0522a+cpan@gmail.comE<gt>

=cut
