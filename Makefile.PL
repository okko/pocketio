#!/usr/bin/env perl

use strict;
use warnings;

use inc::Module::Install;

name 'PocketIO';

version_from 'lib/PocketIO.pm';
author 'Viacheslav Tykhanovskyi <vti@cpan.org>';
abstract 'Socket.IO Plack app';
license 'artistic_2';
perl_version '5.008007';

requires 'AnyEvent'            => '0';
requires 'Fliggy'              => '0';
requires 'JSON'                => '0';
requires 'Plack'               => '0';
requires 'Protocol::WebSocket' => '0.009003';
requires 'Scalar::Util'        => '0';
requires 'Try::Tiny'           => '0';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';

no_index directory => 't';

resources
  bugtracker => 'http://github.com/vti/pocketio/issues',
  repository => 'http://github.com/vti/pocketio/',
  license    => 'http://dev.perl.org/licenses/';

auto_install;

WriteAll;
