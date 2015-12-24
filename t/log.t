#!/usr/bin/env perl
use Test::More;
use JSON::Schema::AsType;
use Mojo::JSON qw/decode_json/;

my $spec = decode_json( do{ local(@ARGV, $/) = 'schema/v0.3/log.json';<>} );
my $log = decode_json( do{ local(@ARGV, $/) = 'test-corpus/log.json';<>} );
ok my $schema = JSON::Schema::AsType->new( schema => $spec ), 'load schema';
ok $schema->check($log), 'process log of messages';
done_testing;
