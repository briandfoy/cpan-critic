package CPAN::Critic::Policy::ExplicitModulesInPrereqs;
use v5.20;

use CPAN::Critic::Basics;

use List::Util qw(max);

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::ExplicitModulesInPrereqs - Check that all used modules show up in the prereqs

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

my %Ignores = map { $_, 1 } qw(
	strict warnings vars subs
	feature
	);

sub run {
	my( $class, @args ) = @_;

	my $files = CPAN::Critic::Util::FindFiles->get_module_files->value;

	my %found;
	foreach my $file ( @$files ) {
		my $namespaces = CPAN::Critic::Util::Lexer->get_namespaces( $file )->value;
		foreach my $elem ( @$namespaces ) {
			next unless defined $elem->[0];
			my( $namespace, $version ) = @$elem;

			my $previous_max = $found{ $namespace } // 0;

			my $max_version = max( $previous_max, version->new( $version ) );
			$found{ $namespace } = $max_version;
			}
		}

	delete @found{ keys %Ignores };

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;
	my $args = $rv->value;

	my $prereqs = $args->{PREREQ_PM};
	foreach my $key ( sort keys %$prereqs ) {
		$prereqs->{$key} = version->new( $prereqs->{$key} );
		}

	my @problems;
	foreach my $key ( keys %found ) {
		my $version = $found{$key} // 0;

		if( ! exists $prereqs->{$key} ) {
			push @problems, ReturnValue->error(
				value       => 0,
				description => "Missing module in prereqs ($key)",
				namespace   => $key,
				);
			}
		elsif( $prereqs->{$key} < $found{$key} ) {
			push @problems, ReturnValue->error(
				value       => 0,
				description => "Prereq version ($prereqs->{$key}) of module ($key) is less than declared version ($found{$key})",
				namespace   => $key,
				declared_version => $prereqs->{$key},
				required_version => $found{$key},
				);
			}
		}

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value       => \@problems,
		description => 'Required modules match declared prereqs',
		policy      => __PACKAGE__,
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
