Setup files for Hadoop, Zookeeper, Accumulo.  Don't just run them naively.  Look at the file and run the parts you need, lest you attempt to add the ustack user when he already exists.

The .bash_ext is run by ustack on his .bashrc.

#### Monitoring Links

| Address                   | Name                      |
|---------------------------|---------------------------|
| <http://localhost:50095/> | Accumulo Monitor          |
| <http://localhost:50070/> | Hadoop Namenode           |
| <http://localhost:8088/>  | MapReduce ResourceManager |
| <http://localhost:19888/> | MapReduce job history     |

