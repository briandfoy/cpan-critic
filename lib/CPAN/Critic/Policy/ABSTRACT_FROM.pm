package CPAN::Critic::Policy::ABSTRACT_FROM;
use v5.10;
use strict;
use warnings;

use ReturnValue;
use ExtUtils::MM_Unix;
use CPAN::Critic::Util::MakefilePL;

my $FILE = 'Makefile.PL';

sub run {
	my( $class, @args ) = @_;

	my $rv = CPAN::Critic::Util::MakefilePL->check_if_modulino();
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $object = bless {
		DISTNAME => $args->{NAME},
		}, 'ExtUtils::MM_Unix';

	my $abstract = eval { $object->parse_abstract( $args->{ABSTRACT_FROM} ) };

	my( $value, $description, $tag ) = do {
		if( ! exists $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM is in the data structure', 'found' );
			}
		elsif( ! -e $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is there', 'found' );
			}
		elsif( ! -r $args->{ABSTRACT_FROM} ) {
			( 0, 'ABSTRACT_FROM file is readable', 'found' );
			}
		elsif( ! $abstract ) {
			say "Error: $@\nAbstract: $abstract";
			( 0, 'ABSTRACT_FROM is there', '???' );
			}
		elsif( $abstract =~ m/This/ ) {
			( 0, "ABSTRACT_FROM doesn't have boilerplate", '???' );
			}
		else {
			( $abstract, 'The abstract is okay', '???' );
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
