package CPAN::Critic::Policy::ABSTRACT;
use v5.10;
use strict;
use warnings;

use ReturnValue;
use ExtUtils::MM_Unix;
use CPAN::Critic::Util;
use CPAN::Critic::Util::FindFiles;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::ABSTRACT - Every module has an abstract

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub run {
	my( $class, @args ) = @_;

	my $rv = CPAN::Critic::Util::FindFiles->find_by_extension( 'pm' );
	return $rv unless $rv->is_success;

	my $files = $rv->value;

	my @results;
	my $errors;
	
	FILE: foreach my $file ( @$files ) {
		my $rv = CPAN::Critic::Util->extract_package( $file );
		
		if( $rv->is_error ) {
			push @results, $rv;
			next FILE;
			}

		no warnings 'uninitialized';
		my $abstract = eval {
			my $object = bless {
				DISTNAME => $rv->value,
				}, 'ExtUtils::MM_Unix';

			$object->parse_abstract( $file )
			};

		my( $value, $description, $tag ) = do {
			if( ! -e $file ) {
				( 0, "$file file is there", 'found' );
				}
			elsif( ! -r $file ) {
				( 0, "$file file is readable", 'readable' );
				}
			elsif( ! $abstract ) {
				( 0, "$file has an abstract", '???' );
				}
			elsif( $abstract =~ m/This/ ) {
				( 0, "Abstract doesn't have boilerplate", '???' );
				}
			else {
				( $abstract, "The abstract is okay in $file", '???' );
				}
			};
			
		my $method = $value ? 'success' : 'error';
		
		push @results, 	ReturnValue->$method(
			value       => $value,
			description => $description,
			tag         => $tag,
			file        => $file,
			policy      => __PACKAGE__,
			);
			
		$errors++ if $results[-1]->is_error;
		}

	my $method = $errors ? 'error' : 'success';
	
	ReturnValue->$method(
		value       => \@results,
		description => 'Some files had abstract errors',
		policy      => __PACKAGE__,
		);	
	}

__PACKAGE__;
