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

    # lib/My/Project.pm
    use Env::Elope qw( dist_env_dir );
    my $config = dist_env_dir( 'My-Project' )->child( 'db.yml' );

    # share/env/dev/db.yml
    db_server: dev.example.com

    # share/env/prd/db.yml
    db_server: example.com

    # On a command line:
    $ elope dev run_my_project
    $ elope prd run_my_project

=head1 DESCRIPTION

Elope helps to manage multiple environments through configuration directories
and environment variables. Using the C<elope> command-line script, a program
can be run in any environment, choosing all the right configuration for that
environment.

=head2 SETUP

To set up Elope, you need:

=over 4

=item A config directory named for each environment

The configuration directories should be in each distribution's "share/env" directory
and should have the same name as the environment they configure. So C<share/env/dev>
will be our "dev" environment, and C<share/env/prod> our "prod" environment.

=item The C<elope> command-line utility

The elope utility will source in the envrc file for the current environment and then
run the command. The elope utility sets the C<ELOPE_ENV> environment variable that
chooses which config directory to use.

=item An envrc file named for each environment

After installing the elope utility, you must make a directory for your envrc files.
If you installed elope to /opt/bin/elope, you should make a directory /opt/etc/envrc
and put your envrc files there.

An envrc file should be named the same as the environment, and should export
environment variables like C<PATH> and C<LD_LIBRARY_PATH>, or maybe configure a Perl
L<local::lib>.

    # /opt/etc/envrc/dev
    # Now that 5.20.2 is released, lets use it in dev to try it
    PATH=/usr/perlbrew/perls/5.20.2/bin:$PATH
    eval $( perl -Mlocal::lib=/opt/envs/dev )

    # /opt/etc/envrc/prod
    # We haven't upgrade to 5.20.2 yet in prod
    PATH=/usr/perlbrew/perls/5.20.1/bin:$PATH
    eval $( perl -Mlocal::lib=/opt/envs/prod )

=back

=head2 USING

Now that we have our envrc and our config dirs, we can run our scripts with the
elope command:

    # Install one of our modules in dev
    $ elope dev perl Build.PL
    $ ./Build install

    # Run its tests using the dev configuration
    $ elope dev prove -lr t

    # Run our server
    $ elope dev morbo bin/my-mojo-app -l 'http://*:8080'

If we switch "dev" to "prod" in any of the above commands, we are running them in
production.

