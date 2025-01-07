@echo off
REM Path to VBoxManage.exe - update if VirtualBox is installed in a different location
set "VBOXMANAGE=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

REM List of VMs to start in headless mode
set VMS=isprouter companyrouter homerouter web dns database employee remote-employee wazuh

echo Starting VMs in headless mode...

for %%V in (%VMS%) do (
    echo Starting %%V...
    "%VBOXMANAGE%" startvm "%%V" --type headless
    if %ERRORLEVEL% neq 0 (
        echo Failed to start %%V
    ) else (
        echo %%V started successfully.
    )
)

echo All VMs have been processed.
pause
