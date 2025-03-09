#!/bin/bash

# show ID eula
show_eula () {
    echo "By using this container, you agree to the ioquake3/ID Software EULA found at https://ioquake3.org/extras/patch-data/ or https://github.com/mddeff/ioq3-container/ID_EULA.txt"
}

# get pack0.pk3 onboard somehow
pak0_setup () {
    # check if pak0.pk3 is present in /data
    echo "Checking for pak0.pk3"

    if [ -f "/data/pak0.pk3" ] && [ "$FORCE_DOWNLOAD" != "true" ]; then
        echo "/data/pak0.pk3 found, symlinking."
        ln -sf /data/pak0.pk3 /ioq3/baseq3/pak0.pk3
    elif [ -n "$PAK0_URL" ]; then
        echo "Downloading pak0.pk3 from $PAK0_URL"
        pushd /ioq3/baseq3/ && wget -nv $PAK0_URL pak0.pk3
    else
        echo "FATAL - Couldn't get pak0.pk3, check the the readme for more information https://github.com/mddeff/ioq3-container/readme.md#sourcing-quake-3-arena-pak0pk3"
        exit 255
    fi

}

symlink_cfgs () {
    # symlink in autostart cfg
    if [ -f /data/cfg/q3config_server.cfg ]; then
        echo "Linking in /data/cfg/q3config_server.cfg for default configuration"
        ln -sf /data/cfg/q3config_server.cfg /ioq3/baseq3/q3config_server.cfg
    fi
    # symlink in directory of configs that user may have provided
    if [ -d /data/cfg ]; then
        echo "Linking in cfg directory for console use"
        ln -sf /data/cfg /ioq3/baseq3/cfg
    fi

}

start_server () {

    CMD="/ioq3/ioq3ded.x86_64 +logfile 3 ${EXTRA_ARGS:-+set dedicated 1 +set sv_allowDownload 1 +set sv_dlURL \"\" +set com_hunkmegs 64 +set net_port 27960 +set g_Gametype 4 +map q3ctf4 +set bot_minplayers 10}"

    # Execute the command
    echo "##########################################################################################################"
    echo "# STARTING ioquake3 with: $CMD"
    echo "# Starting in TMUX session, if you need a console, shell into this container and run 'tmux attach' "
    echo "##########################################################################################################"

    tmux new-session -d "$CMD"
    sleep 2
    tail -n 100 -f /root/.q3a/baseq3/qconsole.log
    

}

# MAIN
show_eula
pak0_setup
symlink_cfgs
start_server
