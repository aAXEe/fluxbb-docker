This is the image we're using for our forum at http://forum.openseamap.org.
It is based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker).
The Dockerfile is based on [raumzeitlabor/mediawiki-docker](https://github.com/raumzeitlabor/mediawiki-docker).

The fluxbb version being used is 1.5.9. The image comes with a
default installation housed in `/data/fluxbb`.

### Requirements

This container requires a running, linked mysql instance, e.g.
[raumzeitlabor/mysql-docker](https://github.com/raumzeitlabor/mysql-docker). It
is intended to be run behind a reverse-proxy and thus comes with an SSL
webserver configuration.
It is prepared to use [raumzeitlabor/nginx-proxy](https://github.com/raumzeitlabor/nginx-proxy).

### Setup

To set up this container, simply copy the `fluxbb.service` file to
`/etc/systemd/system` and run `systemctl daemon-reload`, followed by `systemctl
start fluxbb.service`.

The service unit will then take care of creating two containers:

* `fluxbb-data`: The data-only container that exposes a volume called
`/data`. This container immediately exits. It's only purpose is to keep state.
_Don't delete it._
* `fluxbb-web`: The application container that houses an nginx webserver,
and php5-fpm.

#### Initial setup of FluxBB

At the first run fluxbb will detect the missing config.php in its root directory
and will start the install procedure.

For the mysql host enter `mysql`. The login data for the database depend on the
chosen provider for the db.

After the install you will be prompted a file `config.php` for download. You need
to copy this file into the fluxbb-data container:

```
docker run -it --volumes-from fluxbb-data -v $(pwd):/extern phusion/baseimage:0.9.16 /sbin/my_init -- bash
```
Starts a basic container with an link to the data container (mounted at `/data`)
and to your local files (mounted at `/extern`).

Copy the `config.php`:
```
cp /extern/some/path/config.php /data/fluxbb/
```


### Backup

A script called `/etc/cron.daily/backup-mysql` creates a daily dump of the
database configured for this installation. By default, the dump is
placed into `/data/backup` and dumps older than 14 days are deleted.

The idea is to mount the `/data` volume of `fluxbb-data` from another
container and then create an off-site backup of the entire folder:

```
docker run --volumes-from fluxbb-data -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /data
```

Or use [raumzeitlabor/backup-docker](https://github.com/raumzeitlabor/backup-docker) for this.
