package CPAN::Critic::Policy::MinimumVersion;
use v5.10;

use strict;
use warnings;

use ReturnValue;

sub run {
	my( $class, @args ) = @_;

	my $rv = CPAN::Critic::Util::MakefilePL->check_if_modulino();
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	no warnings 'uninitialized';

	my( $value, $description, $tag ) = do {
		if( ! exists $args->{MIN_PERL_VERSION} ) {
			( 0, 'MIN_PERL_VERSION is in the data structure', 'found' );
			}
		else {
			( $args->{MIN_PERL_VERSION}, 'The minimum version is there', '???' );
			}
		};

	my $method = $value ? 'success' : 'error';

	ReturnValue->$method(
		value       => $value,
		description => $description,
		tag         => $tag,
		policy      => __PACKAGE__,
		);
	}
	}


__PACKAGE__;
