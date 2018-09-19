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

=item new

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

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
