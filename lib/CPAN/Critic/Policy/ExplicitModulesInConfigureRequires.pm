package CPAN::Critic::Policy::ExplicitModulesInConfigureRequires;
use v5.10;
use parent qw(CPAN::Critic::Policy::ExplicitModules);

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::ExplicitModulesInConfigureRequires - Check that all used modules show up in the named key

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my %Ignores = map { $_, 1 } qw(
	strict warnings vars subs
	feature
	);

sub MM_key      { 'CONFIGURE_REQUIRES' }
sub find_method { 'get_build_files' }

sub run { $_[0]->_run }

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
