package CPAN::Critic::Policy::Pod::ABSTRACT;
use v5.20;

use CPAN::Critic::Basics;

use ExtUtils::MM_Unix;

=encoding utf8

=head1 NAME

CPAN::Critic::Policy::Pod::ABSTRACT - Every module has an abstract

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item run

=cut

sub run {
	my( $class, @args ) = @_;
	my @problems;

	my $rv = CPAN::Critic::Util::FindFiles->get_module_files;
	return $rv unless $rv->is_success;

	my $files = $rv->value;

	FILE: foreach my $file ( @$files ) {
		my $rv = CPAN::Critic::Util->extract_package( $file );

		if( $rv->is_error ) {
			push @problems, $rv->value->@*;
			next FILE;
			}

		no warnings 'uninitialized';
		my $abstract = eval {
			my $object = bless {
				DISTNAME => $rv->value,
				}, 'ExtUtils::MM_Unix';

			$object->parse_abstract( $file )
			};

		my( $value, $description ) = do {
			if( ! -e $file ) {
				( 0, "$file file is there" );
				}
			elsif( ! -r $file ) {
				( 0, "$file file is readable" );
				}
			elsif( ! $abstract ) {
				( 0, "$file has an abstract" );
				}
			elsif( $abstract =~ m/This/ ) {
				( 0, "Abstract doesn't have boilerplate" );
				}
			else {
				( $abstract, "The abstract is okay in $file" );
				}
			};

		push @problems, CPAN::Critic::Problem->new(
			description => $description,
			file        => $file,
			) unless $value;
		}

	my $method = @problems ? 'error' : 'success';

	ReturnValue->$method(
		value       => \@problems,
		description => 'Some files had abstract errors',
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

Copyright © 2014-2025, brian d foy <bdfoy@cpan.org>. All rights reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
