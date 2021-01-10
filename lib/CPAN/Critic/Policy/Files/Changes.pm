package CPAN::Critic::Policy::Files::Changes;
use v5.10;

use CPAN::Critic::Basics;

use CPAN::Changes;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Files::Changes - Check the Changes file

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

my $FILE = 'Changes';

sub run {
	my( $class, @args ) = @_;
	my @problems;

    my $changes = eval { CPAN::Changes->load( $FILE ) };
	my $at = $@;

	if( $at ) {
		push @problems, CPAN::Critic::Problem->new(
			value       => $at,
			description => "Parsed the Changes file",
			);

		return ReturnValue->error(
			value  => \@problems,
			policy => $class,
			);
		}

    my @releases = $changes->releases;
	push @problems, CPAN::Critic::Problem->new(
		description => "The Changes file has at least one release",
		) unless @releases;
	return ReturnValue->error(
		value  => \@problems,
		policy => $class,
		) if @problems;


    foreach my $release ( @releases ) {
        if ( !defined $release->date || $_->release eq ''  ) {
			push @problems, CPAN::Critic::Problem->new(
				description => "No date for version " . $release->version,
				version     => $release->version,
				);
        	}

		unless( $release->{_parsed_date} =~ m/\A${CPAN::Changes::W3CDTF_REGEX}\z/ ) {
			push @problems, CPAN::Critic::Problem->new(
				description => "The date for version " . $release->version . " is the right format",
				parsed_date => $release->{_parsed_date},
				);
			}

        # strip off -TRIAL before testing
        (my $version = $release->version) =~ s/-TRIAL$//;
        if( not version::is_lax($version) ) {
			push @problems, CPAN::Critic::Problem->new(
				description => "The version is the right format",
				version     => $version,
				);
			}
        }

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value  => \@problems,
		policy => $class,
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

Copyright © 2014-2021, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
