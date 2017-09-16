use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

# テスト共通
use t::Util;
my $t = t::Util::init();
use Data::Dumper;

# ルーティング (ステータスのみ)
subtest 'router' => sub {

    # 302リダイレクトレスポンスの許可
    $t->ua->max_redirects(1);

    $t->get_ok('/sanpo/profile/1')->status_is(200);
    $t->get_ok('/sanpo/profile/1/edit')->status_is(200);
    $t->get_ok('/sanpo/profile/search')->status_is(200);
    $t->post_ok('/sanpo/profile/1/update')->status_is(200);
    $t->post_ok('/sanpo/profile/1/remove')->status_is(200);

    # 必ず戻す
    $t->ua->max_redirects(0);
};

subtest 'show' => sub {

    # ログインをする
    t::Util::login($t);
    subtest 'template' => sub {

        # ログイン中はユーザーID取得できる
        my $login_user = $t->app->login_user;
        my $user_id    = $login_user->id;
        my $profile    = $t->app->test_db->teng->single( 'profile',
            +{ user_id => $user_id } );
        my $url = "/sanpo/profile/$user_id";
        $t->get_ok($url)->status_is(200);

        # 主な部分のみ
        my $name = $profile->name;
        my $id   = $profile->id;
        $t->content_like(qr{\Q$name\E});

        # 編集画面へのボタン
        $t->element_exists("a[href=/sanpo/profile/$id/edit]");
    };

    # ログアウトをする
    t::Util::logout($t);
};

done_testing();

__END__

package Wansanpo::Controller::Sanpo::Profile;
