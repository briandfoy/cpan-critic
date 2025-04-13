package CPAN::Critic::Basics;
use v5.20;
use strict;
use warnings;

our $VERSION = '0.001';

use CPAN::Critic::Problem;
use CPAN::Critic::Util::Lexer;
use CPAN::Critic::Util;
use CPAN::Critic::Util::FindFiles;
use CPAN::Critic::Util::MakefilePL;

use version      ();
use Data::Dumper ();
use List::Util   ();

use ReturnValue  ();

=encoding utf8

=head1 NAME

CPAN::Critic::Basics - Things everyone needs

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item import

=cut

use Import::Into;

sub import {
	my $target = caller;

	strict->import::into( $target );
	feature->import::into( $target, ':5.20', 'postderef' );

	warnings->import::into( $target );
	warnings->unimport::out_of( qw(
		experimental::postderef
		) );

	List::Util->import::into( $target, 'max' );
	Data::Dumper->import::into( $target, 'Dumper' );
	}

=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2025, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
