OpenTSDB Examples
=================

Tools for installing, starting, and populating an OpenTSDB cluster on HBase

The tooling will perform the following steps.

1. Create the necessary [HBase tables](http://opentsdb.net/docs/build/html/installation.html#id1)
2. Install and start the [TSD processes](http://opentsdb.net/docs/build/html/user_guide/cli/tsd.html)
3. Install and start the [tcollector processes](http://opentsdb.net/docs/build/html/user_guide/utilities/tcollector.html)
4. Install a wrapper around the [tsdb cli](http://opentsdb.net/docs/build/html/user_guide/cli/index.html) to supply arguments from the config


Prerequisites
-------------
1. Functional HBase cluster 


Setup
-----
* Clone the repo
```
cd /tmp && git clone https://github.com/sakserv/opentsdb-examples.git
```

* Modify the config with the appropriate values
```
cd /tmp/opentsdb-examples && vi conf/opentsdb.conf
```

* Create the HBase tables
```
cd /tmp/opentsdb-examples/ && bash -x bin/create_opentsdb_hbase_tables.sh
```

* Install the TSDs
```
cd /tmp/opentsdb-examples/ && bash -x bin/opentsdb_tsd_install.sh
```

* Install the tcollectors
```
cd /tmp/opentsdb-examples/ && bash -x bin/opentsdb_tcollector_install.sh
```

* Install the TSD cli wrapper
```
cd /tmp/opentsdb-examples/ && bash -x bin/opentsdb_cli_install.sh
```

Data Load
---------
Two sample data sets are stored in S3 for demoing the capabilities of OpenTSDB. The data sets are:
* [NOAA for daily temps at Chicago ORD: 01/2010 - 03/2015](http://www.ncdc.noaa.gov/cdo-web/search?datasetid=GHCND) - 100MB
* [City of Chicago Data Portal Crimes: 01/2010 - 03/2015](https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-present/ijzp-q8t2) - 11KB

Using these data sets, you can easily visualize how the daily temperature in Chicago impacts the number of crimes daily. The data is stored in S3.

* Download the datasets and stage in HDFS
```
cd /tmp/opentsdb-examples/ && bash -x bin/opentsdb_load_sample_data.sh
```

Usage
-----
The default configuration will start the TSD on port 19990. Open a browser and navigate to the TSD_PORT on the machine where the TSD was installed. Tcollector was already installed and started, so data points should be available. In the metric box, type proc. and validate that a list of metrics is returned. Be sure to modify port forwarding and firewall rules as appropriate to allow access to the TSD web interface.
