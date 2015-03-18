#!/bin/bash

#
# Variables
#
source ../conf/opentsdb.conf

#
# Parse cmdline
#
if [ $# -ne 1 ]; then
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
echo -e "## Starting OpenTSDB Table Creation on $node"
echo -e "##"

# Validate that HBase is installed
echo -e "\n#### Checking to see if HBase is installed"
if ! ssh $SSH_ARGS $node "test -d $HBASE_HOME"; then
    echo "ERROR: HBase does not appear to be installed at $HBASE_HOME"
    exit 1
fi

# Validate that node is running the HMaster process
echo -e "\n#### Checking to see if HBase Master is running on $node"
if ! ssh $SSH_ARGS $node "ps -ef | grep proc_master | grep -v grep | grep -q proc_master"; then
    echo "ERROR: HBase Master not running on $node"
    exit 1
fi

# Install git, autoconf
echo -e "\n#### Installing git, and automake"
ssh $SSH_ARGS $node "yum install -y git automake" || exit 1

# Build opentsdb
echo -e "\n#### Cloning OpenTSDB git repo"
if ssh $SSH_ARGS $node "test -d /tmp/opentsdb"; then
    echo "WARNING: /tmp/opentsdb already exists... running git pull"
    ssh $SSH_ARGS $node "cd /tmp/opentsdb && git pull" || exit 1
else
    ssh $SSH_ARGS $node "cd /tmp && git clone git://github.com/OpenTSDB/opentsdb.git" || exit 1
fi

# Run the opentsdb build script
echo -e "\n#### Running the OpenTSDB build script"
ssh $SSH_ARGS $node "cd /tmp/opentsdb && PATH=$PATH:$JAVA_BIN ./build.sh" || exit 1

# Create hbase table if not already created
echo -e "\n#### Creating OpenTSDB HBase tables if needed"
if ssh $SSH_ARGS $node "curl -s $HBASE_WEB_TABLE_LIST | grep -q tsdb-uid"; then
    echo "WARNING: OpenTSDB tables already exist... skipping"
else
    ssh $SSH_ARGS $node "cd /tmp/opentsdb && env COMPRESSION=SNAPPY HBASE_HOME=$HBASE_HOME ./src/create_table.sh" || exit 1
fi

echo -e "\n##"
echo -e "## Successfully completed OpenTSDB Table Creation on $node"
echo -e "##"

exit 0
