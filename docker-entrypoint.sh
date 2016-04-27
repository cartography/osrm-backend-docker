#!/bin/bash
DATA_PATH=${DATA_PATH:="/osrm-data"}
set -e

_sig() {
  kill -TERM $child 2>/dev/null
}

if [ "$1" = 'osrm' ]; then
  trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

  if [ ! -f profiles/$2.lua ]; then
    echo "You need to give a valid profile name as argument. Invalid: $2"
    echo "You can choose from the following:"
    ls profiles | grep lua | cut -d. -f 1
    exit 1
  fi

  if [ ! -f $DATA_PATH/$2.osrm ]; then
    if [ ! -f $DATA_PATH/$2.osm.pbf ]; then
      curl $3 > $DATA_PATH/$2.osm.pbf
    fi
    ./osrm-extract -p profiles/$2.lua $DATA_PATH/$2.osm.pbf
    ./osrm-contract $DATA_PATH/$2.osrm
  fi

  ./osrm-routed $DATA_PATH/$2.osrm --max-table-size 8000 &
  child=$!
  wait "$child"
else
  exec "$@"
fi
