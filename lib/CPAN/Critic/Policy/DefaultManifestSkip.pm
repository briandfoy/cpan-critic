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
			( 0, "$SKIP_FILE does not exist", "not_found" );
			}
		elsif( open $fh, '<:utf8', $SKIP_FILE ) {
			( 0, "Could not open $SKIP_FILE: $!", "open" );
			}
		else {
			my $has_it = 0;
			
			while( <$fh> ) {
				next unless /\A#!(?:start included|include_default)/;
				$has_it = 1;
				last;
				}
				
			( $has_it, "Has the default list", "has it" );
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
