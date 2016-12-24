package WWW::Wikipedia::LangTitles;
use warnings;
use strict;
use Carp;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw/get_wiki_titles/;
our %EXPORT_TAGS = (
    all => \@EXPORT_OK,
);
our $VERSION = '0.01';
use LWP::UserAgent;
use URI::Escape 'uri_escape';
use JSON::Parse 'parse_json';

sub get_wiki_titles
{
    # The name of the article to fetch.
    my ($name, %options) = @_;
    my $verbose = $options{verbose};
    my $safe_name = $name;
    $safe_name = uri_escape ($safe_name);
    # The URL to get the information from.
    my $url = "https://www.wikidata.org/w/api.php?action=wbgetentities&sites=enwiki&titles=$safe_name&props=sitelinks/urls|datatype&format=json";
    if ($verbose) {
	print "Getting $safe_name from '$url'.\n";
    }
    my $ua = LWP::UserAgent->new ();
    my $agent = "Secret Agent Man";
    $ua = LWP::UserAgent->new (agent => $agent);
    $ua->default_header (
	'Accept-Encoding' => scalar HTTP::Message::decodable()
    );
    my $response = $ua->get ($url);
    if (! $response->is_success ()) {
	carp "Get $url failed: " . $response->status_line ();
	return;
    }
    my $json = $response->decoded_content ();
    my $data = parse_json ($json);
    my $array = $data->{entities};
    my %lang2title;
    for my $k (keys %$array) {
	my $sitelinks = $array->{$k}->{sitelinks};
	for my $k (keys %$sitelinks) {
	    my $lang = $k;
	    if ($lang =~ /wikiversity|simple|commons|wikiquote|wikibooks/) {
		next;
	    }
	    $lang =~ s/wiki$//;
	    $lang2title{$lang} = $sitelinks->{$k}->{title};
	}
    }
    return \%lang2title;
}

1;
