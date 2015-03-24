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

# Download the data sets
echo -e "\n#### Downloading and extracting the datasets"
for dataSet in $CRIMES_DATA $WEATHER_DATA; do
  echo "Downloading and extracting $dataSet"
  cd /tmp && wget -N $dataSet
  fileName=$(echo $dataSet | awk -F\/ '{print $NF}')
  cd /tmp && tar -xvzf $fileName
done

# Copying the data into HDFS
echo -e "\n#### Loading sample data into HDFS at $SAMPLE_DATA_HDFS_DIR"
if hdfs dfs -test -d $SAMPLE_DATA_HDFS_DIR; then
  hdfs dfs -rm -r $SAMPLE_DATA_HDFS_DIR
fi
hdfs dfs -mkdir $SAMPLE_DATA_HDFS_DIR

for dataSet in weather crime; do
  fileName=${dataSet}__2010_to_present.csv.csv"
  echo "Putting /tmp/$fileName into HDFS"
  hdfs dfs -put /tmp/$fileName $SAMPLE_DATA_HDFS_DIR
done

exit 0
