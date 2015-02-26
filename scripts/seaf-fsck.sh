#!/bin/bash

echo ""

SCRIPT=$(readlink -f "$0")
INSTALLPATH=$(dirname "${SCRIPT}")
TOPDIR=$(dirname "${INSTALLPATH}")
default_ccnet_conf_dir=${TOPDIR}/ccnet
seaf_fsck=${INSTALLPATH}/seafile/bin/seaf-fsck
seaf_fsck_opts=""

export PATH=${INSTALLPATH}/seafile/bin:$PATH
export SEAFILE_LD_LIBRARY_PATH=${INSTALLPATH}/seafile/lib/:${INSTALLPATH}/seafile/lib64:${LD_LIBRARY_PATH}

script_name=$0
function usage () {
    echo "usage : "
    echo "$(basename ${script_name}) [repair] "
    echo ""
}


function validate_ccnet_conf_dir () {
    if [[ ! -d ${default_ccnet_conf_dir} ]]; then
        echo "Error: there is no ccnet config directory."
        echo "Have you run setup-seafile.sh before this?"
        echo ""
        exit -1;
    fi
}

function read_seafile_data_dir () {
    seafile_ini=${default_ccnet_conf_dir}/seafile.ini
    if [[ ! -f ${seafile_ini} ]]; then
        echo "${seafile_ini} not found. Now quit"
        exit 1
    fi
    seafile_data_dir=$(cat "${seafile_ini}")
    if [[ ! -d ${seafile_data_dir} ]]; then
        echo "Your seafile server data directory \"${seafile_data_dir}\" is invalid or doesn't exits."
        echo "Please check it first, or create this directory yourself."
        echo ""
        exit 1;
    fi
}

function run_seaf_fsck () {
    validate_ccnet_conf_dir;
    read_seafile_data_dir;

    echo "Starting seaf-fsck, please wait ..."
    echo

    LD_LIBRARY_PATH=$SEAFILE_LD_LIBRARY_PATH ${seaf_fsck} \
        -c "${default_ccnet_conf_dir}" -d "${seafile_data_dir}" \
        ${seaf_fsck_opts}

    echo "seaf-fsck run done"
    echo
}

if [ $# -eq 0 ];
then
    run_seaf_fsck;
elif [ $# -eq 1 -a "$1" = "repair" ];
then
    seaf_fsck_opts="-r"
    run_seaf_fsck;
else
    usage;
    exit 1;
fi

echo "Done."
