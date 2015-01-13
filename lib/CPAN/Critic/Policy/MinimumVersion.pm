package CPAN::Critic::Policy::MinimumVersion;
use v5.10;

use strict;
use warnings;

use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::MinimumVersion - Check that the declared minimum version matches the actual one

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

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
