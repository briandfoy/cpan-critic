#!/Users/brian/bin/perls/perl5.20.0
use v5.20;
use feature qw(postderef);

use FindBin qw($Bin);

use lib "$Bin/lib";
use lib qw(
	/Users/brian/Dev/ReturnValue/lib
	);

use CPAN::Critic;

my $critic = CPAN::Critic->new;

my $rc = $critic->critique( '/Users/brian/Dev/ReturnValue' );

if( $rc->is_success ) {
	my $results = $rc->value;

	foreach my $result ( $results->@* ) {
		printf "%4s <- %s\n", $result->value ? 'PASS' : 'FAIL', $result->policy;

		unless( $result->value ) {
			say Dumper( $result ); use Data::Dumper;
			say "\tProblem: ", $result->description;
			}
		}
	}
else {
	say "Big problem: ", $result->description;
	}

1;

