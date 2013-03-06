package Monitoring::TT::Render;

use strict;
use warnings;
use utf8;
use Carp;
use Monitoring::TT::Log qw/error warn info debug trace log/;

#####################################################################

=head1 NAME

Monitoring::TT::Render - Render Helper Functions

=head1 DESCRIPTION

All functions from this render helper can be used in templates

=cut

#####################################################################

=head1 METHODS

=head2 die

    die(error message)

    die with an hopefully useful error message

=cut
sub die {
    my( $msg ) = @_;
    croak($msg);
    return;
}

#####################################################################

=head2 uniq

    uniq(objects, attr)
    uniq(objects, attr, name)

    returns list of uniq values for one attr of a list of objects

    ex.:

    get uniq list of group items
    uniq(hosts, 'group')

    get uniq list of test tags
    uniq(hosts, 'tag', 'test')

=cut
sub uniq {
    my( $objects, $attrlist , $name ) = @_;
    croak('expected list of objects') unless ref $objects eq 'ARRAY';
    my $uniq = {};
    for my $o (@{$objects}) {
        for my $attr (@{_list($attrlist)}) {
            if($name) {
                next unless defined $o->{$attr};
                next unless defined $o->{$attr}->{$name};
                for my $v (split(/\s*\|\s*|\s*,\s*/mx, $o->{$attr}->{$name})) {
                    $uniq->{$v} = 1;
                }
            } else {
                next unless defined $o->{$attr};
                my $tmp = $o->{$attr};
                if(ref $tmp ne 'ARRAY') { my @tmp = split(/\s*,\s*/mx,$tmp); $tmp = \@tmp; }
                for my $a (@{$tmp}) {
                    $uniq->{$a} = 1;
                }
            }
        }
    }
    my @list = keys %{$uniq};
    return \@list;
}

#####################################################################

=head2 uniq_list

    uniq_list(list1, list2, ...)

    returns list of uniq values in all lists

=cut
sub uniq_list {
    return join_hash_list(@_) if defined $_[0] and ref $_[0] eq 'HASH';
    my $uniq = {};
    for my $list (@_) {
        for my $i (@{$list}) {
            $uniq->{$i} = 1;
        }
    }
    my @items = sort keys %{$uniq};
    return \@items;
}

#####################################################################

=head2 join_hash_list

    join_hash_list($hashlist, $exceptions)

    returns list csv list for hash but leave out exceptions

=cut
sub join_hash_list {
    my($hash, $exceptions) = @_;
    return "" unless defined $hash;
    my $list = [];
    for my $key (sort keys %{$hash}) {
        my $skip = 0;
        for my $ex (@{_list($exceptions)}) {
            if($key =~ m/$ex/mx) {
                $skip = 1;
                last;
            }
        }
        next if $skip;
        for my $val (@{_list($hash->{$key})}) {
            if($val) {
                push @{$list}, $key.'='.$val;
            } else {
                push @{$list}, $key;
            }
        }
    }
    $list = uniq_list($list);
    return join(', ', sort @{$list});
}

#####################################################################
sub _list {
    my($data) = @_;
    return([]) unless defined $data;
    return($data) if ref $data eq 'ARRAY';
    return([$data]);
}
#####################################################################

=head1 AUTHOR

Sven Nierlein, 2013, <sven.nierlein@consol.de>

=cut

1;
