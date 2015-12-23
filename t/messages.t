#!/usr/bin/env perl
use Test::More;
use JSON::Schema::AsType;
use Mojo::JSON 'decode_json';

my $spec = decode_json( do{ local(@ARGV, $/) = 'schema/message.json';<>} );
my $messages = decode_json( do{ local(@ARGV, $/) = 'test-corpus/messages.json';<>} );
ok my $schema = JSON::Schema::AsType->new( schema => $spec ), 'load schema';

for my $msg (@$messages)
{
  my $result = $schema->check($msg->{message}) ? 1 : 0;
  ok $result == $msg->{correct}, $msg->{message}{event};
}

done_testing;
