use inc::Module::Install;
name 'WebService-ImKayac';
all_from 'lib/WebService/ImKayac.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
