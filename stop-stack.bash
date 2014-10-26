#!/bin/bash
$ACCUMULO_HOME/bin/stop-all.sh
$ZOOKEEPER_HOME/bin/zkServer.sh stop
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh

