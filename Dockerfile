FROM quay.io/rockylinux/rockylinux:9-minimal


RUN microdnf upgrade -y && microdnf install git gcc SDL2-devel wget zip rsync tmux -y
RUN mkdir /build
RUN pushd /build && git clone https://github.com/ioquake/ioq3.git

# https://discourse.ioquake.org/t/error-compiling-on-arch-linux-sdl-version-h-no-such-file-or-directory/1858
RUN pushd /build/ioq3/ && make SDL_CFLAGS="-I/usr/include/SDL2 -D_REENTRANT" SDL_LIBS="-lSDL2"

RUN mv /build/ioq3/build/release-linux-x86_64 /ioq3

RUN pushd /tmp && wget https://files.ioquake3.org/quake3-latest-pk3s.zip
RUN unzip /tmp/quake3-latest-pk3s.zip -d /quake_tmp
RUN rsync -av /quake_tmp/quake3-latest-pk3s/* /ioq3/.
RUN rm -rf /quake_tmp /tmp/quake3-latest-pk3s.zip /build

COPY start.sh /start.sh
COPY base.cfg /ioq3/baseq3/base.cfg

ENTRYPOINT [ "/start.sh" ]
# /ioq3/ioq3ded.x86_64 +set dedicated 2 +set sv_allowDownload 1 +set sv_dlURL \"\" +set com_hunkmegs 64 +set gamemode ctf
# map q3ctf4