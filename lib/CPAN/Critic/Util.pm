package CPAN::Critic::Util;
use 5.008;

use strict;
use warnings;

use Cwd qw(getcwd);
use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Util - Stuff you need in the other parts

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item extract_package

=cut

sub extract_package {
	my( $class, $filename ) = @_;

	unless( -e $filename ) {
		return ReturnValue->error(
			value => undef,
			description => 'File does not exist',
			file        => $filename,
			cwd         => getcwd(),
			);
		}

	require Module::Extract::Namespaces;
	my $namespace  = Module::Extract::Namespaces->from_file( $filename );

	ReturnValue->success(
		value => $namespace,
		);
	}

=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2025, brian d foy <briandfoy@pobox.com>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
