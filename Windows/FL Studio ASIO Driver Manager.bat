@echo off
title FL Studio ASIO Driver Manager
color 0B

setlocal EnableDelayedExpansion

:: run as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges..
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:menu
cls
echo ------------------------------------------
echo     FL Studio ASIO Driver Manager
echo ------------------------------------------
echo 1. Install/Update Driver
echo 2. Uninstall Driver
echo 3. Exit
echo.
set /p CHOICE="Select an option (1-3): "

if "%CHOICE%"=="1" goto install
if "%CHOICE%"=="2" goto uninstall
if "%CHOICE%"=="3" exit /b
goto menu

:install
cls
echo ------------------------------------------
echo     FL Studio ASIO Driver Installer
echo ------------------------------------------

set "target=%SystemRoot%\System32\ILWASAPI2ASIO_x64.dll"
set "local=Drivers\ILWASAPI2ASIO_x64.dll"
set "verLocal="
set "verInstalled="

:: get local version
for /f "delims=" %%v in ('powershell -NoProfile -Command ^
  "$b=[IO.File]::ReadAllBytes('%~dp0%local%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
    set "verLocal=%%v"
)

:: check installed version, if exists ofc
if exist "%target%" (
    for /f "delims=" %%v in ('powershell -NoProfile -Command ^
      "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
        set "verInstalled=%%v"
    )
)

echo Local version:     %verLocal%
if defined verInstalled (
    echo Installed version: %verInstalled%
) else (
    echo No version currently installed.
)

:: compare versions
if "%verLocal%"=="%verInstalled%" (
    echo.
    echo You already have %verInstalled% installed.
    pause
    goto menu
)

:: prompt for install or update
if defined verInstalled (
    echo.
    set /p REPLACE="Update to %verLocal%? (Y/N): "
    if /i "!REPLACE!"=="Y" (
        set FLAG=/Y
    ) else (
        echo Installation cancelled.
        pause
        goto menu
    )
) else (
    echo.
    set /p INSTALL="Do you wish to install %verLocal%? (Y/N): "
    if /i "!INSTALL!"=="Y" (
        set FLAG=/Y
    ) else (
        echo Installation cancelled.
        pause
        goto menu
    )
)

:: copy files
echo.
echo Copying files..
copy %FLAG% Drivers\ILWASAPI2ASIO.DLL %SystemRoot%\System32\ >nul
copy %FLAG% Drivers\ILWASAPI2ASIO_x64.DLL %SystemRoot%\System32\ >nul

:: double-check
set "postCopyVer="
for /f "delims=" %%v in ('powershell -NoProfile -Command ^
  "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
    set "postCopyVer=%%v"
)

if not "%postCopyVer%"=="%verLocal%" (
    echo Error: File copy failed.
    pause
    goto menu
)

:: register dlls
echo Registering DLLs..
regsvr32.exe /s %SystemRoot%\System32\ILWASAPI2ASIO.DLL
regsvr32.exe /s %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL

:: restart audio service
echo Restarting Windows Audio Service
net stop Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo Failed to stop Audio Service.
    pause
    goto menu
)
call :LoadingBar "Stopping"

net start Audiosrv >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Failed to start Audio Service.
    pause
    goto menu
)
call :LoadingBar "Starting"

echo.
echo Installation successful!
pause
goto menu

:uninstall
cls
echo ------------------------------------------
echo     FL Studio ASIO Driver Uninstaller
echo ------------------------------------------

set "target=%SystemRoot%\System32\ILWASAPI2ASIO_x64.dll"
set "verInstalled="

:: check if installed
if exist "%target%" (
    for /f "delims=" %%v in ('powershell -NoProfile -Command ^
      "$b=[IO.File]::ReadAllBytes('%target%'); $s=[Text.Encoding]::Unicode.GetString($b); if ($s -match 'FL Studio ASIO V[\d\.]+') { $matches[0] }"') do (
        set "verInstalled=%%v"
    )
)

if not defined verInstalled (
    echo No FL Studio ASIO Driver installed.
    pause
    goto menu
)

echo.
echo You are about to uninstall %verInstalled%
echo.
set /p CONFIRM="Are you sure you want to continue? (Y/N): "
if /i "!CONFIRM!"=="Y" (
    echo.
    echo Unregistering DLLs..
    regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO.DLL
    if %errorlevel% neq 0 (
        echo Warning: Failed to unregister ILWASAPI2ASIO.DLL
        echo Trying force unregister..
        regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO.DLL
        if %errorlevel% neq 0 (
            echo Error: Could not unregister ILWASAPI2ASIO.DLL
            pause
            goto menu
        )
    )
    
    regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL
    if %errorlevel% neq 0 (
        echo Warning: Failed to unregister ILWASAPI2ASIO_x64.DLL
        echo Trying force unregister..
        regsvr32.exe /u /s %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL
        if %errorlevel% neq 0 (
            echo Error: Could not unregister ILWASAPI2ASIO_x64.DLL
            pause
            goto menu
        )
    )

    echo.
    echo Deleting files..
    del %SystemRoot%\System32\ILWASAPI2ASIO.DLL >nul 2>&1
    if %errorlevel% neq 0 (
        echo Warning: Failed to delete ILWASAPI2ASIO.DLL
        echo Trying force delete..
        del /f %SystemRoot%\System32\ILWASAPI2ASIO.DLL >nul 2>&1
        if %errorlevel% neq 0 (
            echo Error: Could not delete ILWASAPI2ASIO.DLL
            pause
            goto menu
        )
    )
    
    del %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL >nul 2>&1
    if %errorlevel% neq 0 (
        echo Warning: Failed to delete ILWASAPI2ASIO_x64.DLL
        echo Trying force delete..
        del /f %SystemRoot%\System32\ILWASAPI2ASIO_x64.DLL >nul 2>&1
        if %errorlevel% neq 0 (
            echo Error: Could not delete ILWASAPI2ASIO_x64.DLL
            pause
            goto menu
        )
    )

    echo.
    echo Restarting Windows Audio Service
    net stop Audiosrv >nul 2>&1
    if %errorlevel% neq 0 (
        echo Failed to stop Audio Service.
        pause
        goto menu
    )
    call :LoadingBar "Stopping"

    net start Audiosrv >nul 2>&1
    if %errorlevel% neq 0 (
        echo Error: Failed to start Audio Service.
        pause
        goto menu
    )
    call :LoadingBar "Starting"

    echo.
    echo Uninstallation successful!
) else (
    echo Uninstallation cancelled.
)
pause
goto menu

:: loading bar
:LoadingBar
<nul set /p= %~1 Audio Service:
for /L %%i in (1,1,20) do (
    <nul set /p=.
    ping -n 1 127.0.0.1 >nul
)
echo.
exit /b