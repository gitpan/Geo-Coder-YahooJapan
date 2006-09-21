# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Geo-Coder-YahooJapan.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('Geo::Coder::YahooJapan') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use Geo::Coder::YahooJapan;


my $r = Geo::Coder::YahooJapan::lookup("神奈川県川崎市中原区井田2-21-6");
ok ( defined $r);

my $lat = 35.557595;
my $lng = 139.64600972;

my $precision = 0.000001;

ok ( abs($r->{latitude} - $lat) < $precision );
ok ( abs($r->{longitude} - $lng) < $precision / 2 );

