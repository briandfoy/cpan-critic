package CPAN::Critic::Policy::TestMoreWithSubtests;
use v5.20;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::TestMoreWithSubtests - Check that tests use subtests

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $files = CPAN::Critic::Util::FindFiles->get_test_files->value;

	foreach my $file ( $files->@* ) {
		push @problems, CPAN::Critic::Problem->new(
			description => "Test file ($file) uses subtests",
			file        => $file,
			) unless 1;
		}

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
