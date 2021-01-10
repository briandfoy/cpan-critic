package CPAN::Critic;
use v5.20;

use CPAN::Critic::Basics;

use Config::Tiny;
use Cwd;
use File::Find;
use File::Spec::Functions qw(catfile splitdir);

our $VERSION = '0.001_001';

=encoding utf8

=head1 NAME

CPAN::Critic - Critique a CPAN distribution

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub new {
	my( $class ) = shift;
	my $self = bless {}, $class;

	$self->_init( @_ );

	$self;
	}

sub _init {
	my( $self, %args ) = @_;

	if( $self->config_file_exists ) {
		$self->{config} = $self->load_config;
		}

	my $result = $self->_load_default_policies;
	if( $result->is_error ) {


		}

	my %namespaces = $result->value->%*;
	my @namespaces = keys %namespaces;

	$self->{config}{policies} = \@namespaces;

	$self;
	}

sub _default_config    { 'cpan-critic.ini' }

=item config_file_exists

=cut

sub config_file_exists { -e $_[0]->_default_config }

=item load_config

=cut

sub load_config {
	my( $self ) = @_;

	my $file = $self->_default_config;

	my $config = Config::Tiny->new->read( $file );
	}

=item disabled_policies

=cut

sub disabled_policies {
	my( $self ) = @_;

	my @sections = grep {
		s/\A\s*-//
		}
		keys $self->config->%*;
	}

sub _load_default_policies {
	my( $self ) = @_;

	my %Results;
	my $errors = 0;

	POLICY: foreach my $namespace ( $self->_find_policies ) {
		unless( $namespace =~ m/\A [A-Z0-9_]+ (::[A-Z0-9_]+)+ \z/xi ) {
			$Results{_errors}{$namespace} = "Bad namespace [$namespace]";
			$Results{$namespace} = 0;
			next POLICY;
			}

		unless( eval "require $namespace; 1" ) {
			say "Error with $namespace: $@";
			$Results{_errors}{$namespace} = "Problem loading $namespace: $@";
			$Results{$namespace} = 0;
			$errors++;
			next POLICY;
			}

		$Results{$namespace}++;
		}

	my $method = $errors ? 'error' : 'success';

	ReturnValue->$method(
		value => \%Results,
		);
	}

sub _find_policies {
	my( $self ) = @_;

	my @dirs = grep { -d } map {
		File::Spec->catfile( $_, qw(CPAN Critic Policy) )
		} @INC;

	my @namespaces;
	foreach my $dir ( @dirs ) {
		my @files;
		my $wanted = sub {
			push @files,
				File::Spec::Functions::canonpath( $File::Find::name ) if m/\.pm\z/
				};
		find( $wanted, $dir );

		push @namespaces,
			grep {
				eval "use $_; 1"
					&&
				$_->can( 'run' );
				}
			map {
				my $rel = File::Spec->abs2rel( $_, $dir );
				$rel =~ s/\.pm\z//;
				my @parts = splitdir( $rel );
				join '::', qw(CPAN Critic Policy), @parts;
				}
			@files;
		#say join "\n\t", "Found", @files;
		}

	@namespaces;
	}

=item config( CONFIG )

=cut

sub config {
	my( $self ) = shift;

	$self->{config} = $_[0] if @_;

	$self->{config}
	}

=item critique( DIRECTORY )

Apply all the policies to the given directory.

=cut

sub critique {
	my( $self, $dir ) = @_;

	defined $dir or return ReturnValue->error(
		value       => undef,
		description => "No directory argument: $!",
		tag         => 'system',
		);

	my $starting_dir = cwd();
	chdir $dir or return ReturnValue->error(
		value       => undef,
		description => "Could not change to directory [$dir]: $!",
		tag         => 'system',
		);

	my @results;
	foreach my $policy ( sort $self->policies ) {
		chdir $dir;
		my $result = $self->apply( $policy );

		push @results, $result;
		}

	chdir $starting_dir or return ReturnValue->error(
		value       => undef,
		description => "Could not change back to original directory [$dir]: $!",
		tag         => 'system',
		);

	return ReturnValue->success(
		value => \@results,
		);
	}

=item apply( POLICY )

=cut

sub apply {
	my( $self, $policy ) = @_;

	$policy->run();
	}

=item policies

Return a list of policy objects

=cut

sub policies {
	my( $self ) = @_;

	my @policies = grep { ! /\A_/ } $self->config->{policies}->@*;

	wantarray
		?
		@policies
			:
		[ @policies ]
		;
	}

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/cpan-critic/

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2014-2021, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
