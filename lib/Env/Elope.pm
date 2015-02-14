package Env::Elope;
# ABSTRACT: Configure projects in multiple environments

use strict;
use warnings;
use Sub::Exporter -setup => {
    exports => [qw( dist_env_dir )],
};
use File::Share qw( dist_dir );
use Path::Tiny qw( path );

=sub dist_env_dir DIST, OPTIONS

Get the configuration directory for the given C<DIST>. Returns a L<Path::Tiny>
object with the given dist path.

Configuration directories are located in a distribution's C<share/env/> directory.
Which directory is chosen is based on the C<ELOPE_ENV> environment variable.

C<OPTIONS> is a set of key/value pairs for options with the following keys:

    env     - Set the environment name, overriding the current environment

=cut

sub dist_env_dir($%) {
    my ( $dist, %opt ) = @_;
    my $env = $opt{env} || $ENV{ELOPE_ENV} || die "ELOPE_ENV not set!";
    return path( dist_dir( $dist ), 'env', $env );
}

1;
__END__

=head1 SYNOPSIS

    use Env::Elope qw( dist_env_dir );

    my $config = dist_env_dir( 'My-Project' )->child( 'config.yml' );

=head1 DESCRIPTION

This module manages configuration directories based on the what environment
the code is running in.
