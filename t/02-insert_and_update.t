#!/usr/bin/perl -w

use Test::More;

use t::app::Main;
use strict;

eval{ system "sqlite3 t/app/db/example.db < t/app/db/example.sql";};
if ($@)
{
  plan skip_all => "sqlite3 is require for these tests : $@";
  exit;
}
else
{
  plan tests => 7;
}

system "perl t/app/insertdb.pl";

my $schema = t::app::Main->connect('dbi:SQLite:t/app/db/example.db');
# for other DSNs, e.g. MySQL, see the perldoc for the relevant dbd
# driver, e.g perldoc L<DBD::mysql>.


# object t::app::Main::Result::Object have validate options
# libelle must be unique
# libelle can not be 'error'

use Data::Dumper 'Dumper';

my $object1 = $schema->resultset('Object')->create({name => "good"});
is(ref($object1), 't::app::Main::Result::Object', "create Object with name 'good' is Ok");
my @objects1 = $schema->resultset('Object')->search({name => "good"});
is( scalar(@objects1),1,"validation is ok, object was create");

my $object2= $schema->resultset('Object')->create({name => "good"});
ok( $object2->result_errors, "can not create 2 objects with the same name");
my @objects2 = $schema->resultset('Object')->search({name => "good"});
is( scalar(@objects2),1,"can not create 2 objects with the same name");

my $object3 = $objects2[0];
$object3->name('error');
my $ok = $object3->update();
ok( $object3->result_errors, "can not update object with an error");
my @objects3 = $schema->resultset('Object')->search({name => "error"});
is( scalar(@objects3),0,"can not update object with the name 'error'");
my @objects4 = $schema->resultset('Object')->search({name => "good"});
is( scalar(@objects4),1,"can not update object with the name 'error'");

