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

# Create TSD log dir
echo -e "\n#### Creating the TSD log dir $TSD_LOG_DIR"
ssh $SSH_ARGS $node "mkdir -p $TSD_LOG_DIR" || exit 1

# Creating the CLI wrapper
echo -e "\n#### Creating the CLI wrapper script"
ssh $SSH_ARGS $node "echo \"cd $TSD_HOME && ./build/tsdb \$\"@\" --zkquorum=$ZK_QUORUM --zkbasedir=$ZK_HBASE_ROOT\" >$TSD_HOME/tsdb.cli && chmod 755 $TSD_HOME/tsdb.cli"  || exit 1

echo -e "\n##"
echo -e "## Successfully completed OpenTSDB TSD install on $node"
echo -e "##"
