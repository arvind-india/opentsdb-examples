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

for node in $TCOLL_HOST_LIST; do

   echo -e "\n##"
   echo -e "## Starting tcollector install on $node"
   echo -e "##"

   # Install git
   echo -e "\n#### Installing git"
   ssh $SSH_ARGS $node "yum install -y git" || exit 1

   # Install python module ordereddict
   echo -e "\n#### Installing python ordereddict"
   ssh $SSH_ARGS $node "easy_install ordereddict" || exit 1

   # Clone tcollector git repo
   echo -e "\n#### Cloning tcollector git repo"
   if ssh $SSH_ARGS $node "test -d /tmp/tcollector"; then
      echo "WARNING: /tmp/tcollector already exists... skipping"
   else
      ssh $SSH_ARGS $node "cd /tmp && git clone https://github.com/OpenTSDB/tcollector.git" || exit 1
   fi

   # Move the tcollector to TCOLL_HOME
   echo -e "\n#### Moving tcollector into $TCOLL_HOME"
   ssh $SSH_ARGS $node "mkdir -p $TCOLL_HOME && cp -R /tmp/tcollector/* $TCOLL_HOME/" || exit 1

   # Set TSD address in startstop script
   echo -e "\n#### Setting variables in the tcollector init script"
   scp $SSH_ARGS /tmp/opentsdb-examples/etc/init.d/tcollector $node:/etc/init.d/
   ssh $SSH_ARGS $node "sed -i 's|^.*#.*TSD_HOST=.*|TSD_HOST='$TSD_VIP'|g' /etc/init.d/tcollector" || exit 1
   ssh $SSH_ARGS $node "sed -i 's|^.*#.*TSD_PORT=.*|TSD_PORT='$TSD_PORT'|g' /etc/init.d/tcollector" || exit 1
   ssh $SSH_ARGS $node "sed -i 's|^.*TCOLLECTOR_PATH=.*|TCOLLECTOR_PATH='$TCOLL_HOME'|g' /etc/init.d/tcollector" || exit 1

   # Starting the TSD
   echo -e "\n#### Starting the tcollector on $node"
   ssh $SSH_ARGS $node "service tcollector restart" || exit 1

   echo -e "\n##"
   echo -e "## Successfully completed OpenTSDB TSD install on $node"
   echo -e "##"
done
