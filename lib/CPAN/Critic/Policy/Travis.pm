package CPAN::Critic::Policy::Travis;
use v5.10;


use strict;
use warnings;

use ReturnValue;

my $FILE = '.travis.yml';

sub run {
	my( $class, @args ) = @_;

	my $fh;

	my( $value, $description, $tag ) = do {
		if( ! -e $FILE ) {
			( 0, "$FILE exists", "found" );
			}
		elsif( -r $FILE ) {
			( 0, "$FILE is readable", "open" );
			}
		elsif( -s $FILE ) {
			( 0, "$FILE has non-zero size", "size" );
			}
		else {
			( 1, "$FILE is good", 'good' );
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
