#!/bin/bash
set -e #command fail -> script fail
set -u #unset variable reference causes script fail
VERSION=1.7.0
#mvn package -DskipTests -DDEV_ACCUMULO_HOME=$STACK_HOME -Dhadoop.version=2.6.0
mvn package -P assemble -Dhadoop.version=2.6.0 -DskipTests
tar xzf assemble/target/accumulo-${VERSION}-SNAPSHOT-bin.tar.gz -C $STACK_HOME
ACCUMULO_DEV_HOME=$STACK_HOME/accumulo-${VERSION}-SNAPSHOT
if [ `grep -Ec "^export ACCUMULO_DEV_HOME=" ~/.bashrc` -gt 1 ]; 
then # safety check because we're editing .bashrc
    echo "check ~/.bashrc";
    grep -E "^export ACCUMULO_DEV_HOME=" ~/.bashrc;
else 
    TMP=`mktemp`
    { echo "export ACCUMULO_DEV_HOME=$ACCUMULO_DEV_HOME";
	grep -Ev "^export ACCUMULO_DEV_HOME=" ~/.bashrc; } > $TMP
    cp $TMP ~/.bashrc
    rm $TMP
fi
$ACCUMULO_DEV_HOME/bin/build_native_library.sh 
cp $ACCUMULO_HOME/conf/*.* $ACCUMULO_DEV_HOME/conf
# don't include directories; meh, needs to cd
#ls -F1 $ACCUMULO_HOME/conf/ | grep -v / | xargs cp -t $ACCUMULO_DEV_HOME/conf

