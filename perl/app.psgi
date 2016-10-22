#!/usr/bin/env plackup
use 5.014;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use File::Spec;
use Plack::Builder;

use Plack::Middleware::AxsLog;
use File::RotateLogs;

use Isuketch::Web;

my $root_dir = $FindBin::Bin;
my $app = Isuketch::Web->new(root_dir => $root_dir);
my $psgi_app = $app->build_app;

my $rotatelogs = File::RotateLogs->new(
    logfile      => '/tmp/access_log.%Y%m%d%H%M',
    linkname     => '/tmp/access_log',
    rotationtime => 3600,
    maxage       => 86400, #1day
);

builder {
    enable 'AxsLog' => (
        combined      => 1,
        response_time => 1,
        error_only    => 1,
        ltsv          => 1,
        logger        => sub { $rotatelogs->print(@_) }
    );

    mount '/' => sub {
        my ($env) = @_;
        if ($env->{PATH_INFO} =~ m<\A/api/stream/rooms/([^/]+)\z>) {
            return $app->get_api_stream_room($env, $1);
        } else {
            return $psgi_app->($env);
        }
    };
};

__END__

sub {
    my ($env) = @_;
    if ($env->{PATH_INFO} =~ m<\A/api/stream/rooms/([^/]+)\z>) {
        return $app->get_api_stream_room($env, $1);
    } else {
        return $psgi_app->($env);
    }
};
