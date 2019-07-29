#!/bin/sh
DIRNAME=`dirname $0`
BROWSER_HOME=$DIRNAME
JAVA=java

if [ -f $BROWSER_HOME/jre/bin/java ]; then
    JAVA=$BROWSER_HOME/jre/bin/java
fi
$JAVA -Xmx384m -cp $BROWSER_HOME/lib/browser.jar com.ireasoning.app.mibbrowser.SnmpGet $*
