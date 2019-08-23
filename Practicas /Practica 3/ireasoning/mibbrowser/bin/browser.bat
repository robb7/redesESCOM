@echo off
set BROWSER_HOME=.\..
if "%OS%" == "Windows_NT" set BROWSER_HOME=%~dp0%..
set JRE_BIN=%BROWSER_HOME%\jre\bin
IF EXIST "%JRE_BIN%\java.exe" GOTO L1
java  -Xmx768m  -Duser.country=US -Duser.language=en -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true  -jar "%BROWSER_HOME%\lib\browser.jar"  %*
GOTO EXIT
:L1
"%JRE_BIN%\java.exe"  -Xmx768m  -Duser.country=US -Duser.language=en -Dsun.java2d.d3d=false -Dsun.java2d.noddraw=true -jar "%BROWSER_HOME%\lib\browser.jar"  %* 
:EXIT

