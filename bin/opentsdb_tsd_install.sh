#!/bin/bash

#
# Variables
#
. /tmp/opentsdb-examples/conf/opentsdb.conf

#
# Sanity Checks
#
if [ `id -un` != "root" ]; then
   echo "ERROR: Must be run as root"
   exit 1
fi

#
# Main
#

for node in $TSD_HOST_LIST; do

   echo -e "\n##"
   echo -e "## Starting OpenTSDB TSD install on $node"
   echo -e "##"

   # Install git, automake, and gnuplot
   echo -e "\n#### Installing git, gnuplot, and automake"
   ssh $SSH_ARGS $node "yum install -y git gnuplot automake" || exit 1

   # Build opentsdb
   echo -e "\n#### Cloning OpenTSDB git repo and switching to \"next\" branch"
   if ssh $SSH_ARGS $node "test -d $TSD_HOME/.git"; then
      echo "WARNING: /tmp/opentsdb already exists... skipping"
   else
      ssh $SSH_ARGS $node "cd $(dirname $TSD_HOME) && git clone git://github.com/OpenTSDB/opentsdb.git && cd $TSD_HOME && git checkout next" || exit 1
   fi

   # Run the opentsdb build script
   echo -e "\n#### Running the OpenTSDB build script"
   ssh $SSH_ARGS $node "cd $TSD_HOME && PATH=$PATH:$JAVA_BIN ./build.sh" || exit 1

   # Create tmpfs filesystem for tsd cache storage
   echo -e "\n#### Creating tmpfs filesystem for tsd cache storage if needed"
   ssh $SSH_ARGS $node "mkdir -p $TSD_CACHE_DIR" || exit 1
   if ssh $SSH_ARGS $node "mount | grep $TSD_CACHE_DIR"; then
      echo "WARNING: tmpfs $TSD_CACHE_DIR already mounted"
   else
      ssh $SSH_ARGS $node "mount -t tmpfs -o size=10g,mode=0777 tmpfs $TSD_CACHE_DIR" || exit 1
      ssh $SSH_ARGS $node "df -h $TSD_CACHE_DIR" || exit 1
   fi

   # Create TSD log dir
   echo -e "\n#### Creating the TSD log dir $TSD_LOG_DIR"
   ssh $SSH_ARGS $node "mkdir -p $TSD_LOG_DIR" || exit 1

   # Starting the TSD
   echo -e "\n#### Starting the TSD at $node:$TSD_PORT"
   if ssh $SSH_ARGS $node "ps -ef | grep TSDMain | grep -v grep | grep -q TSDMain"; then
      echo "WARNING: TSD is already running... skipping"
   else
      ssh $SSH_ARGS $node "echo \"cd $TSD_HOME && ./build/tsdb tsd --port=$TSD_PORT --staticroot=build/staticroot --cachedir $TSD_CACHE_DIR --zkquorum=$ZK_QUORUM --zkbasedir=$ZK_HBASE_ROOT --auto-metric >$TSD_LOG_DIR/opentsdb.log 2>&1\" | at now" || exit 1
   fi

   echo -e "\n##"
   echo -e "## Successfully completed OpenTSDB TSD install on $node"
   echo -e "##"
done
