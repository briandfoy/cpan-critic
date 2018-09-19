package CPAN::Critic::Policy::BuildFile::ExplicitModulesInTestRequires;
use v5.10;
use parent qw(CPAN::Critic::Policy::BuildFile::ExplicitModules);

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::ExplicitModulesInTestRequires - Check that all used modules show up in tests are in TEST_REQUIRES

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub MM_key      { 'TEST_REQUIRES' }
sub find_method { 'get_test_files' }

sub run { $_[0]->_run }

=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;