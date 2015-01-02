package CPAN::Critic::Config;

use strict;
use warnings;

use List::MoreUtils qw(any none apply);
use Scalar::Util qw(blessed);

use Perl::Critic::Exception::AggregateConfiguration;
use Perl::Critic::Exception::Configuration;
use Perl::Critic::Exception::Configuration::Option::Global::ParameterValue;
use Perl::Critic::Exception::Fatal::Internal qw{ throw_internal };
use Perl::Critic::PolicyFactory;
use Perl::Critic::Theme qw( $RULE_INVALID_CHARACTER_REGEX cook_rule );
use Perl::Critic::UserProfile qw();
use Perl::Critic::Utils qw{
    :booleans :characters :severities :internal_lookup :classification
    :data_conversion
};
use Perl::Critic::Utils::Constants qw<
    :profile_strictness
    $_MODULE_VERSION_TERM_ANSICOLOR
>;
use Perl::Critic::Utils::DataConversion qw< boolean_to_number dor >;

our $VERSION = '1.123';

Readonly::Scalar my $SINGLE_POLICY_CONFIG_KEY => 'single-policy';

sub new {

    my ( $class, %args ) = @_;
    my $self = bless {}, $class;
    $self->_init( %args );
    return $self;
}

sub _init {
    my ( $self, %args ) = @_;

    # -top or -theme imply that -severity is 1, unless it is already defined
    if ( defined $args{-top} || defined $args{-theme} ) {
        $args{-severity} ||= $SEVERITY_LOWEST;
    }

    my $errors = Perl::Critic::Exception::AggregateConfiguration->new();

    # Construct the UserProfile to get default options.
    my $profile_source = $args{-profile}; # Can be file path or data struct
    my $profile = Perl::Critic::UserProfile->new( -profile => $profile_source );
    my $options_processor = $profile->options_processor();
    $self->{_profile} = $profile;

    $self->_validate_and_save_profile_strictness(
        $args{'-profile-strictness'},
        $errors,
    );

    # If given, these options should always have a true value.
    $self->_validate_and_save_regex(
        'include', $args{-include}, $options_processor->include(), $errors
    );
    $self->_validate_and_save_regex(
        'exclude', $args{-exclude}, $options_processor->exclude(), $errors
    );
    $self->_validate_and_save_regex(
        $SINGLE_POLICY_CONFIG_KEY,
        $args{ qq/-$SINGLE_POLICY_CONFIG_KEY/ },
        $options_processor->single_policy(),
        $errors,
    );
    $self->_validate_and_save_color_severity(
        'color_severity_highest', $args{'-color-severity-highest'},
        $options_processor->color_severity_highest(), $errors
    );
    $self->_validate_and_save_color_severity(
        'color_severity_high', $args{'-color-severity-high'},
        $options_processor->color_severity_high(), $errors
    );
    $self->_validate_and_save_color_severity(
        'color_severity_medium', $args{'-color-severity-medium'},
        $options_processor->color_severity_medium(), $errors
    );
    $self->_validate_and_save_color_severity(
        'color_severity_low', $args{'-color-severity-low'},
        $options_processor->color_severity_low(), $errors
    );
    $self->_validate_and_save_color_severity(
        'color_severity_lowest', $args{'-color-severity-lowest'},
        $options_processor->color_severity_lowest(), $errors
    );

    $self->_validate_and_save_verbosity($args{-verbose}, $errors);
    $self->_validate_and_save_severity($args{-severity}, $errors);
    $self->_validate_and_save_top($args{-top}, $errors);
    $self->_validate_and_save_theme($args{-theme}, $errors);
    $self->_validate_and_save_pager($args{-pager}, $errors);
    $self->_validate_and_save_program_extensions(
        $args{'-program-extensions'}, $errors);

    # If given, these options can be true or false (but defined)
    # We normalize these to numeric values by multiplying them by 1;
    $self->{_force} = boolean_to_number( dor( $args{-force}, $options_processor->force() ) );
    $self->{_only}  = boolean_to_number( dor( $args{-only},  $options_processor->only()  ) );
    $self->{_color} = boolean_to_number( dor( $args{-color}, $options_processor->color() ) );
    $self->{_unsafe_allowed} =
        boolean_to_number(
            dor( $args{'-allow-unsafe'}, $options_processor->allow_unsafe()
        ) );
    $self->{_criticism_fatal} =
        boolean_to_number(
            dor( $args{'-criticism-fatal'}, $options_processor->criticism_fatal() )
        );


    # Construct a Factory with the Profile
    my $factory =
        Perl::Critic::PolicyFactory->new(
            -profile              => $profile,
            -errors               => $errors,
            '-profile-strictness' => $self->profile_strictness(),
        );
    $self->{_factory} = $factory;

    # Initialize internal storage for Policies
    $self->{_all_policies_enabled_or_not} = [];
    $self->{_policies} = [];

    # "NONE" means don't load any policies
    if ( not defined $profile_source or $profile_source ne 'NONE' ) {
        # Heavy lifting here...
        $self->_load_policies($errors);
    }

    if ( $errors->has_exceptions() ) {
        $errors->rethrow();
    }

    return $self;
}

sub add_policy {

    my ( $self, %args ) = @_;

    if ( not $args{-policy} ) {
        throw_internal q{The -policy argument is required};
    }

    my $policy  = $args{-policy};

    # If the -policy is already a blessed object, then just add it directly.
    if ( blessed $policy ) {
        $self->_add_policy_if_enabled($policy);
        return $self;
    }

    # NOTE: The "-config" option is supported for backward compatibility.
    my $params = $args{-params} || $args{-config};

    my $factory       = $self->{_factory};
    my $policy_object =
        $factory->create_policy(-name=>$policy, -params=>$params);
    $self->_add_policy_if_enabled($policy_object);

    return $self;
}

sub _add_policy_if_enabled {
    my ( $self, $policy_object ) = @_;

    my $config = $policy_object->__get_config()
        or throw_internal
            q{Policy was not set up properly because it does not have }
                . q{a value for its config attribute.};

    push @{ $self->{_all_policies_enabled_or_not} }, $policy_object;
    if ( $policy_object->initialize_if_enabled( $config ) ) {
        $policy_object->__set_enabled($TRUE);
        push @{ $self->{_policies} }, $policy_object;
    }
    else {
        $policy_object->__set_enabled($FALSE);
    }

    return;
}

sub _load_policies {

    my ( $self, $errors ) = @_;
    my $factory  = $self->{_factory};
    my @policies = $factory->create_all_policies( $errors );

    return if $errors->has_exceptions();

    for my $policy ( @policies ) {

        # If -single-policy is true, only load policies that match it
        if ( $self->single_policy() ) {
            if ( $self->_policy_is_single_policy( $policy ) ) {
                $self->add_policy( -policy => $policy );
            }
            next;
        }

        # Always exclude unsafe policies, unless instructed not to
        next if not ( $policy->is_safe() or $self->unsafe_allowed() );

        # To load, or not to load -- that is the question.
        my $load_me = $self->only() ? $FALSE : $TRUE;

        ## no critic (ProhibitPostfixControls)
        $load_me = $FALSE if     $self->_policy_is_disabled( $policy );
        $load_me = $TRUE  if     $self->_policy_is_enabled( $policy );
        $load_me = $FALSE if     $self->_policy_is_unimportant( $policy );
        $load_me = $FALSE if not $self->_policy_is_thematic( $policy );
        $load_me = $TRUE  if     $self->_policy_is_included( $policy );
        $load_me = $FALSE if     $self->_policy_is_excluded( $policy );


        next if not $load_me;
        $self->add_policy( -policy => $policy );
    }

    # When using -single-policy, only one policy should ever be loaded.
    if ($self->single_policy() && scalar $self->policies() != 1) {
        $self->_add_single_policy_exception_to($errors);
    }

    return;
}

sub _policy_is_disabled {
    my ($self, $policy) = @_;
    my $profile = $self->_profile();
    return $profile->policy_is_disabled( $policy );
}

sub _policy_is_enabled {
    my ($self, $policy) = @_;
    my $profile = $self->_profile();
    return $profile->policy_is_enabled( $policy );
}

sub _policy_is_thematic {
    my ($self, $policy) = @_;
    my $theme = $self->theme();
    return $theme->policy_is_thematic( -policy => $policy );
}

sub _policy_is_unimportant {
    my ($self, $policy) = @_;
    my $policy_severity = $policy->get_severity();
    my $min_severity    = $self->{_severity};
    return $policy_severity < $min_severity;
}

sub _policy_is_included {
    my ($self, $policy) = @_;
    my $policy_long_name = ref $policy;
    my @inclusions  = $self->include();
    return any { $policy_long_name =~ m/$_/ixms } @inclusions;
}

sub _policy_is_excluded {
    my ($self, $policy) = @_;
    my $policy_long_name = ref $policy;
    my @exclusions  = $self->exclude();
    return any { $policy_long_name =~ m/$_/ixms } @exclusions;
}


sub _policy_is_single_policy {
    my ($self, $policy) = @_;

    my @patterns = $self->single_policy();
    return if not @patterns;

    my $policy_long_name = ref $policy;
    return any { $policy_long_name =~ m/$_/ixms } @patterns;
}

sub _new_global_value_exception {
    my ($self, @args) = @_;

    return
        Perl::Critic::Exception::Configuration::Option::Global::ParameterValue
            ->new(@args);
}

sub _add_single_policy_exception_to {
    my ($self, $errors) = @_;

    my $message_suffix = $EMPTY;
    my $patterns = join q{", "}, $self->single_policy();

    if (scalar $self->policies() == 0) {
        $message_suffix =
            q{did not match any policies (in combination with }
                . q{other policy restrictions).};
    }
    else {
        $message_suffix  = qq{matched multiple policies:\n\t};
        $message_suffix .= join qq{,\n\t}, apply { chomp } sort $self->policies();
    }

    $errors->add_exception(
        $self->_new_global_value_exception(
            option_name     => $SINGLE_POLICY_CONFIG_KEY,
            option_value    => $patterns,
            message_suffix  => $message_suffix,
        )
    );

    return;
}


sub _validate_and_save_regex {
    my ($self, $option_name, $args_value, $default_value, $errors) = @_;

    my $full_option_name;
    my $source;
    my @regexes;

    if ($args_value) {
        $full_option_name = "-$option_name";

        if (ref $args_value) {
            @regexes = @{ $args_value };
        }
        else {
            @regexes = ( $args_value );
        }
    }

    if (not @regexes) {
        $full_option_name = $option_name;
        $source = $self->_profile()->source();

        if (ref $default_value) {
            @regexes = @{ $default_value };
        }
        elsif ($default_value) {
            @regexes = ( $default_value );
        }
    }

    my $found_errors;
    foreach my $regex (@regexes) {
        eval { qr/$regex/ixms }
            or do {
                my $cleaned_error = $EVAL_ERROR || '<unknown reason>';
                $cleaned_error =~
                    s/ [ ] at [ ] .* Config [.] pm [ ] line [ ] \d+ [.] \n? \z/./xms;

                $errors->add_exception(
                    $self->_new_global_value_exception(
                        option_name     => $option_name,
                        option_value    => $regex,
                        source          => $source,
                        message_suffix  => qq{is not valid: $cleaned_error},
                    )
                );

                $found_errors = 1;
            }
    }

    if (not $found_errors) {
        my $option_key = $option_name;
        $option_key =~ s/ - /_/xmsg;

        $self->{"_$option_key"} = \@regexes;
    }

    return;
}

sub _validate_and_save_profile_strictness {
    my ($self, $args_value, $errors) = @_;

    my $option_name;
    my $source;
    my $profile_strictness;

    if ($args_value) {
        $option_name = '-profile-strictness';
        $profile_strictness = $args_value;
    }
    else {
        $option_name = 'profile-strictness';

        my $profile = $self->_profile();
        $source = $profile->source();
        $profile_strictness = $profile->options_processor()->profile_strictness();
    }

    if ( not $PROFILE_STRICTNESSES{$profile_strictness} ) {
        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $option_name,
                option_value    => $profile_strictness,
                source          => $source,
                message_suffix  => q{is not one of "}
                    . join ( q{", "}, (sort keys %PROFILE_STRICTNESSES) )
                    . q{".},
            )
        );

        $profile_strictness = $PROFILE_STRICTNESS_FATAL;
    }

    $self->{_profile_strictness} = $profile_strictness;

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_verbosity {
    my ($self, $args_value, $errors) = @_;

    my $option_name;
    my $source;
    my $verbosity;

    if ($args_value) {
        $option_name = '-verbose';
        $verbosity = $args_value;
    }
    else {
        $option_name = 'verbose';

        my $profile = $self->_profile();
        $source = $profile->source();
        $verbosity = $profile->options_processor()->verbose();
    }

    if (
            is_integer($verbosity)
        and not is_valid_numeric_verbosity($verbosity)
    ) {
        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $option_name,
                option_value    => $verbosity,
                source          => $source,
                message_suffix  =>
                    'is not the number of one of the pre-defined verbosity formats.',
            )
        );
    }
    else {
        $self->{_verbose} = $verbosity;
    }

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_severity {
    my ($self, $args_value, $errors) = @_;

    my $option_name;
    my $source;
    my $severity;

    if ($args_value) {
        $option_name = '-severity';
        $severity = $args_value;
    }
    else {
        $option_name = 'severity';

        my $profile = $self->_profile();
        $source = $profile->source();
        $severity = $profile->options_processor()->severity();
    }

    if ( is_integer($severity) ) {
        if (
            $severity >= $SEVERITY_LOWEST and $severity <= $SEVERITY_HIGHEST
        ) {
            $self->{_severity} = $severity;
        }
        else {
            $errors->add_exception(
                $self->_new_global_value_exception(
                    option_name     => $option_name,
                    option_value    => $severity,
                    source          => $source,
                    message_suffix  =>
                        "is not between $SEVERITY_LOWEST (low) and $SEVERITY_HIGHEST (high).",
                )
            );
        }
    }
    elsif ( not any { $_ eq lc $severity } @SEVERITY_NAMES ) {
        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $option_name,
                option_value    => $severity,
                source          => $source,
                message_suffix  =>
                    q{is not one of the valid severity names: "}
                        . join (q{", "}, @SEVERITY_NAMES)
                        . q{".},
            )
        );
    }
    else {
        $self->{_severity} = severity_to_number($severity);
    }

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_top {
    my ($self, $args_value, $errors) = @_;

    my $option_name;
    my $source;
    my $top;

    if (defined $args_value and $args_value ne q{}) {
        $option_name = '-top';
        $top = $args_value;
    }
    else {
        $option_name = 'top';

        my $profile = $self->_profile();
        $source = $profile->source();
        $top = $profile->options_processor()->top();
    }

    if ( is_integer($top) and $top >= 0 ) {
        $self->{_top} = $top;
    }
    else {
        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $option_name,
                option_value    => $top,
                source          => $source,
                message_suffix  => q{is not a non-negative integer.},
            )
        );
    }

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_theme {
    my ($self, $args_value, $errors) = @_;

    my $option_name;
    my $source;
    my $theme_rule;

    if ($args_value) {
        $option_name = '-theme';
        $theme_rule = $args_value;
    }
    else {
        $option_name = 'theme';

        my $profile = $self->_profile();
        $source = $profile->source();
        $theme_rule = $profile->options_processor()->theme();
    }

    if ( $theme_rule =~ m/$RULE_INVALID_CHARACTER_REGEX/xms ) {
        my $bad_character = $1;

        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $option_name,
                option_value    => $theme_rule,
                source          => $source,
                message_suffix  =>
                    qq{contains an illegal character ("$bad_character").},
            )
        );
    }
    else {
        my $rule_as_code = cook_rule($theme_rule);
        $rule_as_code =~ s/ [\w\d]+ / 1 /gxms;

        # eval of an empty string does not reset $@ in Perl 5.6.
        local $EVAL_ERROR = $EMPTY;
        eval $rule_as_code; ## no critic (ProhibitStringyEval, RequireCheckingReturnValueOfEval)

        if ($EVAL_ERROR) {
            $errors->add_exception(
                $self->_new_global_value_exception(
                    option_name     => $option_name,
                    option_value    => $theme_rule,
                    source          => $source,
                    message_suffix  => q{is not syntactically valid.},
                )
            );
        }
        else {
            eval {
                $self->{_theme} =
                    Perl::Critic::Theme->new( -rule => $theme_rule );
            }
                or do {
                    $errors->add_exception_or_rethrow( $EVAL_ERROR );
                };
        }
    }

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_pager {
    my ($self, $args_value, $errors) = @_;

    my $pager;
    if ( $args_value ) {
        $pager = defined $args_value ? $args_value : $EMPTY;
    }
    elsif ( $ENV{PERLCRITIC_PAGER} ) {
        $pager = $ENV{PERLCRITIC_PAGER};
    }
    else {
        my $profile = $self->_profile();
        $pager = $profile->options_processor()->pager();
    }

    if ($pager eq '$PAGER') {   ## no critic (RequireInterpolationOfMetachars)
        $pager = $ENV{PAGER};
    }
    $pager ||= $EMPTY;

    $self->{_pager} = $pager;

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_color_severity {
    my ($self, $option_name, $args_value, $default_value, $errors) = @_;

    my $source;
    my $color_severity;
    my $full_option_name;

    if (defined $args_value) {
        $full_option_name = "-$option_name";
        $color_severity = lc $args_value;
    }
    else {
        $full_option_name = $option_name;
        $source = $self->_profile()->source();
        $color_severity = lc $default_value;
    }
    $color_severity =~ s/ \s+ / /xmsg;
    $color_severity =~ s/ \A\s+ //xms;
    $color_severity =~ s/ \s+\z //xms;
    $full_option_name =~ s/ _ /-/xmsg;

    # Should we really be validating this?
    my $found_errors;
    if (
        eval {
            require Term::ANSIColor;
            Term::ANSIColor->VERSION( $_MODULE_VERSION_TERM_ANSICOLOR );
            1;
        }
    ) {
        $found_errors =
            not Term::ANSIColor::colorvalid( words_from_string($color_severity) );
    }

    # If we do not have Term::ANSIColor we can not validate, but we store the
    # values anyway for the benefit of Perl::Critic::ProfilePrototype.

    if ($found_errors) {
        $errors->add_exception(
            $self->_new_global_value_exception(
                option_name     => $full_option_name,
                option_value    => $color_severity,
                source          => $source,
                message_suffix  => 'is not valid.',
            )
        );
    }
    else {
        my $option_key = $option_name;
        $option_key =~ s/ - /_/xmsg;

        $self->{"_$option_key"} = $color_severity;
    }

    return;
}

#-----------------------------------------------------------------------------

sub _validate_and_save_program_extensions {
    my ($self, $args_value, $errors) = @_;

    delete $self->{_program_extensions_as_regexes};

    my $extension_list = q{ARRAY} eq ref $args_value ?
        [map {words_from_string($_)} @{ $args_value }] :
        $self->_profile()->options_processor()->program_extensions();

    my %program_extensions = hashify( @{ $extension_list } );

    $self->{_program_extensions} = [keys %program_extensions];

    return;

}

#-----------------------------------------------------------------------------
# Begin ACCESSSOR methods

sub _profile {
    my ($self) = @_;
    return $self->{_profile};
}

#-----------------------------------------------------------------------------

sub all_policies_enabled_or_not {
    my ($self) = @_;
    return @{ $self->{_all_policies_enabled_or_not} };
}

#-----------------------------------------------------------------------------

sub policies {
    my ($self) = @_;
    return @{ $self->{_policies} };
}

#-----------------------------------------------------------------------------

sub exclude {
    my ($self) = @_;
    return @{ $self->{_exclude} };
}

#-----------------------------------------------------------------------------

sub force {
    my ($self) = @_;
    return $self->{_force};
}

#-----------------------------------------------------------------------------

sub include {
    my ($self) = @_;
    return @{ $self->{_include} };
}

#-----------------------------------------------------------------------------

sub only {
    my ($self) = @_;
    return $self->{_only};
}

#-----------------------------------------------------------------------------

sub profile_strictness {
    my ($self) = @_;
    return $self->{_profile_strictness};
}

#-----------------------------------------------------------------------------

sub severity {
    my ($self) = @_;
    return $self->{_severity};
}

#-----------------------------------------------------------------------------

sub single_policy {
    my ($self) = @_;
    return @{ $self->{_single_policy} };
}

#-----------------------------------------------------------------------------

sub theme {
    my ($self) = @_;
    return $self->{_theme};
}

#-----------------------------------------------------------------------------

sub top {
    my ($self) = @_;
    return $self->{_top};
}

#-----------------------------------------------------------------------------

sub verbose {
    my ($self) = @_;
    return $self->{_verbose};
}

#-----------------------------------------------------------------------------

sub color {
    my ($self) = @_;
    return $self->{_color};
}

#-----------------------------------------------------------------------------

sub pager  {
    my ($self) = @_;
    return $self->{_pager};
}

#-----------------------------------------------------------------------------

sub unsafe_allowed {
    my ($self) = @_;
    return $self->{_unsafe_allowed};
}

#-----------------------------------------------------------------------------

sub criticism_fatal {
    my ($self) = @_;
    return $self->{_criticism_fatal};
}

#-----------------------------------------------------------------------------

sub site_policy_names {
    return Perl::Critic::PolicyFactory::site_policy_names();
}

#-----------------------------------------------------------------------------

sub color_severity_highest {
    my ($self) = @_;
    return $self->{_color_severity_highest};
}

#-----------------------------------------------------------------------------

sub color_severity_high {
    my ($self) = @_;
    return $self->{_color_severity_high};
}

#-----------------------------------------------------------------------------

sub color_severity_medium {
    my ($self) = @_;
    return $self->{_color_severity_medium};
}

#-----------------------------------------------------------------------------

sub color_severity_low {
    my ($self) = @_;
    return $self->{_color_severity_low};
}

#-----------------------------------------------------------------------------

sub color_severity_lowest {
    my ($self) = @_;
    return $self->{_color_severity_lowest};
}

#-----------------------------------------------------------------------------

sub program_extensions {
    my ($self) = @_;
    return @{ $self->{_program_extensions} };
}

#-----------------------------------------------------------------------------

sub program_extensions_as_regexes {
    my ($self) = @_;

    return @{ $self->{_program_extensions_as_regexes} }
        if $self->{_program_extensions_as_regexes};

    my %program_extensions = hashify( $self->program_extensions() );
    $program_extensions{'.PL'} = 1;
    return @{
        $self->{_program_extensions_as_regexes} = [
            map { qr< @{[quotemeta $_]} \z >smx } sort keys %program_extensions
        ]
    };
}

1;
