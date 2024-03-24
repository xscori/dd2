REM if you have not set the execution policy you need the following line run once. Remove REM
REM powershell -command "Set-ExecutionPolicy Unrestricted"

REM Why? Because it allows you to run this PowerShell script you just downloaded
REM Ref: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies

powershell -noexit -file c:\temp\dd2_backup\dd2_backup.ps1 -mins 5 -keep 1000


REM by default, backups are taken if 5 minutes has passed since the last backup
REM change -min 5 to another value if you want more or less backups

REM if you want all saves to be backed up, use -always instead of -mins
REM to do that, put a REM in front of the line starting with "powershell" above
REM then, remove "REM " from the lines starting with powershell below

REM Example: Backup all save files, keep all save files
REM powershell -noexit -file c:\temp\dd2_backup\\dd2_backup.ps1 -always

REM Example: Backup all save files, keep last 500 backup save files
REM powershell -noexit -file c:\temp\dd2_backup\\dd2_backup.ps1 -always -keep 500


