package CPAN::Critic::Policy::DefaultManifestSkip;
use v5.10;

use strict;
use warnings;

use ReturnValue;
use Cwd;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::DefaultManifestSkip - Check MANIFEST.SKIP uses the defaults

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $SKIP_FILE = 'MANIFEST.SKIP';

sub run {
	my( $class, @args ) = @_;

	my $fh;

	my( $value, $description, $tag ) = do {
		if( ! -e $SKIP_FILE ) {
			( 0, "$SKIP_FILE exists", "found" );
			}
		elsif( ! -r $SKIP_FILE ) {
			( 0, "$SKIP_FILE is readable: $!", "open" );
			}
		elsif( open $fh, '<:utf8', $SKIP_FILE ) {
			my $has_it = 0;

			while( <$fh> ) {
				next unless /\A#!(?:start included|include_default)/;
				$has_it = 1;
				last;
				}

			( $has_it, "$SKIP_FILE uses the default list", "has it" );
			}
		else {
			( 0, "$SKIP_FILE couldn't be opened: $!", "open" );
			}
		};

	my $method = $value ? 'success' : 'error';

	ReturnValue->$method(
		value       => $value,
		description => $description,
		tag         => $tag,
		policy      => __PACKAGE__,
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
