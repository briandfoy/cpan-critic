package CPAN::Critic::Policy::BuildFile::ExplicitModulesInPrereqs;
use v5.10;
use parent qw(CPAN::Critic::Policy::BuildFile::ExplicitModules);

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::ExplicitModulesInPrereqs - Check that all used modules show up in the prereqs

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

sub run { $_[0]->_run }

=item MM_key

=cut

sub MM_key      { 'PREREQ_PM' }

=item find_method

=cut

sub find_method { 'get_module_files' }


=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2023, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
