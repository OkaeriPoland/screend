#!/bin/sh
### BEGIN INIT INFO
# Provides:          screend
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Required-Start:    $all
# Short-Description: screend init script
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="screend"
NAME="screend"
CWD=/root/screend
USER=root
GROUP=root
EXEC=/root/screend/screend
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

# Increase open files limit
ulimit -n 515214

# Make sure we have started with system locale
if [ -r /etc/default/locale ]; then
        . /etc/default/locale
        export LANG
fi

#
# Function that starts the daemon/service
#
do_start()
{
  # Return
  #   0 if daemon has been started
  #   1 if daemon was already running
  #   2 if daemon could not be started
  start-stop-daemon --start \
    --quiet \
    --pidfile $PIDFILE \
    --user $USER \
    --exec $EXEC \
    --test > /dev/null \
    || return 1
  start-stop-daemon --start \
    --quiet \
    --make-pidfile \
    --pidfile $PIDFILE \
    --chuid $USER \
    --user $USER \
    --group $GROUP \
    --chdir $CWD \
    --background \
    --exec $EXEC \
    || return 2
}

#
# Function that stops the daemon/service
#
do_stop()
{
  # Return
  #   0 if daemon has been stopped
  #   1 if daemon was already stopped
  #   2 if daemon could not be stopped
  #   other if a failure occurred
  start-stop-daemon --stop \
    --quiet \
    --user $USER \
    --pidfile $PIDFILE \
    --exec $EXEC \
    --retry=TERM/30/KILL/5
  RETVAL="$?"
  [ "$RETVAL" = 2 ] && return 2
  rm -f $PIDFILE
  return "$RETVAL"
}

#
# Function that checks if the daemon is running
#
do_status()
{
  start-stop-daemon \
    --start \
    --test \
    --oknodo \
    --pidfile $PIDFILE \
    --user $USER \
    --exec $EXEC
}

case "$1" in
  start)
  [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
  do_start
  case "$?" in
    0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
    2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
  esac
  ;;

  stop)
  [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
  do_stop
  case "$?" in
    0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
    2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
  esac
  ;;

  status)
  do_status
  ;;

  restart|force-reload)

  log_daemon_msg "Restarting $DESC" "$NAME"
  do_stop
  case "$?" in
    0|1)
    do_start
    case "$?" in
      0) log_end_msg 0 ;;
      1) log_end_msg 1 ;; # Old process is still running
      *) log_end_msg 1 ;; # Failed to start
    esac
    ;;
    *)
    # Failed to stop
    log_end_msg 1
    ;;
  esac
  ;;
  *)
  echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
  exit 3
  ;;
esac
