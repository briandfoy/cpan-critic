package CPAN::Critic::Problem;
use 5.010;
use parent qw(Hash::AsObject);

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Problem - represents something you need to fix

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut


sub new {
	my( $class, %args ) = @_;

	$args{policy} //= (caller(1))[0];

	bless \%args, $class;
	}











=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2021, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
