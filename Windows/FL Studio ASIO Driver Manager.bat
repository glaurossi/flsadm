@echo off
mode con cols=70 lines=30
color 0B

:: runs as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges..
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

title FL Studio ASIO Driver Manager

setlocal EnableDelayedExpansion

:menu
cls
echo:
echo:
echo:
echo:
echo:
echo                ---------------------------------------
echo                     FL Studio ASIO Driver Manager
echo                ---------------------------------------
echo:
echo                       [1] Install/Update Driver
echo                       [2] Uninstall Driver
echo                       [3] Exit
echo:
echo                ---------------------------------------
echo:
echo                Choose an option by pressing 1, 2 or 3:
choice /C:123 /N
set CHOICE=%errorlevel%

if %CHOICE%==1 goto install
if %CHOICE%==2 goto uninstall
if %CHOICE%==3 exit /b
goto menu

:install
cls
echo:
echo:
echo:
echo:
echo:
echo                ---------------------------------------
echo                     FL Studio ASIO Driver Manager
echo                ---------------------------------------

:: set variables
set "target=%SystemRoot%\System32\ILWASAPI2ASIO_x64.dll"
set "local=Drivers\ILWASAPI2ASIO_x64.dll"
set "verLocal="
set "verInstalled="

:: get local version
for /f "delims=" %%v in ('powershell -NoProfile -Command ^
  "$b=[IO.File]::ReadAllBytes('%~dp0%local%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
    set "verLocal=%%v"
)

:: get installed version
if exist "%target%" (
    for /f "delims=" %%v in ('powershell -NoProfile -Command ^
      "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
        set "verInstalled=%%v"
    )
)

echo                Local version:     %verLocal%
if defined verInstalled (
    echo                Installed version: %verInstalled%
) else (
    echo:
    echo                    No version currently installed.
    echo:
    echo:

)

:: check if driver is already installed
if "%verLocal%"=="%verInstalled%" (
    echo:
    echo:
    echo           You already have %verInstalled% installed.
    echo:
    echo:
    echo:
    echo:
    echo                      Press any key to continue..
    pause >nul
    goto menu
)

echo:
if defined verInstalled (
    echo           Update to %verLocal%?
) else (
    echo              Install version %verLocal%? [y/n]
    echo:
)
echo:
choice /C:YN /N /M ""
if !errorlevel! == 2 (
    cls
    echo:
    echo:
    echo:
    echo:
    echo:
    echo                ---------------------------------------
    echo                     FL Studio ASIO Driver Manager
    echo                ---------------------------------------
    echo:
    echo                        Installation cancelled.
    echo:
    echo:
    echo:
    echo:
    echo                      Press any key to continue..
    pause >nul
    goto menu
)

:: copy files
cls
echo:
echo:
echo:
echo:
echo:
echo                ---------------------------------------
echo                     FL Studio ASIO Driver Manager
echo                ---------------------------------------
echo:
echo                Copying files..
:: copy files to system32
copy /Y Drivers\ILWASAPI2ASIO.DLL %SystemRoot%\System32\ >nul
copy /Y Drivers\ILWASAPI2ASIO_x64.DLL %SystemRoot%\System32\ >nul

:: check if files were copied
set "postCopyVer="
for /f "delims=" %%v in ('powershell -NoProfile -Command ^
  "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
    set "postCopyVer=%%v"
)

:: check if files were copied
if not "%postCopyVer%"=="%verLocal%" (
    echo                   Error: File copy failed.
    pause
    goto menu
)

:: register DLLs
echo                Registering DLLs..
regsvr32.exe /s %SystemRoot%\System32\ILWASAPI2ASIO.DLL
regsvr32.exe /s %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL

:: restart audio service
echo                Restarting Windows Audio Service..
:: stop audio service
net stop Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo                Failed to stop Audio Service.
    pause
    goto menu
)
:: start audio service
net start Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo                Error: Failed to start Audio Service.
    pause
    goto menu
)

echo:
echo                Installation successful!
echo:
echo:
echo:
echo:
echo                     Press any key to continue..
pause >nul
goto menu

:: uninstall part
:uninstall
cls
echo:
echo:
echo:
echo:
echo:
echo                ---------------------------------------
echo                     FL Studio ASIO Driver Manager
echo                ---------------------------------------

:: get installed version
set "target=%SystemRoot%\System32\ILWASAPI2ASIO_x64.dll"
set "verInstalled="
:: check if driver is installed
if exist "%target%" (
    for /f "delims=" %%v in ('powershell -NoProfile -Command ^
      "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
        set "verInstalled=%%v"
    )
)

if not defined verInstalled (
    echo:
    echo                  No FL Studio ASIO Driver installed.
    echo:
    echo:
    echo:
    echo:
    echo                     Press any key to continue..
    pause >nul
    goto menu
)

echo:
echo           You are about to uninstall %verInstalled%
echo:
echo                         Are you sure? [y/n]
choice /C:YN /N
if !errorlevel! == 2 (
    cls
    echo:
    echo:
    echo:
    echo:
    echo:
    echo                ---------------------------------------
    echo                     FL Studio ASIO Driver Manager
    echo                ---------------------------------------
    echo:
    echo                       Uninstallation cancelled.
    echo:
    echo:
    echo:
    echo:
    echo                      Press any key to continue..
    pause >nul
    goto menu
)

cls
echo:
echo:
echo:
echo:
echo:
echo                ---------------------------------------
echo                     FL Studio ASIO Driver Manager
echo                ---------------------------------------
echo:
echo                Unregistering DLLs..
:: unregister DLLs
regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO.DLL
regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL

:: delete files
echo                Deleting files..
del /f /q %SystemRoot%\System32\ILWASAPI2ASIO.DLL >nul 2>&1
del /f /q %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL >nul 2>&1

:: restart audio service
echo                Restarting Windows Audio Service..
:: stop audio service
net stop Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to stop Audio Service.
    pause
    goto menu
)

:: start audio service
net start Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo                Error: Failed to start Audio Service.
    pause
    goto menu
)

echo:
echo                Uninstall successful!
echo:
echo:
echo:
echo:
echo                      Press any key to continue..
pause >nul
goto menu

echo.
exit /b