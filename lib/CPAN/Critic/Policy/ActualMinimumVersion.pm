package CPAN::Critic::Policy::ActualMinimumVersion;
use 5.008;

use strict;
use warnings;

use ReturnValue;
use Perl::MinimumVersion::Fast;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::ActualMinimumVersion - Check that the declared minimum version matches the actual one match

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

	my $rv = CPAN::Critic::Util::MakefilePL->get_args;
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $modules = CPAN::Critic::Util::FindFiles->get_module_files->value;

	my @results;
	
	foreach my $module ( sort @$modules ) {
		no warnings 'uninitialized';
		my $p = Perl::MinimumVersion::Fast->new( $module );
		my $syntax_v   = $p->minimum_syntax_version;
		my $declared_v = $p->minimum_explicit_version;

		my $declared_v_default = $declared_v || version->new( '5.008' );

		if( ! defined $declared_v ) {
			push @results, ReturnValue->error(
				value            => 0,
				description      => "$module has no declared minimum perl version",
				syntax_version   => $syntax_v,
				);
			}
 
		if( $declared_v && $syntax_v > $declared_v_default ) {
			push @results, ReturnValue->error(
				value            => 0,
				description      => "$module declared perl version is too low! Declared: $declared_v < $syntax_v\n",
				declared_version => $declared_v,
				syntax_version   => $syntax_v,
				);
			}

		unless( exists $args->{MIN_PERL_VERSION} ) {
			push @results, ReturnValue->error(
				value            => 0,
				description      => "The build file doesn't specify MIN_PERL_VERSION",
				);
			}
		elsif( version->new( $args->{MIN_PERL_VERSION} ) < $syntax_v ) {
			push @results, ReturnValue->error(
				value            => 0,
				description      => "The build file MIN_PERL_VERSION is less than the syntax perl version",
				declared_version => $args->{MIN_PERL_VERSION},
				syntax_version   => $syntax_v,
				);
			}
		}

	my $method = @results ? 'error' : 'success';

	ReturnValue->$method(
		value  => \@results,
		policy => __PACKAGE__,
		);
	}


__PACKAGE__;