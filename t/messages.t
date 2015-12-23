#!/usr/bin/env perl
use Test::More;
use JSON::Schema::AsType;
use Mojo::JSON qw/decode_json encode_json/;
use Getopt::Long;

GetOptions(
  'update' => \(my $update_log),
);

my $spec = decode_json( do{ local(@ARGV, $/) = 'schema/message.json';<>} );
my $messages = decode_json( do{ local(@ARGV, $/) = 'test-corpus/messages.json';<>} );
ok my $schema = JSON::Schema::AsType->new( schema => $spec ), 'load schema';

my @data = ();
for my $msg (@$messages)
{
  push(@data, $msg->{message}) if $msg->{correct};
  my $result = $schema->check($msg->{message}) ? 1 : 0;
  ok $result == $msg->{correct}, $msg->{reason};
}

if ($update_log)
{
  my $json = encode_json(\@data);
  open my $fh, '>:utf8', 'test-corpus/log.json';
  print $fh $json;
}

done_testing;
