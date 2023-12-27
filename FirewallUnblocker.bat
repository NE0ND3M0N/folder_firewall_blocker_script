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
set "unblockedFiles="
set "failedUnblocks="
set "ruleNotExists="

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
    netsh advfirewall firewall delete rule name="Blocked: %%f" dir=out && (
      set "unblockedFiles=!unblockedFiles!Outgoing: %%f;"
      echo     [SUCCESS] Unblocked outgoing traffic for: %%f >> firewall_changes.log
    ) || (
      set "failedUnblocks=!failedUnblocks!Outgoing: %%f;"
      echo     [ERROR] Failed to unblock outgoing traffic for: %%f >> firewall_changes.log
    )
  ) || (
    set "ruleNotExists=!ruleNotExists!Outgoing: %%f;"
    echo     [INFO] Outgoing rule does not exist for: %%f >> firewall_changes.log
  )
  netsh advfirewall firewall show rule name="Blocked: %%f" dir=in >nul 2>&1 && (
    netsh advfirewall firewall delete rule name="Blocked: %%f" dir=in && (
      set "unblockedFiles=!unblockedFiles!Incoming: %%f;"
      echo     [SUCCESS] Unblocked incoming traffic for: %%f >> firewall_changes.log
    ) || (
      set "failedUnblocks=!failedUnblocks!Incoming: %%f;"
      echo     [ERROR] Failed to unblock incoming traffic for: %%f >> firewall_changes.log
    )
  ) || (
    set "ruleNotExists=!ruleNotExists!Incoming: %%f;"
    echo     [INFO] Incoming rule does not exist for: %%f >> firewall_changes.log
  )
  echo. >> firewall_changes.log
)

echo All changes has been logged in firewall_changes.log
echo. >> firewall_changes.log

echo.
echo ====================================================
echo Summary:
echo ====================================================
if not "!unblockedFiles!"=="" (
  echo [SUCCESS] Unblocked traffic for the following files:
  echo ----------------------------------------------------
  echo !unblockedFiles:;=^

!
)
if not "!failedUnblocks!"=="" (
  echo [ERROR] Failed to unblock traffic for the following files:
  echo ----------------------------------------------------------
  echo !failedUnblocks:;=^

!
)
if not "!ruleNotExists!"=="" (
  echo [INFO] Rules do not exist for the following files:
  echo --------------------------------------------------
  echo !ruleNotExists:;=^

!
)
echo ====================================================
pause