package CPAN::Critic::Policy::Files::CONTRIBUTING;
use v5.10;

use CPAN::Critic::Basics;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Files::CONTRIBUTING - Check that there's a contributing document

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

my @Files = qw( CONTRIBUTING CONTRIBUTING.md );

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my( $file ) = grep -e, @Files;

	my( $value, $description ) = do {
		if( ! -e $file ) {
			( 0, "$file exists" );
			}
		elsif( ! -r $file ) {
			( 0, "$file is readable" );
			}
		elsif( ! -s $file ) {
			( 0, "$file has non-zero size" );
			}
		else {
			( 1, "$file is good" );
			}
		};

	push @problems, CPAN::Critic::Problem->new(
		description => $description,
		file        => $file,
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

Copyright © 2014-2022, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
