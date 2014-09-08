#!/usr/bin/bash -x

export JBOSS_DIR=/cygdrive/e/workarea/tools/server/jboss-5.1.0.GA
export JBOSS_CONF=defaultapilayer
export PROJECT_DIR=/cygdrive/e/workarea/code/LS-SI-API/ls-si-api-mr-war/target
export PROJECT_FILE=ls-si-api-mr-war-*.war
rm -rf $JBOSS_DIR/server/$JBOSS_CONF/log
rm -rf $JBOSS_DIR/server/$JBOSS_CONF/tmp
rm -rf $JBOSS_DIR/server/$JBOSS_CONF/work
rm -rf $JBOSS_DIR/server/$JBOSS_CONF/data
rm -rf $JBOSS_DIR/server/$JBOSS_CONF/deploy/$PROJECT_FILE
cp $PROJECT_DIR/$PROJECT_FILE $JBOSS_DIR/server/$JBOSS_CONF/deploy/
setfacl -m  u::rwx,g::r-x,o::r-x $JBOSS_DIR/server/$JBOSS_CONF/deploy/$PROJECT_FILE