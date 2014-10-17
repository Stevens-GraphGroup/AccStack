#!/bin/bash
$HADOOP_HOME/sbin/start-dfs.sh
$ZOOKEEPER_HOME/bin/zkServer.sh start
$ACCUMULO_HOME/bin/accumulo init
$ACCUMULO_HOME/bin/start-all.sh
