package CPAN::Critic::Policy::BugTracker;
use v5.10;

use strict;
use warnings;

use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BugTracker - The Makefile arguments specifies a bugtracker

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $url = eval {
		$args->{META_MERGE}{resources}{bugtracker}{web}
		};

	my( $value, $description, $tag ) = do {
		if( ! exists $args->{META_MERGE} ) {
			( 0, 'META_MERGE is in the data structure', 'found' );
			}
		elsif( ! exists $args->{META_MERGE}{resources} ) {
			( 0, 'META_MERGE/resources is in the data structure', 'found' );
			}
		elsif( ! exists $args->{META_MERGE}{resources}{bugtracker} ) {
			( 0, 'META_MERGE/resources/bugtracker is in the data structure', 'found' );
			}
		elsif( ! $args->{META_MERGE}{resources}{bugtracker}{web} ) {
			( 0, 'META_MERGE/resources/bugtracker/web file is there', 'found' );
			}
		elsif( $url !~ m/issues/ ) {
			( 0, "bugtracker has /issues, literally", '???' );
			}
		else {
			( $url, 'The bugtracker is there', '???' );
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
