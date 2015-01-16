package CPAN::Critic::Util::FindFiles;
use 5.008;
use strict;
use warnings;

use File::Find qw(find);
use File::Spec::Functions qw(canonpath);

=encoding utf8

=head1 NAME

CPAN::Critic::Util::FindFiles - Find files easily

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub get_module_files     { $_[0]->find_by_extension( 'pm' ) }

sub get_pod_files        { $_[0]->find_by_extension( 'pod' ) }

sub get_all_pod_files    { $_[0]->find_by_extension( qw(pod pm pl PL) ) }

sub get_test_files       { $_[0]->find_by_extension( 't' ) }

sub find_by_name {
	my( $class, @names ) = @_;
	my %names = map { $_, 1 } @names;
	my( $policy ) = ( caller(1) )[0];

	my @files;
	my $wanted = sub {
		push @files, canonpath( $File::Find::name ) if exists $names{$_}
		};

	find( $wanted, '.' );

	ReturnValue->success(
		value => \@files,
		);
	}

sub find_by_extension {
	my( $class, @extensions ) = @_;
	my %extensions = map { $_, 1 } @extensions;
	my( $policy ) = ( caller(1) )[0];

	my @files;
	my $wanted = sub {
		no warnings 'uninitialized';
		my( $extension ) = /\.([^.]+)\z/;
		push @files, canonpath( $File::Find::name )
			if exists $extensions{$extension};
		};

	find( $wanted, '.' );

	ReturnValue->success(
		value => \@files,
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

1;
