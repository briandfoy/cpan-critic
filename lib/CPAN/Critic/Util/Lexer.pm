package CPAN::Critic::Util::Lexer;
use 5.010;

use CPAN::Critic::Basics;

use Compiler::Lexer 0.19;

=encoding utf8

=head1 NAME

CPAN::Critic::Util::Lexer - Extract things from Perl files

=head1 SYNOPSIS

	use CPAN::Critic;

=head1 DESCRIPTION

=over 4

=item new

=cut


sub get_namespaces {
	my( $class, $file ) = @_;

	my $tokens = $class->tokenize( $file );

	my @found;

	for( my $i = 0; $i <= $#$tokens; $i++ ) {
		next unless is_use( $tokens->[$i] );

		my $j = $i;

		my( $namespace, $version );
		while( ++$j ) {
			my $name = $tokens->[$j]->name;
			$namespace .= $tokens->[$j]->data if(
				$name eq 'UsedName' ||
				$name eq 'Namespace' || $name eq 'NamespaceResolver'
				);

			$version = $tokens->[$j]->data if is_num( $tokens->[$j] );
			last if $tokens->[$j]->name eq 'SemiColon'
			}

		push @found, [ $namespace, $version ];

		$i = $j;
		}

	ReturnValue->success(
		value => \@found,
		);
	}


sub tokenize {
	my( $class, $file ) = @_;

	my $source = do { local( @ARGV, $/ ) = $file; <> };

    my $lexer = Compiler::Lexer->new( $file );
    my $tokens = $lexer->tokenize( $source );
	}


=pod

PATTERNS

UseDecl Namespace (NamespaceResolver Namespace)+ (Double)+
	RegList RegDelim RegExp+ RegDelim
	LeftParenthesis RawString (Comma RawString)+ RightParenthesis

	SemiColon

=cut

sub is_use {
	$_[0]->name eq 'UseDecl' || $_[0]->name eq 'RequireDecl'
	}

sub is_num {
	$_[0]->name eq 'Int' || $_[0]->name eq 'Double'
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

1;
