package Mojolicious::Command::generate::mvc;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{class_to_file class_to_path};

has description => 'Generate create mvc';
has usage => sub { shift->extract_usage };
has [qw{}];

sub run {
    my $self        = shift;
    my @class_names = @_;
    my $home        = $self->app->home;

    my $error_msg
        = 'Your application name has to be a well formed (CamelCase) Perl module name like "MyApp". ';

    # 指定ない場合 doc, etc を配置
    if ( !scalar @class_names ) {
        $self->app->commands->run( 'generate', 'doc' );
        $self->app->commands->run( 'generate', 'etc' );
        return;
    }

    for my $name (@class_names) {
        next if $name =~ /^[A-Z](?:\w|::)+$/;
        $error_msg = "Your input name [$name] ?\n" . $error_msg;
        die $error_msg;
    }

    # app 自身のクラス名取得
    die 'Can not get class name!' if $home->path('lib')->list->size ne 1;
    my $app = $home->path('lib')->list->first->basename('.pm');

    # lib/App/Controller/Base.pm
    $self->_lib_file( $app, [ 'Controller', 'Base' ], 'controller_base' );

    # lib/App/Model/Base.pm
    $self->_lib_file( $app, [ 'Model', 'Base' ], 'model_base' );

    # lib/App/DB/Base.pm
    $self->_lib_file( $app, [ 'DB', 'Base' ], 'db_base' );

    # lib/App/Model.pm
    $self->_lib_file( $app, ['Model'], 'model_pm' );

    # lib/App/DB.pm
    $self->_lib_file( $app, ['DB'], 'db_pm' );

    # lib/App/DB/Master.pm
    $self->_lib_file( $app, [ 'DB', 'Master' ], 'master_pm' );

    # lib/App/Util.pm
    $self->_lib_file( $app, ['Util'], 'util_pm' );

    # lib/App/Controller/
    $self->_lib_file( $app, [ 'Controller', @class_names ], 'controller' );

    # lib/App/Model/
    $self->_lib_file( $app, [ 'Model', @class_names ], 'model' );

    # lib/Test/Mojo/Role/Basic.pm
    $self->_lib_test_file($app);

    # db/app_schema.sql
    $self->_db_file($app);

    # t/app.t or t/
    $self->_t_file( $app, \@class_names );

    # templates/
    $self->_templates_file( \@class_names );

    # doc/
    $self->_doc_file( $app, \@class_names );
    return;
}

sub _array_to_path {
    my ( $self, $array ) = @_;
    return class_to_path( join '::', @{$array} );
}

# lib/Test/Mojo/Role/Basic.pm
sub _lib_test_file {
    my $self     = shift;
    my $appclass = shift;

    my $test_mojo_role      = join '::', 'Test', 'Mojo', 'Role', 'Basic';
    my $test_mojo_role_file = class_to_path $test_mojo_role;
    my $test_mojo_role_args = +{
        class   => $test_mojo_role,
        appname => $appclass,
    };
    $self->render_to_rel_file( 'test_mojo_role', "lib/$test_mojo_role_file",
        $test_mojo_role_args );
    return;
}

# db/app_schema.sql
sub _db_file {
    my $self     = shift;
    my $appclass = shift;
    my $sql_name = class_to_file $appclass;
    my $sql_file = $sql_name . '_schema.sql';
    $self->render_to_rel_file( 'sql', "db/$sql_file" );
    return;
}

# t/app.t or t/
sub _t_file {
    my $self        = shift;
    my $appclass    = shift;
    my $class_names = shift;

    my $t_app_t_name = class_to_file $appclass;
    my $t_app_t_file = $t_app_t_name . '.t';
    my $t_app_t_args = +{ appname => $appclass, };
    $self->render_to_rel_file( 'test', "t/$t_app_t_file", $t_app_t_args );

    my $controller_file = $self->_array_to_path(
        [ $appclass, 'Controller', @{$class_names} ] );

    # ひとつの区切りごとに class_to_file をしないといけない
    my @test_files = split '/', $controller_file;
    for my $name (@test_files) {
        $name = class_to_file $name;
    }
    my $test_file = join '/', @test_files;
    $test_file =~ s{\Q.pm\E}{.t};
    my $test_args = +{ appname => $appclass, };
    $self->render_to_rel_file( 'test', "t/$test_file", $test_args );
    return;
}

# templates/
sub _templates_file {
    my $self           = shift;
    my $class_names    = shift;
    my $templates_file = class_to_file join '/', @{$class_names},
        'index.html.ep';
    $self->render_to_rel_file( 'index', "templates/$templates_file" );
    return;
}

# doc/
sub _doc_file {
    my $self        = shift;
    my $appclass    = shift;
    my $class_names = shift;

    # Controller
    my $controller_file = $self->_array_to_path(
        [ $appclass, 'Controller', @{$class_names} ] );

    # Model
    my $model_file
        = $self->_array_to_path( [ $appclass, 'Model', @{$class_names} ] );

    # Templates
    # ひとつの区切りごとに class_to_file をしないといけない
    my @templates_names;
    for my $name ( @{$class_names} ) {
        push @templates_names, class_to_file $name;
    }
    my $templates_name = join '/', @templates_names, '';
    my $templates_file = $templates_name;

    # ひとつの区切りごとに class_to_file をしないといけない
    my @test_files = split '/', $controller_file;
    for my $name (@test_files) {
        $name = class_to_file $name;
    }
    my $test_file = join '/', @test_files;
    $test_file =~ s{\Q.pm\E}{.t};

    # ひとつの区切りごとに class_to_file をしないといけない
    my @doc_files = split '/', $controller_file;
    for my $name (@doc_files) {
        $name = class_to_file $name;
    }
    my $doc_file = join '/', @doc_files;

    $doc_file =~ s{\Q.pm\E}{.md};
    my $doc_name = $doc_file;
    $doc_name =~ s{\Q.md\E}{};

    my $doc_args = +{
        name       => $doc_name,
        appname    => $appclass,
        controller => $controller_file,
        model      => $model_file,
        templates  => $templates_file,
        test       => $test_file,
    };
    $self->render_to_rel_file( 'doc', "doc/$doc_file", $doc_args );
    return;
}

# lib/
sub _lib_file {
    my $self     = shift;
    my $appclass = shift;
    my $names    = shift;
    my $template = shift;

    my $class     = join '::', $appclass, @{$names};
    my $file_path = class_to_path $class;
    my $args      = +{
        class   => $class,
        appname => $appclass,
    };
    $self->render_to_rel_file( $template, "lib/$file_path", $args );
    return;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Command::generate::mvc - Mojolicious mvc

=head1 SYNOPSIS

  Usage: carton exec -- script/app generate mvc [OPTIONS]

  Options:
    -m, --mode   Does something.

    # コントローラ, モデル, テンプレート, テストコードが作成
    # package App::Controller::Auth::Test; の場合
    $ carton exec -- script/app generate mvc Auth Test

=head1 DESCRIPTION

=cut

__DATA__

@@ controller_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base 'Mojolicious::Controller';

1;

@@ model_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;
use <%= $args->{appname} %>::DB;

has [qw{conf req_params}];

has db => sub {
    <%= $args->{appname} %>::DB->new( +{ conf => shift->conf } );
};

1;

@@ db_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;

has [qw{conf}];

1;

@@ model_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Model::Base';

# add method
# use <%= $args->{appname} %>::Model::Example;
# has example => sub {
#     <%= $args->{appname} %>::Model::Example->new( +{ conf => shift->conf } );
# };

# add helper method
# package <%= $args->{appname} %>;
# use Mojo::Base 'Mojolicious';
# use <%= $args->{appname} %>::Model;
#
# sub startup {
#    my $self = shift;
#    ...
#    my $config = $self->config;
#    $self->helper(
#        model => sub { <%= $args->{appname} %>::Model->new( +{ conf => $config } ); } );
#    ...
# }

1;

@@ db_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::DB::Base';
use <%= $args->{appname} %>::DB::Master;

has master => sub { <%= $args->{appname} %>::DB::Master->new(); };

1;

@@ master_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;

has [qw{master_hash master_constant_hash}];

sub deleted {
    my $self = shift;
    my $hash = +{
        0 => 'not_deleted',
        1 => 'deleted',
    };

    my $constant = +{
        NOT_DELETED => 0,
        DELETED     => 1,
    };

    $self->master_hash($hash);
    $self->master_constant_hash($constant);
    return $self;
}

# my $word = 'deleted';
# my $deleted_id = $master->deleted->word_id($word);
sub word_id {
    my $self = shift;
    my $word = shift;
    my $word_id;
    while ( my ( $key, $val ) = each %{ $self->master_hash } ) {
        $word_id = $key;
        return $word_id if $val eq $word;
    }
    die 'error master methode word_id: ';
}

# my $word_id = 5;
# my $deleted_word = $master->deleted->word($word_id);
sub word {
    my $self    = shift;
    my $word_id = shift;
    my $word    = $self->master_hash->{$word_id};
    die 'error master methode word: ' if !defined $word;
    return $word;
}

# my $label = 'DELETED';
# my $deleted_word = $master->deleted->to_word($label);
sub to_word {
    my $self     = shift;
    my $label    = shift;
    my $constant = $self->master_constant_hash->{$label};
    die 'error master methode constant: ' if !defined $constant;
    my $word = $self->master_hash->{$constant};
    die 'error master methode word: ' if !defined $word;
    return $word;
}

# my $label = 'DELETED';
# my $deleted_constant = $master->deleted->constant($label);
sub constant {
    my $self     = shift;
    my $label    = shift;
    my $constant = $self->master_constant_hash->{$label};
    die 'error master methode constant: ' if !defined $constant;
    return $constant;
}

# my $constant = 5;
# my $deleted_label = $master->deleted->label($constant);
sub label {
    my $self     = shift;
    my $constant = shift;
    my $label;
    while ( my ( $key, $val ) = each %{ $self->master_constant_hash } ) {
        $label = $key;
        return $label if $val eq $constant;
    }
    die 'error master methode constant: ';
}

# +{  0 => 'not_deleted',
#     1 => 'deleted',
# };
# my $deleted_to_hash = $master->deleted->to_hash;
sub to_hash {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_hash: ' if !scalar @keys;
    return $hash;
}

# [ 0, 1 ];
# my $deleted_to_ids = $master->deleted->to_ids;
sub to_ids {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_ids: ' if !scalar @keys;
    my @sort_keys = sort { $a <=> $b } @keys;
    return \@sort_keys;
}

# [
#     +{ id => 0, name => 'not_deleted', },
#     +{ id => 1, name => 'deleted', },
# ]
# my $deleted_sort_to_hash = $master->deleted->sort_to_hash;
sub sort_to_hash {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode sort_to_hash: ' if !scalar @keys;
    my @sort_keys = sort { $a <=> $b } @keys;
    my $sort_hash;
    for my $key (@sort_keys) {
        push @{$sort_hash}, +{ id => $key, name => $hash->{$key} };
    }
    return $sort_hash;
}

1;

@@ util_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;
use Time::Piece;
use Exporter 'import';
our @EXPORT_OK = qw{
    now_datetime
};

# use <%= $args->{appname} %>::Util qw{now_datetime};
#
# '2017-11-11 13:43:10'
# my $datatime = now_datetime();
sub now_datetime {
    my $t    = localtime;
    my $date = $t->date;
    my $time = $t->time;
    return "$date $time";
}

1;

@@ test_mojo_role
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -role;
use Test::More;
use Mojo::Util qw{dumper};

sub init {
    my $self = shift;
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->with_roles('+Basic')->new('<%= $args->{appname} %>');
    die 'not testing mode' if $t->app->mode ne 'testing';

    # test DB
    # $t->app->commands->run('generate', 'sqlitedb');
    # $t->app->helper(
    #     test_db => sub { <%= $args->{appname} %>::DB->new( +{ conf => $t->app->config } ) }
    # );
    return $t;
}

1;

@@ sql
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    login_id        TEXT,
    password        TEXT,
    approved        INTEGER,
    deleted         INTEGER,
    created_ts      TEXT,
    modified_ts     TEXT
);

@@ controller
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Controller::Base';

sub index {
    my $self = shift;
    $self->render(text => 'index');
    return;
}

1;

@@ test
% my $args = shift;
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};

my $t = Test::Mojo->with_roles('+Basic')->new('<%= $args->{appname} %>')->init;

ok(1);

done_testing();

@@ index
%% layout '';
%% title '';

@@ model
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Model::Base';

sub index {
    my $self = shift;
    return;
}

1;

@@ doc
% my $args = shift;
# NAME

<%= $args->{name} %> - <%= $args->{appname} %>

# SYNOPSIS

## URL

# DESCRIPTION

# TODO

```
- GET - `/example/create` - create
- GET - `/example/search` - search
- GET - `/example` - index
- GET - `/example/:id/edit` - edit
- GET - `/example/:id` - show
- POST - `/example` - store
- POST - `/example/:id/update` - update
- POST - `/example/:id/remove` - remove
```

# SEE ALSO

- `lib/<%= $args->{controller} %>` -
- `lib/<%= $args->{model} %>` -
- `templates/<%= $args->{templates} %>` -
- `t/<%= $args->{test} %>` -
