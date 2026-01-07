package CPAN::Critic::Util::MakefilePL;
use 5.008;

use CPAN::Critic::Basics;

use Cwd                   qw(getcwd);
use File::Spec::Functions qw(rel2abs);

=encoding utf8

=head1 NAME

CPAN::Critic::Util::MakefilePL - Do things with the Makefile.PL

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=cut

my $FILE = "Makefile.PL";

my $REGISTRY = {};

=item get_args

=cut

sub get_args {
	$_[0]->check_if_modulino;
	}

=item check_if_modulino

=cut

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

=back

=head1 TO DO


=head1 SOURCE AVAILABILITY

This code is in Github:

	http://github.com/briandfoy/cpan-critic

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2026, brian d foy <briandfoy@pobox.com>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
