package Getcoin::DB;
use Mojo::Base 'Getcoin::DB::Base';
use Getcoin::DB::Master;

has master => sub { Getcoin::DB::Master->new(); };

1;
