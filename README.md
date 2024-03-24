# Dragon's Dogma 2 - Backup Save files
Dragon's Dogma 2 - Backup save files

# Overview
This is an adaptation of my [backup script for Dragon's Dogma: Dark Arisen](https://github.com/xscori/dragonsdogma).

Unlike previous game, saves are much frequent now, every 3-5 mins game saves automatically.

However, if you wanted to go back to a previous save, this script helps.

# Install
* create a location to save the files. If you want to use as is, create `c:\temp\dd2_backup\` and put the two script ending with `.cmd` and `.ps1` under that.

# Configure
* Edit the `dd2_backup.ps1` file to change two file locations and you are all set to run with defaults.
* your steam save file location: This will usually be at `C:\Program Files (x86)\Steam\userdata\`
  * e.g. for me `342408821` is the number, so edit the line `$steam_folder_id = 342408821` to replace that number with yours
  * script will try to detect and use it, but if for some reason it cannot, edit the ps1 file
  * You backup files will be located at `C:\Program Files (x86)\Steam\userdata\<your_steam_id>\2054970\remote\backup\`
* your game install location, i.e. where dd2.exe is
  * Replace the path on this line: `$dd2_exe_path = "G:\games\steam\steamapps\common\Dragons Dogma 2\dd2.exe"`   

# How does it work
* `dd2_backup.cmd` file simply calls `dd2_backup.ps1` PowerShell script with default params.

## Default parameters
PowerShell script is called as this:

`powershell -noexit -file c:\temp\dd2_backup\dd2_backup.ps1 -mins 5 -keep 1000`

This tells it to:
* backup 1000 save files. then delete the oldest backup file.
* backup the changed save file, if 5 mins passed since the last backup. 

Both can be changed. Please read comments, the lines that start with REM, in `dd2_backup.cmd`

# Run
* Either run the dd2_backup.cmd or configure your steam to launch it.
* There are screenshots that show how to configure steam launch params, if you prefer that like I do.


# Restore
* To restore, go back to game menu first.
* Rename `data000.bin` and `data00-1.bin`, for example insert `_` in front of the file name.
 *  You don't really need to do is, it is just good practice to always backup a file before you work on it.
* Copy over the files and remove `date` part to match `data000.bin` and `data00-1.bin`
* In main menu, choose `Load from last save`

# Note
If you ever see a message where it says It cannot load the save file, exit the game and restart. 

I suspect it is the Denuva anti-cheat engine causing it, but restarting game fixes that.

# Disclaimer
Usual disclaimer goes here with any open source software: Use at your own risk.
