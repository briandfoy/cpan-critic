package CPAN::Critic::Policy::DefaultManifestSkip;
use v5.10;

use strict;
use warnings;

use ReturnValue;
use Cwd;

my $SKIP_FILE = 'MANIFEST.SKIP';

sub run {
	my( $class, @args ) = @_;

	my $fh;

	my( $value, $description, $tag ) = do {
		if( ! -e $SKIP_FILE ) {
			( 0, "$SKIP_FILE exists", "found" );
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
		elsif( -r $SKIP_FILE ) {
			( 0, "$SKIP_FILE is readable: $!", "open" );
			}
		else {
			( 1, "$SKIP_FILE is good", "good" );
			}
		};
	
	my $method = $value ? 'success' : 'error';
	
	ReturnValue->$method(
		value      => $value,
		decription => $description,
		tag        => $tag,
		policy     => __PACKAGE__,
		);
	}

__PACKAGE__;
