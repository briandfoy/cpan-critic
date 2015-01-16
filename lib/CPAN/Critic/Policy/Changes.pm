package CPAN::Critic::Policy::Changes;
use v5.10;

use CPAN::Critic::Basics;

use CPAN::Changes;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Changes - Check the Changes file

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my $FILE = 'Changes';

sub run {
	my( $class, @args ) = @_;

    my $changes = eval { CPAN::Changes->load( $FILE ) };
	my $at = $@;

	return ReturnValue->error(
		value  => $at,
		description => "Parsed the Changes file",
		policy => __PACKAGE__,
		) if $at;

    my @releases = $changes->releases;
	return ReturnValue->error(
		value       => 0,
		description => "The Changes file has at least one release",
		policy      => __PACKAGE__,
		) unless @releases;

	my @results;
    foreach my $release ( @releases ) {
        if ( !defined $release->date || $_->release eq ''  ) {
			push @results, ReturnValue->error(
				value       => 0,
				description => "No date for version " . $release->version,
				);
        	}

		unless( $release->{_parsed_date} =~ m/\A${CPAN::Changes::W3CDTF_REGEX}\z/ ) {
			push @results, ReturnValue->error(
				value       => 0,
				description => "The date for version " . $release->version . " is the right format",
				parsed_date => $release->{_parsed_date},
				);
			}

        # strip off -TRIAL before testing
        (my $version = $release->version) =~ s/-TRIAL$//;
        if( not version::is_lax($version) ) {
			push @results, ReturnValue->error(
				value       => 0,
				description => "The version is the right format",
				version     => $version,
				);
			}
        }

	my $method = @results ? 'error' : 'success';

	ReturnValue->$method(
		value  => \@results,
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

Copyright © 2014-2015, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the same terms as Perl itself.

=cut

__PACKAGE__;
