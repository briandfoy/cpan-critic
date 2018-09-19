package CPAN::Critic::Policy::BuildFile::ABSTRACT_FROM;
use v5.10;

use CPAN::Critic::Basics;

use ExtUtils::MM_Unix;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::ABSTRACT_FROM - Check that the ABSTRACT_FROM is in the Makefile.PL

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = 'Makefile.PL';

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $rv = CPAN::Critic::Util::MakefilePL->get_args();
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	no warnings 'uninitialized';
	my $abstract = eval {
		my $object = bless {
			DISTNAME => $args->{NAME},
			}, 'ExtUtils::MM_Unix';

		$object->parse_abstract( $args->{ABSTRACT_FROM} )
		};

	my( $value, $description ) = do {
		if( ! exists $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM is in the data structure' );
			}
		elsif( ! -e $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is there' );
			}
		elsif( ! -r $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is readable' );
			}
		elsif( ! $abstract ) {
			( 0, 'ABSTRACT_FROM is there' );
			}
		elsif( $abstract =~ m/This/ ) {
			( 0, "ABSTRACT_FROM doesn't have boilerplate" );
			}
		else {
			( $abstract, 'The abstract is okay' );
			}
		};

	push @problems, CPAN::Critic::Problem->new(
		value       => $value,
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

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
