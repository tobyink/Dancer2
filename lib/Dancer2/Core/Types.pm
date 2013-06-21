package Dancer2::Core::Types;

# ABSTRACT: types for Dancer2 core.

use strict;
use warnings;
use Scalar::Util 'blessed', 'looks_like_number';
use Type::Library -base;
use Type::Utils -all;

BEGIN { extends "Types::Standard" };

=head1 DESCRIPTION

Type definitions for Moo/Moose attributes. These are defined as Type::Tiny
type constraints.

=cut

my $single_part = qr/
    [A-Za-z]              # must start with letter
    (?: [A-Za-z0-9_]+ )? # can continue with letters, numbers or underscore
/x;

my $namespace = qr/
    ^
    $single_part                    # first part
    (?: (?: \:\: $single_part )+ )? # optional part starting with double colon
    $
/x;

=head1 TYPES 

=head2 ReadableFilePath($value)

A readable file path.

=head2 WritableFilePath($value)

A writable file path.

=head2 Dancer2Prefix($value)

A proper Dancer2 prefix, which is basically a prefix that starts with a I</>
character.

=head2 Dancer2AppName($value)

A proper Dancer2 application name.

Currently this only checks for I<\w+>.

=head2 Dancer2Method($value)

An acceptable method supported by Dancer2.

Currently this includes: I<get>, I<head>, I<post>, I<put>, I<delete> and
I<options>.

=head2 Dancer2HTTPMethod($value)

An acceptable HTTP method supported by Dancer2.

Current this includes: I<GET>, I<HEAD>, I<POST>, I<PUT>, I<DELETE>
and I<OPTIONS>.

=cut

sub exception_message {
    my ($val, $type) = @_;
    $val = 'undef' unless defined $val;
    return "$val is not $type!";
}

declare 'PositiveNum',
    as Num,
    where     {  $_ > 0  },
    inline_as { "$_ > 0" },
    message   { return exception_message($_, 'a positive number') };

declare 'PositiveOrZeroNum',
    as Num,
    where     {  $_ >= 0  },
    inline_as { "$_ >= 0" },
    message   { return exception_message($_, 'a positive number or zero') };

declare 'PositiveInt',
    as Int,
    where     {  $_ > 0  },
    inline_as { "$_ > 0" },
    message   { return exception_message($_, 'a positive integer') };

declare 'PositiveOrZeroInt',
    as Int,
    where     {  $_ >= 0  },
    inline_as { "$_ >= 0" },
    message   { return exception_message($_, 'a positive integer or zero') };

declare 'NegativeNum',
    as Num,
    where     {  $_ < 0  },
    inline_as { "$_ < 0" },
    message   { return exception_message($_, 'a negative number') };

declare 'NegativeOrZeroNum',
    as Num,
    where     {  $_ <= 0  },
    inline_as { "$_ <= 0" },
    message   { return exception_message($_, 'a negative number or zero') };

declare 'NegativeInt',
    as Int,
    where     {  $_ < 0  },
    inline_as { "$_ < 0" },
    message   { return exception_message($_, 'a negative integer') };

declare 'NegativeOrZeroInt',
    as Int,
    where     {  $_ <= 0  },
    inline_as { "$_ <= 0" },
    message   { return exception_message($_, 'a negative integer or zero') };

declare 'SingleDigit',
    as 'PositiveOrZeroInt',
    where     {  $_ < 10  },
    inline_as { "$_ < 10" },
    message   { return exception_message($_, 'a single digit') };

declare 'ReadableFilePath',
    where     {  -e $_ && -r $_  },
    inline_as { "-e $_ && -r $_" },
    message   { return exception_message($_, 'ReadableFilePath') };

declare 'WritableFilePath',
    where     {  -e $_ && -w $_  },
    inline_as { "-e $_ && -w $_" },
    message   { return exception_message($_, 'WritableFilePath') };

declare 'Dancer2Prefix',
    as Str,
    where {
        # a prefix must start with the char '/'
        # index is much faster than =~ /^\//
        index($_, '/') == 0;
    },
    inline_as { "index($_, q[/])==0" },
    message   { return exception_message($_, 'a Dancer2Prefix') };

declare 'Dancer2AppName',
    as StrMatch[$namespace],
    message   {
        return exception_message(
            length($_) ? $_ : 'Empty string',
            'a Dancer2AppName',
        );
    };

declare 'Dancer2Method',
    as Enum[qw(get head post put delete options patch)],
    message { return exception_message($_, 'a Dancer2Method') };

declare 'Dancer2HTTPMethod',
    as Enum[qw(GET HEAD POST PUT DELETE OPTIONS PATCH)],
    message { return exception_message($_, 'a Dancer2HTTPMethod') };

# generate abbreviated class types for core dancer objects
for my $type (
    qw/
    App
    Context
    Cookie
    DSL
    Dispatcher
    Error
    Hook
    MIME
    Request
    Response
    Role
    Route
    Runner
    Server
    Session
    Types
    /
  )
{
    class_type($type, {
        class   => "Dancer2::Core::$type",
        message => sub { "The value `$_[0]' does not pass the constraint check." },
    });
}

# Export (almost) everything by default.
sub import {
    push @_, qw( -types -is -to ) unless @_ > 1;
    my $super = "Type::Library"->can("import");
    goto $super;
}

1;

=head1 SEE ALSO

L<Types::Standard> for more available types

=cut

