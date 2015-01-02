use ExtUtils::MakeMaker;

require 5.012;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'	       => 'CPAN::Critic',
	'ABSTRACT_FROM' => 'lib/CPAN/Critic.pm',
	'VERSION_FROM' => 'lib/CPAN/Critic.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	clean  => { FILES    => q|CPAN-Critic-*| },

	);
