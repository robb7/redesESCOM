#!/bin/sh
DIRNAME=`dirname $0`
BROWSER_HOME=$DIRNAME
JAVA=java

if [ -f $BROWSER_HOME/jre/bin/java ]; then
    JAVA=$BROWSER_HOME/jre/bin/java
fi
$JAVA  -Xmx384m  -Duser.country=US -Duser.language=en -classpath $BROWSER_HOME/browser.jar  com.ireasoning.server.NetworkServer $*
