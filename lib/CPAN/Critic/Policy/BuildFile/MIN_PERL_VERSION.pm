package CPAN::Critic::Policy::BuildFile::MIN_PERL_VERSION;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::MIN_PERL_VERSION - Check that the declared minimum version matches the actual one

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $rv = CPAN::Critic::Util::MakefilePL->check_if_modulino();
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	no warnings 'uninitialized';

	my( $value, $description ) = do {
		if( ! exists $args->{MIN_PERL_VERSION} ) {
			( 0, 'MIN_PERL_VERSION is in the data structure' );
			}
		else {
			( $args->{MIN_PERL_VERSION}, 'The minimum version is there' );
			}
		};

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

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
