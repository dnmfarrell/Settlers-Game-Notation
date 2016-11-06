#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use JSON::Validator;
use JSON::XS qw/decode_json encode_json/;

my $messages = decode_json( do{ local(@ARGV, $/) = 'test-corpus/messages.json';<>} );
my $validator = JSON::Validator->new;
$validator->schema('schema/v1.0/message.json');

for my $msg (@$messages)
{
  my @errors = $validator->validate($msg->{message});
  my $result = @errors ? 0 : 1;
  cmp_ok $result, '==', $msg->{correct}, $msg->{reason};
}

done_testing;
