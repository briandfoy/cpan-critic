package CPAN::Critic::Util;
use 5.008;

use strict;
use warnings;

use Cwd qw(getcwd);
use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Util - Stuff you need in the other parts

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub extract_package {
	my( $class, $filename ) = @_;	

	unless( -e $filename ) {
		return ReturnValue->error(
			value => undef,
			description => 'File does not exist',
			file        => $filename,
			cwd         => getcwd(),
			);
		}

	require Module::Extract::Namespaces;
	my $namespace  = Module::Extract::Namespaces->from_file( $filename );

	ReturnValue->success(
		value => $namespace,
		);
	}

1;
