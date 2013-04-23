#!/bin/bash
PIDFILE="/home/radja/rsyncd.pid"
RSYNC_CONFIG="/home/radja/.snap-rsyncd.conf"
RSYNC_LOG="/home/radja/rsync.log"
LOG="/home/radja/create-snapshot.log"
USER="radja"
RUSER="${USER}"
LOCALPORT=9999
REMOTEPORT=8888
REMOTEHOST="external"
PID=""
CMD="hourly"

{
    for i in monthly weekly daily hourly; do
        [ -n "`echo $@ | grep $i`" ] && CMD=$i
    done

    echo Starting: `date`
    [ -f ${PIDFILE} ] && echo "ERROR: ${PIDFILE} already exists" >&2 && exit 1
    trap '[ -n "${PID}" ] && kill ${PID}' SIGHUP SIGINT SIGQUIT SIGTERM

    rsync --daemon --config="${RSYNC_CONFIG}" --address=127.0.0.1 --port="${LOCALPORT}" --log-file="${RSYNC_LOG}" -v
    sleep 3
    [ -f ${PIDFILE} ] || { echo "ERROR: ${PIDFILE} doesn't exists" >&2 && exit 2; }
    PID=`cat ${PIDFILE}`
    sudo -u "${USER}" -H ssh -R localhost:${REMOTEPORT}:localhost:"${LOCALPORT}" "${RUSER}"@"${REMOTEHOST}" sudo snapshot-hourly.sh "$CMD"

    ##{ ps p ${PID} >& /dev/null && ps p $! >& /dev/null; } || echo "ERROR: Some of necessary processes does not exist" >&2 && cleanup_and_exit 2
    ##sudo -Hu radja ssh radja@"${REMOTEHOST}" sudo snapshot-hourly.sh

    #assert $PID
    [ -n "${PID}" ] && kill ${PID}

    # TODO: send e-main messages

    # TODO: clean it
    # TODO: check all configuration files (and executable files) have correct permissions (root only write) if we launch process by root
    # TODO: more consistent programms' names and conf- files' names
    # TODO: configuration files for "server" and "client" scripts (port for communication etc)
    # TODO: back backups (from server to laptop): database and web-applications
    echo Ending: `date`
} 1>>${LOG} 2>&1
