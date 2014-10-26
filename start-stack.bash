#!/bin/bash
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
$ZOOKEEPER_HOME/bin/zkServer.sh start
$ACCUMULO_HOME/bin/accumulo init
$ACCUMULO_HOME/bin/start-all.sh
