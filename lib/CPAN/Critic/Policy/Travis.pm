package CPAN::Critic::Policy::Travis;
use v5.10;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Travis - Check the Travis CI configuration file

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = '.travis.yml';

sub run {
	my( $class, @args ) = @_;

	my $fh;

	my( $value, $description, $tag ) = do {
		if( ! -e $FILE ) {
			( 0, "$FILE exists", "found" );
			}
		elsif( ! -r $FILE ) {
			( 0, "$FILE is readable", "open" );
			}
		elsif( ! -s $FILE ) {
			( 0, "$FILE has non-zero size", "size" );
			}
		else {
			( 1, "$FILE is good", 'good' );
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
