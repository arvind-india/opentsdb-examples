#!/bin/bash

#
# Variables
#
source ./opentsdb.conf

#
# Parse cmdline
#
if [ $# -gt 1 ]; then
   echo "ERROR: Must supply hostname to install on"
   exit 1
fi
node="$1"

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

# Set TSD address in startstop script
echo -e "\n#### Setting variables in the tcollector init script"
ssh $SSH_ARGS $node "sed -i 's|^.*#.*TSD_HOST=.*|TSD_HOST='$TSD_VIP'|g' /tmp/tcollector/startstop" || exit 1
ssh $SSH_ARGS $node "sed -i 's|^.*TCOLLECTOR_PATH=.*|TCOLLECTOR_PATH='$TCOLL_HOME'|g' /tmp/tcollector/startstop" || exit 1

# Move the tcollector to TCOLL_HOME
echo -e "\n#### Moving tcollector into $TCOLL_HOME"
ssh $SSH_ARGS $node "mkdir -p $TCOLL_HOME && cp -R /tmp/tcollector/* $TCOLL_HOME/" || exit 1

# Copy the init script
echo -e "\n#### Copying the tcollector init script to /etc/init.d"
ssh $SSH_ARGS $node "cp /tmp/tcollector/startstop /etc/init.d/tcollector" || exit 1

# Starting the TSD
echo -e "\n#### Starting the tcollector on $node"
ssh $SSH_ARGS $node "service tcollector start" || exit 1

echo -e "\n##"
echo -e "## Successfully completed OpenTSDB TSD install on $node"
echo -e "##"
