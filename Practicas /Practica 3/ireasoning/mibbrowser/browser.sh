#!/bin/sh
DIRNAME=`dirname $0`
BROWSER_HOME=$DIRNAME
JAVA=java

if [ -f $BROWSER_HOME/jre/bin/java ]; then
    JAVA=$BROWSER_HOME/jre/bin/java
fi

if command -v $JAVA &>/dev/null
        then
		$JAVA -Xmx384m -Duser.country=US -Duser.language=en -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true -jar $BROWSER_HOME/lib/browser.jar $*
        else
                echo "java command is not found. Please download and install java first. ( http://www.java.com/en/download/manual.jsp )"
fi


