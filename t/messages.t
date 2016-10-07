#!/usr/bin/env perl
use Test::More;
use JSON::Schema::AsType;
use JSON::XS qw/decode_json encode_json/;

my $spec = decode_json( do{ local(@ARGV, $/) = 'schema/v0.4/message.json';<>} );
my $messages = decode_json( do{ local(@ARGV, $/) = 'test-corpus/messages.json';<>} );
ok my $schema = JSON::Schema::AsType->new( schema => $spec ), 'load schema';

my @data = ();
for my $msg (@$messages)
{
  push(@data, $msg->{message}) if $msg->{correct};
  my $result = $schema->check($msg->{message}) ? 1 : 0;
  ok $result == $msg->{correct}, $msg->{reason};
}

done_testing;
