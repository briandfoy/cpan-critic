package CPAN::Critic::Policy::Pod::SeeAlso;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Pod::SeeAlso - Check for SEE ALSO, somewhere

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my( $value, $description ) = (
		1,
		'Null',
		);

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value       => \@problems,
		description => $description,
		policy      => $class,
		);
	}

=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2025, brian d foy <briandfoy@pobox.com>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
