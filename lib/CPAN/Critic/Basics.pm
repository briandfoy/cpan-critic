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

use version;
use Data::Dumper qw(Dumper);
use List::Util;

use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Basics - Things everyone needs

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub import {
	warnings->import;
	warning->unimport( qw(
		experimental::postderef
		) );
	List::Util->import( 'max' );
	strict->import;
	feature->import( ':5.20', 'postderef' );
	}

sub unimport {
    warnings->unimport;
    strict->unimport;
    feature->unimport;
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
