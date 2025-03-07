# ioquake3 dedicated server docker container
This repo contains the tooling and CI/CD to build and run a containerized version of [ioquake3](https://github.com/ioquake/ioq3)

## Quickstart

> Note: both of the examples below assume you are running Steam in a default location on the linux system and have our legally purchased Quake 3: Arena copy in the location specified below. See the **[Sourcing Quake 3: Arena `pak0.pk3`](#sourcing-quake-3-arena-pak0pk3)** for more information about 

- Clone this git repo
- Make sure you have docker/podman installed on your system
- Copy the `cfg-example` directory to `cfg`
- Then either launch with Docker or Docker Compose:

Docker CLI example:
```bash
docker run -it --rm -p 27961:27961/udp \
  -v "${HOME}/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/Quake 3 Arena/baseq3/pak0.pk3:/data/pak0.pk3" \
  -v "$(pwd)/cfg:/data/cfg" \
  -e EXTRA_ARGS="+set dedicated 1 +set com_hunkmegs 64 +set sv_maxclients 16 +set sv_maxclients 16" \
  ghcr.io/mddeff/ioq3-container:main
```

Docker-compose example:
```bash
docker-compose up -d
```

## Using the container image

### Sourcing Quake 3: Arena `pak0.pk3`
As with the upstream project, the user must provide the `pak0.pk3` from a **Licensed copy of Quake 3: Arena**.  To that end, we provide a few ways to bootstrap that file in.

#### Mounting into `/data/pak0.pk3`
If you mount the file into the docker container under `/data/pak0.pk3`, the startup script will find that file, symlink it into the right place (`/ioq3/base3q/pak0.pk3`) and continue with startup.

> Note: If you set the container environment variable `FORCE_DOWNLOAD` to `true`, then the script will skip symlinking in the file, even if it is present.

#### Downloading the file with `PAK0_URL`
If the startup script cannot find `pak0.pk3` on the filesystem (or `FORCE_DOWNLOAD` is `true`), then the script will attempt to download the file from the url provided in the environment variable `PAK0_URL`.

If neither of these options succeed, the script will exit with a `255` return code, and the container will error out.

### Config Files
During startup the `/data/cfg` directory gets symlinked into /ioq3/baseq3 so that you can access the config files via the exec command.

For example, if you have `/data/cfg/ctf4.cfg`, then you'll be able to exec that config in the server console/`rcon` with `exec cfg/ctf4.cfg`

Additionally, if you have `/data/cfg/q3config_server.cfg`, we'll symlink that into `/ioq3/baseq3/q3config_server.cfg` so that it gets automatically executed on launch.  This will be your default server config.

### Environment Variables
In addition to the `FORCE_DOWNLOAD` and `PAK0_URL` described [above](#sourcing-quake-3-arena-pak0pk3), we also provide an `EXTRA_ARGS` environment variable that will append anything to the end of the ioq3ded.x86_64 launch command.

If left undefined, you'll get the following by default:
```bash
/ioq3/ioq3ded.x86_64 +logfile 3 +set dedicated 1 +set sv_allowDownload 1 +set sv_dlURL \"\" +set com_hunkmegs 64 +set net_port 27961
```
If `EXTRA_ARGS` is set, you'll get:
```bash
/ioq3/ioq3ded.x86_64 +logfile 3 ${EXTRA_ARGS}
```

`logfile 3` is always there as it's needed for the console log to make the container work.

## Accessing the local server console log
Because containers don't typically start with TTYs, we use `tmux` to run the server, and then tail the output.  This allows you to attach to the container and access server console directly if needed:

```bash
# from your docker host
docker exec -it container_name_here /bin/bash

# you'll get a shell in the container, then:
tmux attach
```

## Author
Mike D
- https://zeroent.net
- https://schemesandnotions.io

## Legal
This container image is distributed under GPLv2.0, the same as the original source code from [ioquake3](https://github.com/ioquake/ioq3).  The built container image also contains the Patch data from https://ioquake3.org/extras/patch-data/.  Utilizing this image, building it using the tooling in this repo, or pulling the image from any registry constitutes concurrence with the EULA found at https://ioquake3.org/extras/patch-data/ or [a copy of the EULA in this repo](./ID_EULA.txt)

All product names, trademarks, and registered trademarks are the property of their respective owners. The use of these names, trademarks, and brands does not imply endorsement or affiliation.

This project is provided "as is" without any warranty of any kind, either express or implied. Use at your own risk.