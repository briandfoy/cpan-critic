package CPAN::Critic::Policy::CONTRIBUTING;
use v5.10;


use strict;
use warnings;


use ReturnValue;

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
