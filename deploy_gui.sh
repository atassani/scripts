#!/usr/bin/bash -x
cd /cygdrive/e/workarea/code/GUI/parent
#mvn -T 4c -Dmaven.test.skip=true clean install 
mvn -T 4c -Dmaven.test.skip=true install
cd /cygdrive/e/workarea/tools/server/jboss-5.1.0.GA/server/ngg 
rm -rf log
rm -rf tmp
rm -rf work
rm -rf data
cd /cygdrive/e/workarea/tools/server/jboss-5.1.0.GA/server/ngg/deploy
rm -rf ngg.war
cp /cygdrive/e/workarea/code/GUI/web/target/ngg.war /cygdrive/e//workarea/tools/server/jboss-5.1.0.GA/server/ngg/deploy
mv ngg.war ngg.zip
unzip ngg.zip -d ngg.war
rm ngg.zip