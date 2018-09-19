package CPAN::Critic::Policy::BuildFile::ActualMinimumVersion;
use v5.10;

use CPAN::Critic::Basics;

use Perl::MinimumVersion::Fast;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::BuildFile::ActualMinimumVersion - Check that the declared minimum version matches the actual one match

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

{
no warnings qw(redefine);
use List::Util qw(max);
sub Perl::MinimumVersion::Fast::_build_minimum_explicit_version {
    my ($self, $tokens) = @_;
    my @tokens = map { @$_ } @{$tokens};

    my $explicit_version;
    for my $i (0..@tokens-1) {
        if ($tokens[$i]->{name} eq 'UseDecl' || $tokens[$i]->{name} eq 'RequireDecl') {
			if (@tokens >= $i+1) {
                my $next_token = $tokens[$i+1];
                if ($next_token->{name} eq 'Double' || $next_token->{name} eq 'VersionString' ) {
                    $explicit_version = max($explicit_version // 0, version->new($next_token->{data}));
                }
            }
        }
    }
    return $explicit_version;
}
}

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $modules = CPAN::Critic::Util::FindFiles->get_module_files->value;

	my @syntax_versions;
	foreach my $module ( sort @$modules ) {
		no warnings 'uninitialized';
		my $p = Perl::MinimumVersion::Fast->new( $module );

		my $syntax_v   = $p->minimum_syntax_version;
		push @syntax_versions, $syntax_v;

		my $declared_v = $p->minimum_explicit_version;

		my $declared_v_default = $declared_v || version->new( '5.008' );

		if( ! defined $declared_v ) {
			push @problems, CPAN::Critic::Problem->new(
				value            => 0,
				description      => "$module has no declared minimum perl version",
				syntax_version   => $syntax_v,
				);
			}

		if( $declared_v && $syntax_v > $declared_v_default ) {
			push @problems, CPAN::Critic::Problem->new(
				value            => 0,
				description      => "$module declared perl version is too low! Declared: $declared_v < $syntax_v\n",
				declared_version => $declared_v,
				syntax_version   => $syntax_v,
				);
			}

		unless( exists $args->{MIN_PERL_VERSION} ) {
			push @problems, CPAN::Critic::Problem->new(
				value            => 0,
				description      => "The build file doesn't specify MIN_PERL_VERSION",
				);
			}
		elsif( version->new( $args->{MIN_PERL_VERSION} ) < $syntax_v ) {
			push @problems, CPAN::Critic::Problem->new(
				value            => 0,
				description      => "The build file MIN_PERL_VERSION is less than the syntax perl version",
				declared_version => $args->{MIN_PERL_VERSION},
				syntax_version   => $syntax_v,
				);
			}

		}

	my $max_syntax_version = max( @syntax_versions );

	if( version->new( $args->{MIN_PERL_VERSION} ) > $max_syntax_version ) {
		push @problems, CPAN::Critic::Problem->new(
			description      => "The build file MIN_PERL_VERSION [$args->{MIN_PERL_VERSION}] is greater than the maximum syntax perl version [$max_syntax_version]",
			declared_version => $args->{MIN_PERL_VERSION},
			syntax_version   => $max_syntax_version,
			);
		}

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value  => \@problems,
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

Copyright © 2014-2018, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
