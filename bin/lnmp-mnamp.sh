#!/bin/bash

set -ex

print_help_info(){
  exec echo -e "
Usage:

lnmp-mnamp.sh {start | restart | stop} {SOFT_NAME | all | common}

lnmp-mnamp.sh status

Example:

lnmp-mnamp.sh start php nginx mysql redis

lnmp-mnamp.sh stop common
"
}

################################################################################

COMMON_SOFT="nginx php mysql redis"

################################################################################

function _start(){
    for soft in "$@"
    do
    echo -e "\nStart $soft ...\n"
    case "$soft" in
      redis )
          if ! [ -f /usr/local/var/run/redis.log ];then sudo touch /usr/local/var/run/redis.log; fi
          sudo redis-server \
              --logfile /usr/local/var/run/redis.log \
              --dir /tmp \
              --bind 127.0.0.1 \
              --appendonly yes \
              --pidfile /usr/local/var/run/redis.pid \
              --daemonize yes
      ;;

      mongodb )
          sudo mongod \
              --config /usr/local/etc/mongod.conf \
              --pidfilepath /usr/local/var/run/mongodb.pid
      ;;

      memcached )
          sudo memcached \
              -uroot \
              -d \
              -P /usr/local/var/run/memcached.pid
      ;;

      php )
          php-fpm \
              -D \
              -R \
              -g /usr/local/var/run/php-fpm.pid
      ;;

      nginx )
          sudo nginx -t
          # sudo nginx -g "pid /run/nginx.pid;"
          sudo nginx
      ;;

      mysql )
          mysql.server start
      ;;

      postgresql )
          pg_ctl -D /usr/local/var/postgres start
      ;;
esac
done
}

function _stop(){
  for soft in "$@"
  do
    echo -e "\nStop $soft ... \n"
  case "$soft" in
    php )
        sudo kill $(cat /usr/local/var/run/php-fpm.pid)
    ;;

    nginx )
        # sudo nginx -s stop -g "pid /run/nginx.pid;"

        sudo nginx -s stop
    ;;

    redis )
        redis-cli shutdown
    ;;

    memcached )
        sudo kill $(cat /usr/local/var/run/memcached.pid)
    ;;

    mongodb )
        sudo kill $(cat /usr/local/var/run/mongodb.pid)
    ;;

    mysql )
        mysql.server stop
    ;;

    postgresql )
        pg_ctl -D /usr/local/var/postgres stop
    ;;
  esac
done
}

_restart(){
  for soft in "$@"
  do
  _stop $soft
  _start $soft
done
}

if [ -z "$1" ];then
    print_help_info
fi

if [ "$1" = stop ];then
  shift
  if [ "$1" = 'all' ];then
    set +e
    clear
    _stop nginx mysql php redis memcached mongodb postgresql
    exit 0
  elif [ "$1" = 'common' ];then
    set +e
    clear
    for soft in $COMMON_SOFT
      do
      _stop $soft
      done
    exit 0
  fi
  _stop "$@"
  exit 0
fi

if [ "$1" = start ];then
  shift
  if [ "$1" = 'all' ];then
    set +e
    clear
    _start nginx mysql php redis memcached mongodb postgresql
    exit 0
  elif [ "$1" = 'common' ];then
    set +e
    clear
    for soft in $COMMON_SOFT
      do
      _start $soft
      done
    exit 0
  fi

  _start "$@"
  exit 0
fi

if [ "$1" = restart ];then
  shift
  if [ "$1" = 'all' ];then
    set +e
    clear
    _restart nginx mysql php redis memcached mongodb postgresql
    exit 0
  elif [ "$1" = 'common' ];then
    set +e
    clear
    for soft in $COMMON_SOFT
      do
      _restart $soft
      done
    exit 0
  fi
  _restart "$@"
  exit 0
fi

if [ "$1" = 'status' ];then
    ps aux | grep nginx --color=auto
    echo "====>"
    ps aux | grep php-fpm --color=auto
    echo "====>"
    ps aux | grep mysql --color=auto
    echo "====>"
    ps aux | grep redis-server --color=auto
    echo "====>"
    ps aux | grep memcached --color=auto
    echo "====>"
    ps aux | grep mongod --color=auto
    echo "====>"
    ps aux | grep postgres --color=auto
fi
