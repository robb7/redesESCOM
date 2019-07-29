@echo off
echo Start Trap Receiver
set BROWSER_HOME=.\..
if "%OS%" == "Windows_NT" set BROWSER_HOME=%~dp0%..
set JRE_BIN=%BROWSER_HOME%\jre\bin
IF EXIST "%JRE_BIN%\java.exe" GOTO L1
java  -Xmx256m -DisTrapd=true  -Duser.country=US -Duser.language=en  -jar "%BROWSER_HOME%\lib\browser.jar"  %*
GOTO EXIT
:L1
"%JRE_BIN%\java.exe"  -Xmx384m  -DisTrapd=true  -Duser.country=US -Duser.language=en  -jar "%BROWSER_HOME%\lib\browser.jar"  %* 
:EXIT

