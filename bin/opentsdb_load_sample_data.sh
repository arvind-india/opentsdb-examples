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

# Prepare to copy data
for dataSet in weather crime; do
   echo -e "\n#### Creating $SAMPLE_DATA_HDFS_DIR/$dataSet in HDFS"
   if hdfs dfs -test -d $SAMPLE_DATA_HDFS_DIR/$dataSet; then
      hdfs dfs -rm -r $SAMPLE_DATA_HDFS_DIR/$dataSet
   fi
   hdfs dfs -mkdir -p $SAMPLE_DATA_HDFS_DIR/$dataSet
done

# Copying the data into HDFS
for dataSet in weather crime; do
  fileName="${dataSet}_2010_to_present.csv"
  echo "Putting /tmp/$fileName into HDFS"
  hdfs dfs -put /tmp/$fileName $SAMPLE_DATA_HDFS_DIR/$dataSet
done

# Run the MR jobs to produce the opentsdb put output for the crimes data
echo -e "\n#### Running the crimes data processing job"
chmod 777 $CRIMES_MAPPER $CRIMES_REDUCER
if hdfs dfs -test -d $CRIMES_HDFS_OUTPUT_DIR; then
  echo "Cleaning up previous run at $CRIMES_HDFS_OUTPUT_DIR"
  hdfs dfs -rm -r $CRIMES_HDFS_OUTPUT_DIR
fi


exit 0
