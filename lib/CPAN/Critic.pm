use v5.20;
use feature qw(postderef);
no warnings qw();

package CPAN::Critic;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

use ReturnValue;

$VERSION = '0.10_01';

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
	
	$args{config} //= $self->_default_config;
	
	my $result = $self->_load_default_policies;
	
	$self->config( $self->_load_config );
	
	# remove policies by config
	
	$self;
	}

sub _load_default_policies {
	my( $self ) = @_;

	my %Results;
	
	POLICY: foreach $namespace ( $self->_find_policies ) {
		unless( $namespace =~ m/ [A-Z0-9_]+ (::[A-Z0-9_]+)+ / ) {
			$Result{_errors}{$namespace} = "Bad policy $namespace: Skipping";
			$Result{$namespace} = 0;
			next POLICY;
			}
			
		unless( eval "require $namespace; 1" ) {
			$Result{_errors}{$namespace} = "Problem loading $namespace: $@";
			$Result{$namespace} = 0;
			next POLICY;
			}
			
		$Result{$namespace}++;
		}
		
	ReturnValue->success(
		value => \%Results,
		);
	}

sub _find_policies {
	my( $self ) = @_;

	
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

	my $starting_dir = cwd();
	chdir $dir or return ReturnValue->error(
		value       => undef,
		description => "Could not change to directory [$dir]: $!",
		tag         => 'system',
		);
	foreach my $policy ( $self->policies ) {
		my $result = $self->apply( $policy );
		
		push @results, $result;
		}

	chdir $starting_dir or return ReturnValue->error(
		value       => undef,
		description => "Could not change back to original directory [$dir]: $!",
		tag         => 'system',
		);
		
	return ReturnValue->success(
		value => \@results;
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
	
	wantarray ? $self->config->{policies}->@* ? [ $self->config->{policies}->@* ];
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

Copyright (c) 2015, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
