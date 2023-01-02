package CPAN::Critic::Policy::MANIFEST::DefaultManifestSkip;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::MANIFEST::DefaultManifestSkip - Check MANIFEST.SKIP uses the defaults

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

my $FILE = 'MANIFEST.SKIP';

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $fh;

	my( $value, $description ) = do {
		if( ! -e $FILE ) {
			( 0, "$FILE exists" );
			}
		elsif( ! -r $FILE ) {
			( 0, "$FILE is readable: $!" );
			}
		elsif( open $fh, '<:utf8', $FILE ) {
			my $has_it = 0;

			while( <$fh> ) {
				next unless /\A#!(?:start included|include_default)/;
				$has_it = 1;
				last;
				}

			( $has_it, "$FILE uses the default list" );
			}
		else {
			( 0, "$FILE couldn't be opened: $!" );
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

Copyright © 2014-2023, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
