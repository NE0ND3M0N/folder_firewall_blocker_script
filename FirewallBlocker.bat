@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as administrator.
) else (
    echo Not running as administrator. Please run this script as an administrator.
    pause
    exit
)

@ setlocal enableextensions enabledelayedexpansion
@ cd /d "%~dp0"

:: Initialize lists
set "blockedFiles="
set "failedFiles="
set "ruleExists="

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set "date=%datetime:~6,2%/%datetime:~4,2%/%datetime:~0,4%"
set "time=%datetime:~8,2%:%datetime:~10,2%:%datetime:~12,2%"
echo ------------------------------------------------------------------------------------- >> firewall_changes.log
echo ===============================^< %date% %time% ^>=============================== >> firewall_changes.log
echo ------------------------------------------------------------------------------------- >> firewall_changes.log
echo. >> firewall_changes.log

for /R %%f in (*.exe *.dll) do (
  echo Checking %%f >> firewall_changes.log
  netsh advfirewall firewall show rule name="Blocked: %%f" dir=out >nul 2>&1 && (
    set "ruleExists=!ruleExists!Outgoing: %%f;"
    echo     [INFO] Outgoing rule already exists for: %%f >> firewall_changes.log
  ) || (
    netsh advfirewall firewall add rule name="Blocked: %%f" dir=out program="%%f" action=block && (
      set "blockedFiles=!blockedFiles!Outgoing: %%f;"
      echo     [SUCCESS] Blocked outgoing traffic for: %%f >> firewall_changes.log
    ) || (
      set "failedFiles=!failedFiles!Outgoing: %%f;"
      echo     [ERROR] Failed to block outgoing traffic for: %%f >> firewall_changes.log
    )
  )
  netsh advfirewall firewall show rule name="Blocked: %%f" dir=in >nul 2>&1 && (
    set "ruleExists=!ruleExists!Incoming: %%f;"
    echo     [INFO] Incoming rule already exists for: %%f >> firewall_changes.log
  ) || (
    netsh advfirewall firewall add rule name="Blocked: %%f" dir=in program="%%f" action=block && (
      set "blockedFiles=!blockedFiles!Incoming: %%f;"
      echo     [SUCCESS] Blocked incoming traffic for: %%f >> firewall_changes.log
    ) || (
      set "failedFiles=!failedFiles!Incoming: %%f;"
      echo     [ERROR] Failed to block outgoing traffic for: %%f >> firewall_changes.log
    )
  )
  echo. >> firewall_changes.log
)

echo All changes has been logged in firewall_changes.log
echo. >> firewall_changes.log

echo.
echo ====================================================
echo Summary:
echo ====================================================
if not "!blockedFiles!"=="" (
  echo [SUCCESS] Blocked traffic for the following files:
  echo --------------------------------------------------
  echo !blockedFiles:;=^

!
)
if not "!failedFiles!"=="" (
  echo [ERROR] Failed to block traffic for the following files:
  echo --------------------------------------------------------
  echo !failedFiles:;=^

!
)
if not "!ruleExists!"=="" (
  echo [INFO] Rules already exists for the following files:
  echo ----------------------------------------------------
  echo !ruleExists:;=^

!
)
echo ====================================================
pause