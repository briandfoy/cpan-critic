package CPAN::Critic::Policy::Changes;
use v5.10;

use strict;
use warnings;

use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Changes - Check the Changes file

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;

	my( $value, $description, $tag ) = (
		1,
		'Null',
		'null'
		);

	my $method = $value ? 'success' : 'error';

	ReturnValue->$method(
		value       => $value,
		description => $description,
		tag         => $tag,
		policy      => __PACKAGE__,
		);
	}

__PACKAGE__;
