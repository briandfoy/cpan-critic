#!/Users/brian/bin/perls/perl5.20.0

use FindBin qw($Bin);

use lib "$Bin/lib";
use lib qw(
	/Users/brian/Dev/ReturnValue/lib
	);

use CPAN::Critic;


my $critic = CPAN::Critic->new;

$critic->critique( '.' );

1;

