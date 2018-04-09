package Getcoin::Model::Base;
use Mojo::Base -base;
use Getcoin::DB;

has [qw{conf req_params}];

has db => sub {
    Getcoin::DB->new( +{ conf => shift->conf } );
};

1;
