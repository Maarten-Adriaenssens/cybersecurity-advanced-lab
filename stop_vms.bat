@echo off
REM Path to VBoxManage.exe - update if VirtualBox is installed in a different location
set "VBOXMANAGE=C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

REM List of VMs to save state
set VMS=isprouter companyrouter homerouter web dns database employee remote-employee kali-linux-2024.3virtualbox-amd64

echo Saving VMs state...

for %%V in (%VMS%) do (
    echo Saving state of %%V...
    "%VBOXMANAGE%" controlvm "%%V" savestate
    if %ERRORLEVEL% neq 0 (
        echo Failed to save state of %%V
    ) else (
        echo %%V Saved state successfully.
    )
)

echo All VMs have been processed.
pause
