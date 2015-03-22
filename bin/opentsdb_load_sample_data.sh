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

echo -e "\n##"
echo -e "## Starting sample data load from $(hostname)"
echo -e "##"

# Validate that HBase is installed
echo -e "\n#### Downloading the datasets"
for dataSet in $CRIMES_DATA $WEATHER_DATA; do
  echo "Downloading $dataSet"
  cd /tmp && wget $dataSet
done

exit 0
