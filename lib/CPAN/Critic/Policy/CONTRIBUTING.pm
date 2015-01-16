package CPAN::Critic::Policy::CONTRIBUTING;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::CONTRIBUTING - Check that there's a contributing document

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = 'CONTRIBUTING';

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my( $value, $description, $tag ) = do {
		if( ! -e $FILE ) {
			( 0, "$FILE exists" );
			}
		elsif( ! -r $FILE ) {
			( 0, "$FILE is readable" );
			}
		elsif( ! -s $FILE ) {
			( 0, "$FILE has non-zero size" );
			}
		else {
			( 1, "$FILE is good" );
			}
		};

	push @problems, CPAN::Critic::Problem->new(
		description => $description,
		file        => $FILE,
		) unless $value;

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value       => \@problems,
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

Copyright © 2014-2015, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
