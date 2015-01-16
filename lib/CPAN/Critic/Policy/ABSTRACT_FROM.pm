package CPAN::Critic::Policy::ABSTRACT_FROM;
use v5.10;
use strict;
use warnings;

use ReturnValue;
use ExtUtils::MM_Unix;
use CPAN::Critic::Util::MakefilePL;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::ABSTRACT_FROM - Check that the ABSTRACT_FROM is in the Makefile.PL

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = 'Makefile.PL';

sub run {
	my( $class, @args ) = @_;

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

	my( $value, $description, $tag ) = do {
		if( ! exists $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM is in the data structure', 'found' );
			}
		elsif( ! -e $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is there', 'found' );
			}
		elsif( ! -r $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is readable', 'found' );
			}
		elsif( ! $abstract ) {
			( 0, 'ABSTRACT_FROM is there', '???' );
			}
		elsif( $abstract =~ m/This/ ) {
			( 0, "ABSTRACT_FROM doesn't have boilerplate", '???' );
			}
		else {
			( $abstract, 'The abstract is okay', '???' );
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
