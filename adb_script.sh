#!/bin/bash

echo "ADB script for debugging or deploying android app to Physical Phone via WIFI"

VERSION="1.0.0"
ADB_PATH=$(which adb)
IP=""
attach_status="0"
deattach_status="0"

function _initialize() {
    if [[ "$attach_status" = *"0"* ]]; then
        adb start-server
        attach_status="1"
        echo "Please attach your phone to PC!"
    fi
    ADB_OUT=`$ADB_PATH devices | awk 'NR>1 {print $1}'`

    if ! test -n "$ADB_OUT"; then
        _initialize
    fi
}

function _start() {
    if [[ "$deattach_status" = *"0"* ]]; then
        IP=$(adb shell "ip addr show wlan0 | grep -e wlan0$ | cut -d\" \" -f 6 | cut -d/ -f 1")
        adb root
        adb tcpip 5555
        adb connect "$IP:5555"
        deattach_status="1"
        echo "Please de-attach your phone!"
    fi

    if test -n "$ADB_OUT"; then
        _start
    fi
}

function _stop() {
    adb kill-server
    echo "Service is stopped"
}

function _usage() {
  ###### U S A G E : Help and ERROR ######
    cat <<EOF
    Welcome to adb wifi $Options
    $*
        Usage: adbwifi <[options]>
        Options:
                -v   --version        Shows the version of script
                -i   --initialize     Initialize adb for the system. During this step please connect your phone to PC
                -s   --stop           It enables to stop adb
                -d   --deploy         It enables to debug or deploy the app
                -h   --help           Show this message
EOF
}

[ $# = 0 ] && _usage " no options given "

while getopts ':vhisdA:' OPTION ; do
  case "$OPTION" in
    v  ) echo "$VERSION created By Kaan Legolas Köken" ;;
    h  ) _usage                                        ;;
    i  ) _initialize                                   ;;
    d  ) _start                                        ;;
    s  ) _stop                                         ;;
    -  ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
        eval OPTION="\$$optind"
        OPTARG=$(echo $OPTION | cut -d'=' -f2)
        OPTION=$(echo $OPTION | cut -d'=' -f1)
        case $OPTION in
            --version    ) echo "$VERSION created By Kaan Legolas Köken" ;;
            --initialize ) _initialize                                   ;;
            --stop       ) _stop                                         ;;
            --debug      ) _start                                        ;;
            --help       ) _usage                                        ;;
            * )  _usage " Long: >>>>>>>> invalid options (long) " ;;
        esac
        OPTIND=1
        shift
        ;;
    ? )  _usage "Short: >>>>>>>> invalid options (short) "  ;;
  esac
done