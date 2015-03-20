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
