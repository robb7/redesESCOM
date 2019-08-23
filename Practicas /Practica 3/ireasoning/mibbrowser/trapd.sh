#!/bin/sh
DIRNAME=`dirname $0`
BROWSER_HOME=$DIRNAME
JAVA=java

if [ -f $BROWSER_HOME/jre/bin/java ]; then
    JAVA=$BROWSER_HOME/jre/bin/java
fi

$JAVA -Xmx384m -DisTrapd=true  -Duser.country=US -Duser.language=en -jar $BROWSER_HOME/lib/browser.jar $*
