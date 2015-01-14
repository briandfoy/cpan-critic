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

use List::Util qw(max);
sub Perl::MinimumVersion::Fast::_build_minimum_explicit_version {
    my ($self, $tokens) = @_;
    my @tokens = map { @$_ } @{$tokens};

    my $explicit_version;
    for my $i (0..@tokens-1) {
        if ($tokens[$i]->{name} eq 'UseDecl' || $tokens[$i]->{name} eq 'RequireDecl') {
            if (@$tokens >= $i+1) {
                my $next_token = $tokens[$i+1];
                if ($next_token->{name} eq 'Double' || $next_token->{name} eq 'VersionString' ) {
                    $explicit_version = max($explicit_version // 0, version->new($next_token->{data}));
                }
            }
        }
    }
    return $explicit_version;
}


sub run {
	my( $class, @args ) = @_;

	my $rv = CPAN::Critic::Util::MakefilePL->check_if_modulino();
	return $rv unless $rv->is_success;

	my $args = $rv->value;

	my $modules = CPAN::Critic::Util::FindFiles->get_module_files->value;
	
	foreach my $module ( @$modules ) {
		no warnings 'uninitialized';
		my $p = Perl::MinimumVersion::Fast->new( $module );
		my $syntax_v   = $p->minimum_syntax_version;
		my $declared_v = $p->minimum_explicit_version || version->new( '5.008' );

		if( $syntax_v > $declared_v ) {
			print "$module declared version is too low! Declared: $declared_v < $syntax_v\n";
			}


		}

=pod

	no warnings 'uninitialized';

	my( $value, $description, $tag ) = do {
		if( ! exists $args->{MIN_PERL_VERSION} ) {
			( 0, 'MIN_PERL_VERSION is in the data structure', 'found' );
			}
		else {
			( $args->{MIN_PERL_VERSION}, 'The minimum version is there', '???' );
			}
		};

	my $method = $value ? 'success' : 'error';

	ReturnValue->$method(
		value       => $value,
		description => $description,
		tag         => $tag,
		policy      => __PACKAGE__,
		);

=cut

	ReturnValue->success( value => 1 );
	}


__PACKAGE__;
