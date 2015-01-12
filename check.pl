#!/Users/brian/bin/perls/perl5.20.0
use v5.20;
use feature qw(postderef);

use FindBin qw($Bin);
use File::Basename;

use lib "$Bin/lib";
use lib qw(
	/Users/brian/Dev/ReturnValue/lib
	);

use CPAN::Critic;

my $critic = CPAN::Critic->new;

@ARGV = '.' unless @ARGV;

# find . -name "Makefile.PL" -print0 | xargs -0 cpan-critic
my @dirs = map {
	/Makefile.PL$/ ? dirname($_) : $_;
	} @ARGV;

foreach my $dir ( @dirs ) {
	say "===========Processing $dir";
	my $rc = $critic->critique( $dir );

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
		say "Big problem: ", $rc->description;
		}
	}

1;

