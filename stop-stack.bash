#!/bin/bash
$ACCUMULO_HOME/bin/stop-all.sh
$HADOOP_HOME/sbin/stop-dfs.sh
$ZOOKEEPER_HOME/bin/zkServer.sh stop
