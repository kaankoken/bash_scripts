#!/bin/bash

FILE=~/.local_git_config
GIT=./.git

ARG1=""
ARG2=""
VERSION="1.0.0"

create_title="Your information is already exist. Would you like to update it? (Y/n) "
renew_title="Your information does not exist. Would you like to create it? (Y/n) "
update_account="Your information is updated!!!"
create_account="Your information is saved!!!"

function assign_inputs() {
    if [ ! -z "$1" ]; then
        ARG1="$1"
    fi

    if [ ! -z "$2" ]; then
        ARG2="$2"
    fi
}

function get_inputs() {
    title="$1"
    read -p "Enter email: " ARG1
    read -p "Enter username: " ARG2

    read -p "Are you confirm this information? (Y/n) " answer
    if [[ "$answer" == "" ]] || [ $answer == Y ] || [ $answer == y ]; then
        save_to_file
        echo "$title"
    else
        get_inputs "$title"
    fi
}

function save_to_file() {
    echo -e 'email="'"$ARG1"'"\nusername="'"$ARG2"'"' > "$FILE"
}

function _renew_info() {
    if [ ! -f "$FILE" ]; then
        read -p "$1" answer
        if  [[ "$answer" == "" ]] || [ $answer == Y ] || [ $answer == y ]; then
            get_inputs "$update_account"
        else
            exit
        fi
    else
        get_inputs "$update_account"
    fi
}

function _create_info() {
    if [ -f "$FILE" ]; then
        read -p "$1" answer
        if  [[ "$answer" == "" ]] || [ $answer == Y ] || [ $answer == y ]; then
            get_inputs "$create_account"
        else
            exit
        fi
    else
        get_inputs "$create_account"
    fi
}

function _update_local_git() {
    while read line; do
        eval $line;
        ARG1=$email; ARG2=$username
    done < "$FILE"

    git config user.email "$ARG1"
    git config user.name "$ARG2"
    echo "Local git user is changed!!!"
}

function _initialize_local_git() {
    if [ ! -d "$GIT" ]; then
        git init
    else
        read -p "Your git is being initialized. Would you like to reinitialize? (Y/n) " answer
        if  [[ "$answer" == "" ]] || [ $answer == Y ] || [ $answer == y ]; then
            git init;
        fi
    fi
    _update_local_git
}

function _initialize_local_repo() {
    _initialize_local_git
    OUTPUT=$(git remote -v)

    if [ ! "${OUTPUT}" == "" ]; then
        echo "${OUTPUT}"
    else
        read -p "Please enter remote address" remote
        git remote add origin "$remote"
    fi
}

function _usage() {
  ###### U S A G E : Help and ERROR ######
    cat <<EOF
    Welcome to local github account assigner $Options
    $*
        Usage: localgit <[options]>
        Options:
                -v   --version        Shows the version of script
                -c   --create         Save github account info to local and changes it for you
                -r   --renew          Renew the account information
                -i   --initialize     Attach given accounts to project
                -l   --local          Initialize local repository from beginning
                -h   --help           Show this message
                -A   --arguments=...  Set arguments to yes ($arguments) AND get ARGUMENT ($ARG)
                -F   --foobar         Set foobar to yes ($foobar)
EOF
}

[ $# = 0 ] && _usage " no options given "

while getopts ':vcrhi-A:F' OPTION ; do
  case "$OPTION" in
    v  ) echo "$VERSION created By Kaan Legolas Köken" ;;
    c  ) _create_info "$create_title"                  ;;
    r  ) _renew_info "$renew_title"                    ;;
    h  ) _usage                                        ;;
    i  ) _initialize_local_git                         ;;
    l  )                                               ;;
    A  ) sarguments=yes;sARG="$OPTARG"                 ;;
    F  ) sfoobar=yes                                   ;;
    -  ) [ $OPTIND -ge 1 ] && optind=$(expr $OPTIND - 1 ) || optind=$OPTIND
        eval OPTION="\$$optind"
        OPTARG=$(echo $OPTION | cut -d'=' -f2)
        OPTION=$(echo $OPTION | cut -d'=' -f1)
        case $OPTION in
            --version    ) echo "$VERSION created By Kaan Legolas Köken" ;;
            --renew      ) _renew_info "$renew_title"                    ;;
            --create     ) _create_info "$create_title"                  ;;
            --initialize ) _initialize_local_git                         ;;
            --local      )                                               ;;
            --foobar     ) lfoobar=yes                                   ;;
            --help       ) _usage                                        ;;
            --arguments  ) larguments=yes;lARG="$OPTARG"                 ;; 
            * )  _usage " Long: >>>>>>>> invalid options (long) " ;;
        esac
        OPTIND=1
        shift
        ;;
    ? )  _usage "Short: >>>>>>>> invalid options (short) "  ;;
  esac
done