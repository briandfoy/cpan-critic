package CPAN::Critic::Util::MakefilePL;
use 5.008;
use strict;
use warnings;

use Cwd                   qw(getcwd);
use File::Spec::Functions qw(rel2abs);

=encoding utf8

=head1 NAME

CPAN::Critic::Util::MakefilePL - Do things with the Makefile.PL

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = "Makefile.PL";

my $REGISTRY = {};

sub get_args {
	$_[0]->check_if_modulino;
	}

sub check_if_modulino {
	my( $class, $arg ) = @_;

	my( $policy ) = ( caller(1) )[0];

	$FILE = $arg if $arg;

	my $path = rel2abs( $FILE, getcwd );
	
	unless( -e $path ) {
		return ReturnValue->error(
			value      => 0,
			description => "$FILE is there",
			tag        => 'found',
			policy     => $policy,
			);
		}

	if( exists $REGISTRY->{$path} ) {
		return ReturnValue->success(
			value => $REGISTRY->{$path},
			file  => $path,
			)
		}

	delete $INC{$path};
	my $package = eval "require '$path'";
	my $at = $@;

	if( $at ) {
		return ReturnValue->error(
			value      => 0,
			description => "$FILE loads",
			tag        => '???',
			policy     => $policy,
			);
		}

	unless( eval{ $package->can( 'arguments' ) } ) {
		return ReturnValue->error(
			value      => 0,
			description => "$FILE->arguments is available",
			tag        => '???',
			policy     => $policy,
			);
		}

	my $args = eval { $package->arguments };
	unless( ref $args eq ref {} ) {
		return ReturnValue->error(
			value      => 0,
			description => "$FILE->arguments does not return a hash ref",
			tag        => '???',
			policy     => $policy,
			);
		}

	$REGISTRY->{$path} = $args;

	ReturnValue->success(
		value => $args,
		file  => $path,
		);
	}

1;
