use strict;
use warnings;
use utf8;

use Encode;
use JSON;
use URI::Escape;
use LWP::UserAgent;

sub googleImageSearch {
    my ($q, $start) = @_;
    my $googleimgapi = 'http://ajax.googleapis.com/ajax/services/search/images';
    my $referer = 'http://www.yagi.sh/';
    my $uri = sprintf('%s?q=%s&v=1.0&rsz=large&hl=ja&start=%s&imgc=color', $googleimgapi, $q, "$start");

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new('GET', $uri);
    # $req->referer($referer);
    my $res = $ua->request($req);
    if(!$res->is_success) { return undef; }
    my $json = decode_json(($res->content));
    if($json->{'responseStatus'} != 200) { return undef; }
    if(!$json->{'responseData'}) { return undef; }
    if(!$json->{'responseData'}->{'results'}) { return undef; }
    return $json->{'responseData'};
}

sub getImageURLs {
    my ($q, $max) = @_;
    my $start = 0;
    while($start < $max) {
        my $json = &googleImageSearch($q, $start);
        if(!$json) { return undef; }
        my @results = @{$json->{'results'}};
        foreach my $result (@results) {
            if($result->{'url'}) {
                print "$result->{'url'}\n";
            }
        }
        my $cursor = $json->{'cursor'};
        my $nextPageIndex = 1 + $cursor->{'currentPageIndex'};
        if($nextPageIndex > $#{$cursor->{'pages'}}) {
            last;
        }

        $start = $cursor->{'pages'}[$nextPageIndex]->{'start'};
    }
}

&getImageURLs($ARGV[0], 56);
