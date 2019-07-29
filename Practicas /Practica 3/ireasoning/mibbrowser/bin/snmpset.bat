@echo off
set BROWSER_HOME=.\..
if "%OS%" == "Windows_NT" set BROWSER_HOME=%~dp0%..
set JRE_BIN=%BROWSER_HOME%\jre\bin
IF EXIST "%JRE_BIN%\java.exe" GOTO L1
java -cp "%BROWSER_HOME%\lib\browser.jar"  com.ireasoning.app.mibbrowser.SnmpSet %*
GOTO EXIT
:L1
"%JRE_BIN%\java.exe" -cp "%BROWSER_HOME%\lib\browser.jar"  com.ireasoning.app.mibbrowser.SnmpSet %* 
:EXIT



