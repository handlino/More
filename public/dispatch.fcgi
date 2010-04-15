#!/Users/gugod/local/bin/perl
use Plack::Handler::FCGI;

my $app = do('/Users/gugod/src/More/app.psgi');
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
