@echo off
:: Author: David das Neves
:: Date:   15.06.2014
:: File:   Java_Cleanup.bat
:: Descr:  Cleans the computer from all java versions.

setlocal enableextensions enabledelayedexpansion

cls
echo *******************************************************************************
echo *******************************************************************************
echo *******************************************************************************
echo ********                        Java-Uninstaller                       ********
echo *******************************************************************************
echo *******************************************************************************
echo *******************************************************************************
echo ********                      Closing Processes                        ********
echo *******************************************************************************
echo *******************************************************************************

echo ******** iexplorer
Taskkill /F /IM iexplorer.exe /T 2>NUL
echo ******** iexplore
Taskkill /F /IM iexplore.exe /T 2>NUL
echo ******** firefox
Taskkill /F /IM firefox.exe /T 2>NUL
echo ******** chrome
Taskkill /F /IM chrome.exe /T 2>NUL
echo ******** jusched
Taskkill /F /IM jusched.exe /T 2>NUL
echo ******** jqs
Taskkill /F /IM jqs.exe /T 2>NUL
echo ******** java
Taskkill /F /IM java.exe /T 2>NUL
echo ******** javacpl
Taskkill /F /IM javacpl.exe /T 2>NUL

echo ******** Citrix
Taskkill /F /IM Receiver.exe /T 2>NUL
echo ******** Teamviewer / Connect
Taskkill /F /IM VisFastStart.exe /T 2>NUL
echo ******** WMIC
Taskkill /F /IM WMIC.exe /T 2>NUL
echo ******** MSI
Taskkill /F /IM msiexec.exe /T 2>NUL

echo *******************************************************************************
echo *******************************************************************************
echo ********                Deactivating existing Java-Addons              ********
echo *******************************************************************************
echo *******************************************************************************

::Cleaning up user-specific entries
@setlocal

set "RegPath=HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
set "SID="

for /f "delims=" %%i in ('reg query "%RegPath%"^|findstr /ibc:"%RegPath%\S-"') do (
  echo %%~nxi & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{DBC80044-A445-435B-BC74-9C25C1C588A9}" /f & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{761497BB-D6F0-462C-B6EB-D4DAF1D92D43}" /f & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{08B0E5C0-4FCB-11CF-AAA5-00401C608501}" /f & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{E7E6F031-17CE-4C07-BC86-EABFE594F69C}" /f & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA}" /f & REG DELETE "HKU\%%~nxi\Software\Microsoft\Windows\CurrentVersion\Ext\Settings\{8AD9C840-044E-11D1-B3E9-00805F499D93}" /f)

sleep 5

echo ******** Adding regs in system content for addon
:: old JavaAddons
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {DBC80044-A445-435B-BC74-9C25C1C588A9} /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {761497BB-D6F0-462C-B6EB-D4DAF1D92D43} /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {CAFEEFAC-DEC7-0000-0001-ABCDEFFEDCBA} /d 0 /f

sleep 3

::ADOBE
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {E7E6F031-17CE-4C07-BC86-EABFE594F69C} /d 0 /f

sleep 1
::new Java-Addon
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {08B0E5C0-4FCB-11CF-AAA5-00401C608501} /d 1 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Ext\CLSID" /v {8AD9C840-044E-11D1-B3E9-00805F499D93} /d 1 /f

sleep 5

::ReOpening IE - forces a reload
echo ******** iexplore oeffnen
start iexplore

sleep 7

echo ******** iexplorer schliessen
Taskkill /F /IM iexplorer.exe /T 2>NUL
echo ******** iexplore schliessen
Taskkill /F /IM iexplore.exe /T 2>NUL

echo *******************************************************************************
echo *******************************************************************************
echo ********                Java Addons deactivation done                  ********
echo *******************************************************************************
echo *******************************************************************************
echo
echo
echo *******************************************************************************
echo ********                      Reloading MSI                             *******
echo *******************************************************************************
sc config msiserver start= demand
Net stop msiserver

MSIExec /unregister
MSIExec /regserver
regsvr32.exe /s %windir%\system32\msi.dll

Net start msiserver
sc config msiserver start= auto

sleep 7

echo *******************************************************************************
echo ********             Deinstallation of Java-versions                   ********
echo *******************************************************************************
echo *******************************************************************************

:: Gets through the substrings of the keys in the file keys.ini and searches for java installations and triggers a deinstallation if found.
FOR /f %%i in (KEYS.ini) do call :SearchAndDeinstall %%i 

sleep 3
::Deinstallation of all java products

:: CAUTION - all software packages with "java" in it will be deinstalled
:: if no such software is known you should uncomment the following statement
wmic product where "name like '%%Java%%'" call uninstall /nointeractive

sleep 10


echo *******************************************************************************
echo ********                     Removing Reg-Keys                         ********
echo *******************************************************************************
echo *******************************************************************************
sleep 5

::Java internal
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{CAFEEFAC-6666-6666-6666-ABCDEFFEDCBA}" /f 
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{08B0E5C0-4FCB-11CF-AAA5-00401C608501}\TreatAs" /f 

::Policy
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft" /f
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft" /f

sleep 5
::Deleting user-specific entries
@setlocal

set "RegPath=HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\ProfileList"
set "SID="

for /f "delims=" %%i in ('reg query "%RegPath%"^|findstr /ibc:"%RegPath%\S-"') do (
  echo %%~nxi & REG DELETE "HKU\%%~nxi\SOFTWARE\AppDataLow\Software\JavaSoft" /f
)
sleep 1

echo *******************************************************************************
echo ********               Deleting depending files and folders            ********
echo *******************************************************************************
echo *******************************************************************************


echo ******** DLLs               
::DLLs
del c:\Windows\system32\npdeploy*.dll
del c:\Windows\system32\npjpi170_17.dll
del c:\Windows\system32\npjpi160_18.dll
del c:\Windows\system32\npjpi150_22.dll
del c:\Windows\system32\npjpi142_19.dll

del c:\Windows\system32\java*.exe
del c:\Windows\system32\*java.exe
del c:\Windows\system32\*java*.exe

del c:\Windows\syswow64\npdeploy*.dll
del c:\Windows\syswow64\npjpi170_17.dll
del c:\Windows\syswow64\npjpi160_18.dll
del c:\Windows\syswow64\npjpi150_22.dll
del c:\Windows\syswow64\npjpi142_19.dll

del c:\Windows\syswow64\*java.exe
del c:\Windows\syswow64\java*.exe
del c:\Windows\syswow64\*java*.exe

echo ******** Programfolders 
rd /s /q "c:\Programme\Java"
rd /s /q "C:\Program Files (x86)\Java"

sleep 1
echo ******** All Sun-folders in c:/Users
c:
cd c:\users
for /f "delims=" %%a in ('dir /ad /b /s "Sun"') do echo "%%a"  & rd /s /q "%%a" 

sleep 1

echo *******************************************************************************
echo ********                   Resetting JAVA_OPTIONS                      ********
echo *******************************************************************************
echo *******************************************************************************
set JAVA_OPTIONS=
set _JAVA_OPTIONS=

:: Following may help in some cases
::set _JAVA_OPTIONS=-Xmx512M

echo *******************************************************************************
echo ********                Removing existing Reg-Keys                     ********
echo *******************************************************************************
echo *******************************************************************************
REG DELETE "HKEY_CLASSES_ROOT\JNLPFile\Shell\Open\Command" /f 
REG DELETE "HKEY_CLASSES_ROOT\jarfile\Shell\Open\Command" /f 

::Set correct version here.
::REG ADD "HKEY_CLASSES_ROOT\JNLPFile\Shell\Open\Command" /d "\"c:\Program Files\Java\jre8\bin\javaws.exe \"%1\"" /f
::REG ADD "HKEY_CLASSES_ROOT\jarfile\Shell\Open\Command" /d "\"c:\Program Files\Java\jre8\bin\javaws.exe \"%1\"" /f

:EOF
echo *******************************************************************************
echo *******************************************************************************
echo ********                 Deinstallation completed                      ********
echo *******************************************************************************
echo *******************************************************************************
exit

:SearchAndDeinstall
For /F "Tokens=6* delims=\" %%I In ('Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall 2^>NUL ^|Findstr /I /C:"{%1"')  Do (
  echo %%J & MsiExec.exe /qn /x %%J /norestart
)
For /F "Tokens=7* delims=\" %%I In ('Reg Query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall 2^>NUL ^|Findstr /I /C:"{%1"')  Do (
  echo %%J & MsiExec.exe /qn /x %%J /norestart
)                                 