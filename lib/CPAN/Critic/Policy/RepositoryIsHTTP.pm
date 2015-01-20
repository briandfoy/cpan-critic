package CPAN::Critic::Policy::RepositoryIsHTTP;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::RepositoryIsHTTP - The Makefile arguments specifies a bugtracker

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $url = eval {
		$args->{META_MERGE}{resources}{repository}{url}
		};

	my( $value, $description ) = do {
		if( ! exists $args->{META_MERGE} ) {
			( 0, 'META_MERGE is in the data structure' );
			}
		elsif( ! exists $args->{META_MERGE}{resources} ) {
			( 0, 'META_MERGE/resources is in the data structure' );
			}
		elsif( ! exists $args->{META_MERGE}{resources}{repository} ) {
			( 0, 'META_MERGE/resources/repository is in the data structure' );
			}
		elsif( ! $args->{META_MERGE}{resources}{repository}{url} ) {
			( 0, 'META_MERGE/resources/repository/url file is there' );
			}
		elsif( $url !~ m/\A http s? : /x ) {
			( 0, "The repository URL is HTTP" );
			}
		else {
			( $url, 'The repository URL checks out' );
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
