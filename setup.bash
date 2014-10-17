# requires .bash_ext
export STACK_HOME=/Data/stack
cd $STACK_HOME

#sudo addgroup gstack
sudo groupadd gstack
#sudo adduser -ingroup gstack ustack
sudo adduser -g gstack -N ustack
sudo su - ustack
ssh-keygen -q -t rsa -P "" -f ~/.ssh/id_rsa
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
echo "source /Data/stack/.bash_ext" >> ~/.bashrc
exit
sudo mkdir -p /var/zookeeper
sudo chown ustack:gstack /var/zookeeper
sudo echo '''ustack           soft    nofile          32768
ustack           hard    nofile          32768''' >> /etc/security/limits.conf

wget http://www.webhostingjams.com/mirror/apache/maven/maven-3/3.2.3/binaries/apache-maven-3.2.3-bin.tar.gz
tar xzf apache-maven-3.2.3-bin.tar.gz
#wget http://www.gtlib.gatech.edu/pub/apache/hadoop/common/hadoop-2.5.1/hadoop-2.5.1.tar.gz
#tar xzf hadoop-2.5.1.tar.gz
wget http://apache.mirrors.hoobly.com/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz
tar xzf zookeeper-3.4.6.tar.gz
wget http://mirrors.gigenet.com/apache/accumulo/1.6.1/accumulo-1.6.1-src.tar.gz
tar xzf accumulo-1.6.1-src.tar.gz

# for native libraries on hadoop
# first need protoc
sudo yum install cmake
sudo yum install snappy-devel
sudo yum install zlib-devel
sudo yum install openssl-devel
wget https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
tar xzf protobuf-2.5.0.tar.gz
cd protobuf-2.5.0
./configure
make
sudo make install
sudo ldconfig
cd ..
wget http://www.motorlogy.com/apache/hadoop/common/hadoop-2.5.1/hadoop-2.5.1-src.tar.gz
tar xzf hadoop-2.5.1-src.tar.gz
cd hadoop-2.5.1-src
mvn package -Pdist,native -DskipTests -Dtar
cd ..
tar xzf hadoop-2.5.1-src/hadoop-dist/target/hadoop-2.5.1.tar.gz

cd accumulo-1.6.1
export PATH=$PATH:$STACK_HOME/apache-maven-3.2.3/bin
export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk.x86_64
export HADOOP_HOME=$STACK_HOME/hadoop-2.5.1
export ZOOKEEPER_HOME=$STACK_HOME/zookeeper-3.4.6
export ACCUMULO_HOME=$STACK_HOME/accumulo-1.6.1-dev/accumulo-1.6.1

#mvn package -P assemble -Dhadoop.version=2.5.1
mvn package -DskipTests -DDEV_ACCUMULO_HOME=$STACK_HOME -Dhadoop.version=2.5.1
#cd assemble
#mvn package
#cd target/accumulo-1.6.1-dev/accumulo-1.6.1
#./bin/build_native_library.sh

cd ../accumulo-1.6.1-dev/accumulo-1.6.1
./bin/build_native_library.sh

echo """tickTime=2000
dataDir=/var/zookeeper
clientPort=2181
maxClientCnxns=100""" > $STACK_HOME/zookeeper-3.4.6/conf/zoo.cfg
cp conf/examples/2GB/native-standalone/* conf
#see http://wiki.bash-hackers.org/syntax/pe#overview
sed -i "s/\/path\/to\/java/${JAVA_HOME//\//\/}/" conf/accumulo-env.sh
sed -i "s/\/path\/to\/hadoop/${HADOOP_HOME//\//\/}/" conf/accumulo-env.sh
sed -i "s/\/path\/to\/zookeeper/${ZOOKEEPER_HOME//\//\/}/" conf/accumulo-env.sh
#sed -i "s/comma separated list of zookeeper servers/localhost:2181/" conf/accumulo-site.xml
echo '''<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>''' > $STACK_HOME/hadoop-2.5.1/etc/hadoop/core-site.xml
echo '''<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>dfs.namenode.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.datanode.synconclose</name>
        <value>true</value>
    </property>
</configuration>''' > $STACK_HOME/hadoop-2.5.1/etc/hadoop/hdfs-site.xml

sudo chown -R ustack:gstack .

sudo su - ustack
$HADOOP_HOME/bin/hadoop namenode -format
$HADOOP_HOME/sbin/start-dfs.sh
$ZOOKEEPER_HOME/bin/zkServer.sh start
$ACCUMULO_HOME/bin/accumulo init
$ACCUMULO_HOME/bin/start-all.sh

# sites: 
#localhost:50095 accumulo
#50070
#50030