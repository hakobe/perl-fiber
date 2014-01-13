package Fiber;

use strict;
use warnings;

use Carp qw(croak);
use Coro::State;

our $VERSION = '0.01';

my @yieldstack;
my @params;
my $retval;

sub new {
    my $class = shift;
    my $code  = shift;

    my $self = bless {
        coro  => undef, 
        alive => 1,
    }, $class;

    $self->{coro} = Coro::State->new(sub {
        $code->(@params);

        $self->{alive} = undef;
        Fiber->yield;
    });

    return $self;
}

sub yield {
    my $class = shift;
    $retval = shift;

    my ($coro, $prev) = @{ pop @yieldstack };
    $coro->transfer($prev);

    return @params;
}

sub resume {
    my $self = shift;
    croak "dead fiber called" unless $self->{alive};

    @params = @_;

    my $current = Coro::State->new;
    push @yieldstack, [$self->{coro}, $current];
    $current->transfer($self->{coro});

    return $retval;
}

1;

__END__

=encoding utf8

=head1 NAME

Fiber - Coroutine like Ruby 1.9 Fiber

=head1 SYNOPSIS

  use Fiber;

=head1 DESCRIPTION

Fiber is a coroutine implementaion like Ruby 1.9 Fiber.

=head1 AUTHOR

Yohei Fushii E<lt>hakobe@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
