use strict;
use warnings;

package Jifty::Plugin::Authentication::Facebook::Dispatcher;
use Jifty::Dispatcher -base;

=head1 NAME

Jifty::Plugin::Authentication::Facebook::Dispatcher - dispatcher for facebook plugin

=head1 DESCRIPTION

All the dispatcher rules jifty needs to support L<Jifty::Authentication::Facebook>

=head1 RULES

=head2 before '/facebook/callback'

Handles the login callback.  You probably don't need to worry about this.

=cut

before qr'^/facebook/callback(_link)?' => run {
    my $link    = $1 ? 1 : 0;
    my $action  = $link ? 'LinkFacebookUser' : 'LoginFacebookUser';
    my $moniker = $link ? 'facebooklink'     : 'facebooklogin';

    Jifty->web->request->add_action(
        moniker   => $moniker,
        class     => $action,
        arguments => {
            auth_token => get('auth_token'),
        }
    );
    if ( Jifty->web->request->continuation ) {
        Jifty->web->request->continuation->call;
    }
    else {
        redirect '/';
    }
};

=head2 before '/facebook/force_login'

Redirects user to the Facebook login page.  Useful if you want to skip
prompting the user to login on your app.

=cut

before '/facebook/force_login' => run {
    my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Facebook');
    Jifty->web->_redirect( $plugin->get_login_url );
};

=head2 before '/facebook/logout'

Directing a user here will log him out of the app and Facebook.

=cut

before '/facebook/logout' => run {
    if ( Jifty->web->current_user->id ) {
        Jifty->web->current_user( undef );
        my ($plugin) = Jifty->find_plugin('Jifty::Plugin::Authentication::Facebook');
        $plugin->api->auth->logout;
    };
    redirect '/';
};

1;
