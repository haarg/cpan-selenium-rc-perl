#!/usr/bin/perl
# Copyright 2006 ThoughtWorks, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use lib 'lib';
use FindBin qw($Bin);
use File::Spec;
use Test::WWW::Selenium;
use WWW::Selenium::Util qw(server_is_running);
use Test::More;

my ($host, $port) = server_is_running();
if ($host and $port) {
    plan tests => 7;
}
else {
    plan skip_all => "No selenium server found!";
    exit 0;
}
my $test_click_page1 = File::Spec->catfile($Bin, 'files', 'test_click_page1.html');

Regular_test: {
    my $sel = Test::WWW::Selenium->new(
        host        => $host,
        port        => $port,
        browser     => "*firefox",
        browser_url => "http://$host:$port",
        verbose => 1,
    );
    $sel->open_ok("file://" . $test_click_page1);
    $sel->text_like("link", qr/Click here for next page/, "link contains expected text");
    my @links = $sel->get_all_links();
    ok(@links > 3);
    is($links[3], "linkToAnchorOnThisPage");
    $sel->click("link");
    $sel->wait_for_page_to_load(5000);
    $sel->location_like(qr/test_click_page2\.html/);
    $sel->click("previousPage");
    $sel->wait_for_page_to_load(5000);
    $sel->location_like(qr/test_click_page1\.html/);
}

HTTP_GET: {
    my $sel = Test::WWW::Selenium->new(
        host        => $host,
        port        => $port,
        browser     => "*firefox",
        browser_url => "http://$host:$port",
        http_method => 'GET',
        verbose => 1,
    );
    $sel->open_ok("file://" . $test_click_page1);
}
