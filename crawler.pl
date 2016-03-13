#!/usr/bin/perl
use strict;
use warnings;

use Tie::LevelDB;
use JSON::XS;
use LWP::UserAgent;
use HTML::LinkExtractor;
use Data::Dumper;

my $queueDb = new Tie::LevelDB::DB("./qdb");
my $foundProducts = new Tie::LevelDB::DB("./foundPUlrs");
my $baseUrl = "http://www.target.com";
#-- data structures needed:

#a queue to figure out what next to crawl
my @urlQueue = ();
my $urlQueueRef = @urlQueue;

#a hash to keep track of all the urls that have been visited
#-- this will have a url as a key true as the value -----> this will be updated once basic working:
#-- name, brand, model, category, price, url, timestamp. Can this store the depth too at one point?
my $visitedUrlsRef = {};
my $productsCapturedRef = {};

#-- Chose a webpage and send a get request to return the content of the page
my $startUrl = FILLMEIN;
getLinks($startUrl);
# my $count = 0;

#-- Main Function
#-----------------
while ( $urlQueueRef > 0 ) {#while the queue length is not 0 
	# $count++;
	#get first thing in the queue and mark as seen
	my $nextUrl = shift @urlQueue;

	if ( $nextUrl !~ /\bhttp/ ) { #if not start with http then add the rest of the address
		$nextUrl = $baseUrl . $nextUrl;
		print "ADD http to the URL: $nextUrl";
	}

	#check if is it a products page
	if ( $nextUrl =~ /https?:\/\/www\.target\.com\/p\// ) {
		#if products page then add to product hash with needed info and depth (later)
		$productsCapturedRef->{ $nextUrl } = "true";
		#get the html and sift for the needed information TODO
		$foundProducts->Put( $nextUrl, "true" );
		print "Found a product page: $nextUrl";
	} else {
		sleep(2);
		#get the links from the page
		getLinks( $nextUrl );
	}

}

sub getLinks {
	my ( $url ) = @_;
	my $ua = LWP::UserAgent->new;
	$ua->timeout(10);
	$ua->env_proxy;

	my $response = $ua->get( $startUrl );

	if ($response->is_success) {
		my $input = $response->decoded_content;
		my $LX = new HTML::LinkExtractor();
		$LX->parse(\$input);
		#subroutine to add the links to the queue if they have an href not return important information
		addLinksToQueue( $LX->links, $url );
		$visitedUrlsRef->{ $nextUrl } = "true";
	} else {
		$visitedUrlsRef->{ $url } = "Bad URL!";
		print "Bad url";
	}		
};

sub addLinksToQueue {
	my ( $links, $url ) = @_;
	# add urls to the queue
	foreach my $link ( @{ $links } ) {
		if ( defined $link->{ "href" } && ! defined $visitedUrlsRef->{ $link } ) {
			my $urlValid = filterUrl( $link );
			if ( defined $urlValid ) {
				push @urlQueue, $urlValid->{ "href" };
			}
		}
	}
	#update the queue db replace the current key with new latest array
	my $arrayRef = \@urlQueue;
	my $valueRef = encode_json $arrayRef;
	$queueDb->Put("Queue", $valueRef);
	print "Added latest relevant urls to queue: " . Dumper( @urlQueue );
};

sub filterUrl {
	my ( $link ) = @_;
	#if it starts with http then must contain target.com and not end in css
	if ( $link->{ "href" } =~ /https?:\/\/www\.target\.com/ ) {
		if ( $link->{ "href" } !~ /(help|investors|size-charts|checkout_cartview|affiliate|giftcards|redcard|subscriptions|press|contactus|weeklyad|store-locator|corporate|gift-registry|targetmedianetwork|careers|coupons|accessibility|productrecallpage|terms-conditions|privacy|policy)/ ) {
			return $link;
		}
	} elsif ( $link->{ "href" } =~ /^(\/\w+(\/|\?).+)$/ && $link->{ "href" } !~ /help/ ) {
		return $link;
	}
	return undef;
};




#Project1: Crawl target.com
#Project2: Find dead links inside semantics3.com

#-- somehow filter by those useful ?! Need to see if there is a price or product here?
#-- on target anything that has target.com/p/..... is a product page EXTRA

#if href not start with http then need to start with target.com
#if the href is target.com/p/..... then it is a product page
	#id=price_main div contains a div and a span which contains a price
	#class: product-name item div contains span this is also inthe url
	#Brand? in name but how extract?
	#span with class of last contains an a with class category and title of main category

#Algorithm (Breadth-first search):
#while(queue is not empty) {
# pop element
# visit/download page (use LWP::Simple)
# check html error code/status of the page ie. 404 or 500 or 200
# extract links out (use HTML::LinkExtor)
# mark page as visited
# check if those links have been visited or not. If not, put them into the queue
# extensions: keep track of "depth"/layers
# sleep time (put 2 seconds)
# extenions: persistency - can your crawler recover from a crash or restart?
#}



