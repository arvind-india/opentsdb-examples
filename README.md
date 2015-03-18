OpenTSDB Demo
============

Tools for installing, starting, and populating an OpenTSDB cluster on HBase

The tooling will perform the following steps.

1. Create the necessary [HBase tables](http://opentsdb.net/docs/build/html/installation.html#id1)
2. Install and start the [TSD processes](http://opentsdb.net/docs/build/html/user_guide/cli/tsd.html)
3. Install and start the [tcollector processes](http://opentsdb.net/docs/build/html/user_guide/utilities/tcollector.html)

**WARNING: This is intended for POC/sandbox testing, may not be idempotent so DO NOT use on an existing Production cluster!!!**


Prerequisites
-------------
1. Functional HBase 0.98 cluster


Setup
-----
1. Clone the repo
2. Set the necessary cluster variables in opentsdb.conf


Running
-------
* Create the necessary HBase tables with create_opentsdb_hbase_tables.sh $HMASTER_HOSTNAME
  1. Installs git and automake
  2. Clones the OpenTSDB git repo
  3. Creates snappy compressed OpenTSDB tables

* Install the TSD process on Region Servers with opentsdb_tsd_install.sh $REGION_SERVER_HOSTNAME
  1. Installs git, automake, and gnuplot
  2. Clones the "next" branch from the OpenTSDB git repo
  3. Creates a tmpfs filesystem for the OpenTSDB cache
  4. Creates the OpenTSDB log directory
  5. Starts the TSD

* Configure load balancing across TSD instances
  1. ssh to haproxy01.cloud.hortonworks.com as root
  2. Edit haproxy.cfg: 

    ```
    vi /etc/haproxy/haproxy.cfg
    ```

  3. Add a block similar to below, changing the bind port and backend servers:

    ```
    #---------------------------------------------------------------------
    # OpenTSDB TSD Config
    #---------------------------------------------------------------------
    frontend http
        bind *:4242
        mode tcp
        default_backend tsd

    backend tsd
        balance	source
        mode	tcp
        server tsd1 opentsdb-skumpf02.cloud.hortonworks.com:4242 check
        server tsd2 opentsdb-skumpf03.cloud.hortonworks.com:4242 check
        server tsd3 opentsdb-skumpf04.cloud.hortonworks.com:4242 check
    ```

  4. Reload the config 

    ```
    service haproxy reload
    ```

* Install tcollector on all nodes where metric's collection is desired with opentsdb_tcollector_install.sh $NODE_HOSTNAME
  1. Installs git
  2. Sets the TSD address in the init script
  3. Creates the init script
  4. Starts the tcollector
