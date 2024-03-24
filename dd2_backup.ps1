param(    
    # Backup if minimum minutes passed since last save
    [int]$mins = 5,

    # Number of backup files to keep, older will be deleted
    [int]$keep,

    # backup anytime game saves
    [switch]$always,

    # Skip Starting DD2 when running script    
    [switch]$SkipDD2Start

)

######### Changes for your Steam setup #########

function Find-SteamId {
    try {
        (Get-ChildItem "C:\Program Files (x86)\Steam\userdata\*\2054970\remote").FullName.Split('\')[-3]
    } catch {
        write-host "Unable to locate Steam Id. Please enter it manually"
    }

}

# we will try to detect it using default location, if not edit the line below and enter it manually
$steam_folder_id = Find-SteamId
# $steam_folder_id = 342408821

Write-Host "Detected Steam Id: $steam_folder_id"

$dd2_exe_path = "G:\games\steam\steamapps\common\Dragons Dogma 2\dd2.exe"

######### End Change ############################

### Common Vars ### 

# Root folder where Steam save file directory is located for "me"
$dd2_root = "C:\Program Files (x86)\Steam\userdata\$steam_folder_id\2054970\remote"

# put the backup folder next to "Remote" folder
$dd_backup_folder="$dd2_root\backup"

### End Vars ###


### Utility Functions ###

Function Remove-OlderBackups{
    param($keep)
    
    $backup_files = (Get-ChildItem $dd_backup_folder "*data000.bin" | Sort-Object lastWriteTime -Descending)
    $backup_count = (Get-ChildItem $dd_backup_folder).count / 2

    if ($backup_count -gt $keep) {

        Write-Host "backup count: $backup_count > $keep Deleting older files"

        $oldest_file_time = $backup_files[$keep-1].LastWriteTime
        $oldest_file_name = ${backup_files[$keep-1]}.fullname
        write-host "oldest to keep: $oldest_file_name - $oldest_file_time"
        
        $to_be_deleted = (Get-ChildItem $dd_backup_folder | ? {$_.LastWriteTime -lt $oldest_file_time}).fullname
        if ($to_be_deleted) {
            Write-host "To be deleted: $($to_be_deleted.count)"
            $to_be_deleted | remove-item -Force
        }

    }

}

### End Functions ###



### MAIN ###



# delete existing watcher events
Get-EventSubscriber -force | unregister-event -force

Function Start-DD2 {

    # start dd2 if it is not already running
    if (-not (get-process dd2 -ErrorAction SilentlyContinue)) {
        
        Write-Host "Launching dd2"
        start-process $dd2_exe_path
    }

}

if (-not $SkipDD2Start) { Start-DD2 }


# create the backup dir and a dummy file for date comparison for the first time
if (-not (test-path $dd_backup_folder)) {
    New-Item -Path $dd_backup_folder -ItemType Directory
    New-item -Path $dd_backup_folder -ItemType File -Name '.init'
}

# setup watcher
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = "$dd2_root\win64_save"
$watcher.EnableRaisingEvents = $true
    
$action =
    {
		

        # file changed but game first creates a .stmp stub file before replacing the actual save file
        # sometimes it takes a few secs to update the save file, wait for 10 secs
        Start-Sleep(10)

        $path = $event.SourceEventArgs.FullPath
		$changetype = $event.SourceEventArgs.ChangeType
		Write-Host "$path was $changetype at $(get-date)"
		
		$dd_save_file1 = "$dd2_root\win64_save\data000.bin"
		$dd_save_file2 = "$dd2_root\win64_save\data00-1.bin"


		# when was it last saved
		$dd_save_file_date = (Get-ChildItem $dd_save_file1).LastWriteTime
		

		# find the latest backed up save file & its date
		$last_backup = (Get-ChildItem "$dd_backup_folder" |Sort-Object LastWriteTime)[-1]        
		$last_backup_date = $last_backup.LastWriteTime

		
        if ($always) {
            
            # Backup everytime game save file changes

            if ($dd_save_file_date -ne $last_backup_date) {
		        Write-Host "Current save file has a newer date than last backed up file. Backing up..."

		        $date = get-date -f "yyyy-MM-ddTHHmmss"
		        copy-item $dd_save_file1 "$dd_backup_folder\${date}_data000.bin"
		        copy-item $dd_save_file2 "$dd_backup_folder\${date}_data00-1.bin"


		    } else {
	    	    write-host "Have the latest save file backed up already"
		    }

        } else {

            # Backup if it $Mins has passed since the last backup
            $elapsed = ($dd_save_file_date - $last_backup_date).Minutes

            if ($elapsed -ge $mins) {
		        write-host "$mins mins has passed since the last backup. Backing up save file..."

		        $date = get-date -f "yyyy-MM-ddTHHmmss"
		        copy-item $dd_save_file1 "$dd_backup_folder\${date}_data000.bin"
		        copy-item $dd_save_file2 "$dd_backup_folder\${date}_data00-1.bin"


		    } else {
	    	    write-host "$elapsed < $mins mins, skipped backing up save file."
		    }            
        }
    
        if ($keep) { Remove-OlderBackups -keep $keep } else { write-host "Keep param not specified"}
    
    }


Register-ObjectEvent $watcher 'Changed' -Action $action

# display results
Get-EventSubscriber

write-host "Backup will be saved to: $dd_backup_folder"