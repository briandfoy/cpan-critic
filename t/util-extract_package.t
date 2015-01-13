use Test::More 0.95;

use File::Spec::Functions;

my $class   = 'CPAN::Critic::Util';
my @methods = qw( extract_package );

subtest 'set up' => sub {
	use_ok( $class );
	can_ok( $class, @methods );
	};

subtest 'extract Util.pm' => sub {
	( my $file = $class ) =~ s|::|/|g;
	$file .= ".pm";

	my $rv = $class->extract_package( catfile( 'lib', $file ) );
	ok( $rv->is_success, 'Return value is successful' );
	is( $rv->value, $class );
	};

done_testing();
