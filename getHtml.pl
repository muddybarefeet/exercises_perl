use strict;
use warnings;

use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;
use Data::Dumper;

my $mech = WWW::Mechanize->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

$mech->get( 'http://www.target.com/p/acer-11-6-chromebook-white-cb3-131-c3kd/-/A-50679552#prodSlot=_1_1' );

# -- Product Name
my $title = $mech->title();

#-- Price, could probably do this without a loop
my @list = $mech->look_down('_tag' => 'span',
							'class' => 'offerPrice');

# # Now just iterate and process
# foreach (@list) {
#     print $_->as_text();
# }

#-- This gets the list of the category tree (last item = span with class of last)
my @list = $mech->look_down('_tag' => 'a',
							'class' => 'category');

my @category = ();

# # Now just iterate and process
foreach (@list) {
    push @category, $_->as_text();
}

# print Dumper(@category);











	


