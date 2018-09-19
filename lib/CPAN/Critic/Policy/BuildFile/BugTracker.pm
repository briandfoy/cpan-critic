package CPAN::Critic::Policy::BuildFile::BugTracker;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::BugTracker - The Makefile arguments specifies a bugtracker

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

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $url = eval {
		$args->{META_MERGE}{resources}{bugtracker}{web}
		};

	my( $value, $description ) = do {
		if( ! exists $args->{META_MERGE} ) {
			( 0, 'META_MERGE is in the data structure' );
			}
		elsif( ! exists $args->{META_MERGE}{resources} ) {
			( 0, 'META_MERGE/resources is in the data structure' );
			}
		elsif( ! exists $args->{META_MERGE}{resources}{bugtracker} ) {
			( 0, 'META_MERGE/resources/bugtracker is in the data structure' );
			}
		elsif( ! $args->{META_MERGE}{resources}{bugtracker}{web} ) {
			( 0, 'META_MERGE/resources/bugtracker/web file is there' );
			}
		elsif( $url !~ m/issues/ ) {
			( 0, "bugtracker has /issues, literally" );
			}
		else {
			( $url, 'The bugtracker is there' );
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

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
