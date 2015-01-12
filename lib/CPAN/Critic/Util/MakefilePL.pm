package CPAN::Critic::Util::MakefilePL;
use strict;
use warnings;

my $FILE = "Makefile.PL";

sub check_if_modulino {
	my( $class, $arg ) = @_;

	my( $policy ) = ( caller(1) )[0];

	$FILE = $arg if $arg;

	unless( -e $FILE ) {
		return ReturnValue->error(
			value      => 0,
			decription => "$FILE is there",
			tag        => 'found',
			policy     => $policy,
			);
		}

	delete $INC{$FILE};
	my $package = eval "require '$FILE'";
	my $at = $@;

	if( $at ) {
		return ReturnValue->error(
			value      => 0,
			decription => "$FILE loads",
			tag        => '???',
			policy     => $policy,
			);
		}

	unless( eval{ $package->can( 'arguments' ) } ) {
		return ReturnValue->error(
			value      => 0,
			decription => "$FILE->arguments is available",
			tag        => '???',
			policy     => $policy,
			);
		}


	my $args = eval { $package->arguments };
	unless( ref $args eq ref {} ) {
		return ReturnValue->error(
			value      => 0,
			decription => "$FILE->arguments does not return a hash ref",
			tag        => '???',
			policy     => $policy,
			);
		}

	ReturnValue->success(
		value => $args,
		);
	}

1;
