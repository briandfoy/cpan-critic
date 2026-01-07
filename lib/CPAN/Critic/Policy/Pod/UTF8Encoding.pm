package CPAN::Critic::Policy::Pod::UTF8Encoding;
use v5.10;

use ReturnValue;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Pod::UTF8Encoding - Check that the pod has UTF-8 set

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

sub run {
	my( $class, @args ) = @_;

	my $pod_files = CPAN::Critic::Util::FindFiles->get_all_pod_files->value;

	my @problems;

	FILE: foreach my $file ( @$pod_files ) {
		open my $fh, '<:utf8', $file;
		my $in_pod;

		# the encoding should be the first pod directive
		LINE: while( <$fh> ) {
			next LINE unless /\A=(\S+)\s+(\S+)/;
			my( $directive, $encoding ) = ( $1, $2 );
			push @problems, CPAN::Critic::Problem->new(
				value       => 0,
				description => "=encoding isn't the first pod directive in ($file)",
				policy      => __PACKAGE__,
				) unless $directive eq 'encoding';

			push @problems, CPAN::Critic::Problem->new(
				value       => 0,
				description => "=encoding isn't UTF-8 in ($file)",
				policy      => __PACKAGE__,
				) unless $encoding eq 'utf8';

			next FILE;
			}

		push @problems, CPAN::Critic::Problem->new(
			value       => 0,
			description => "No pod in ($file)",
			policy      => __PACKAGE__,
			);
		}

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value       => \@problems,
		policy      => __PACKAGE__,
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

__PACKAGE__;
