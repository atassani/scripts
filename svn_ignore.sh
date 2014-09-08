#!/usr/bin/bash

for f in `find . -name .classpath`; do svn delete --force $f; done
for f in `find . -name .preferences`; do svn delete --force $f; done
for f in `find . -name .settings`; do svn delete --force $f; done
for f in `find . -name .project`; do svn delete --force $f; done
for f in `find . -name target`; do svn delete --force $f; done
for f in `find . -name bin`; do svn delete --force $f; done

for d in *; do
 svn propset svn:ignore -F "e:\code\scripts\ignore_list.txt" $d
done
