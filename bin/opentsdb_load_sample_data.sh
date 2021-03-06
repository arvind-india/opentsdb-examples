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

# Run the MR job to produce the opentsdb put output for the crimes data
echo -e "\n#### Running the crimes data processing job"
chmod 777 $CRIMES_MAPPER $CRIMES_REDUCER
if hdfs dfs -test -d $CRIMES_HDFS_OUTPUT_DIR; then
  echo "Cleaning up previous run at $CRIMES_HDFS_OUTPUT_DIR"
  hdfs dfs -rm -r $CRIMES_HDFS_OUTPUT_DIR
fi
echo "Running the Hadoop Streaming job"
hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar -input $SAMPLE_DATA_HDFS_DIR/crime \
       -output $CRIMES_HDFS_OUTPUT_DIR \
       -mapper $CRIMES_MAPPER \
       -reducer $CRIMES_REDUCER


# Run the MR job to produce the opentsdb put output for the weather data
echo -e "\n#### Running the weather data processing job"
chmod 777 $WEATHER_MAPPER
if hdfs dfs -test -d $WEATHER_HDFS_OUTPUT_DIR; then
  echo "Cleaning up previous run at $WEATHER_HDFS_OUTPUT_DIR"
  hdfs dfs -rm -r $WEATHER_HDFS_OUTPUT_DIR
fi
echo "Running the Hadoop Streaming job"
hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-streaming.jar -input $SAMPLE_DATA_HDFS_DIR/weather \
       -output $WEATHER_HDFS_OUTPUT_DIR \
       -mapper $WEATHER_MAPPER


# Load the crimes data
if ! hdfs dfs -test -e $CRIMES_HDFS_OUTPUT_DIR/part-00000; then
  echo "ERROR: Could not find MR output for the crimes data set"
  exit 1
fi
hdfs dfs -copyToLocal $CRIMES_HDFS_OUTPUT_DIR/part-00000 $CRIMES_LOCAL_OUTPUT_FILE
$TSD_HOME/tsdb.cli import $CRIMES_LOCAL_OUTPUT_FILE || exit 1

# Load the weather data
if ! hdfs dfs -test -e $WEATHER_HDFS_OUTPUT_DIR/part-00000; then
  echo "ERROR: Could not find MR output for the weather data set"
  exit 1
fi
hdfs dfs -copyToLocal $WEATHER_HDFS_OUTPUT_DIR/part-00000 $WEATHER_LOCAL_OUTPUT_FILE
$TSD_HOME/tsdb.cli import $WEATHER_LOCAL_OUTPUT_FILE || exit 1

exit 0
