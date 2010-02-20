#!/usr/bin/env perl

use common::sense;
use utf8;

use FindBin::libs;
use WebService::ImKayac;
use Config::Pit;
use YAML;

my %conf = (%{ pit_get('im.kayac') }, type => 'secret');

#warn YAML::Dump(\%conf);

my $im = WebService::ImKayac->new(%conf);

$im->send('Hello! test send!!');
