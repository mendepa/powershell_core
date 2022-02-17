
$CurrentPath = Get-Location
$Jobs = Get-ChildItem $CurrentPath\jobs\ -Exclude "Length -eq 0"
$Jobs

$SoftwareList = Get-Content $CurrentPath\software.json | ConvertFrom-Json 
$SoftwareList | ft

$BuildList = @()


foreach ($Software in $SoftwareList) {
    $Software.LastCheckDate = Get-Date -Format "MM/dd/yyyy HH:mm"

    $Job = ($Jobs | Where-Object {$_.Name -eq $Software.JobFileName})

    #Nie ma zadania dla tej aplikacji
    if(!$Job) {continue}
    
    $JobScriptPath = "$CurrentPath\jobs\" + $Job.Name

    #Start powershell job 
    $JobAction = & $JobScriptPath -FolderName $Software.Name
    
    if(!($JobAction -is [int]))
    {
        $Software.DownloadedVersion = $JobAction.Version
        $Software.DownloadDate = $JobAction.Date
    }
    else {
        #Nothing
    }

    if($Software.DownloadedVersion -gt $Software.InstalledVersion)
    {
        "Need to update software: {0}, ID: {1}, current: {2}, new version: {3}" -f $Software.Name, $Software.ID, $Software.InstalledVersion, $Software.DownloadedVersion
        $BuildList += [PSCustomObject]@{
            Name = $Software.Name
            NewVersion = $Software.DownloadedVersion
            OldVersion = $Software.DownloadedVersion
            IntuneID = $Software.ID
        }

        Write "Current buildlist: "
        $BuildList
    
    }
}





#Zapisyanie wszelkich zmian do pliku JSON
($SoftwareList | ConvertTo-Json) > $CurrentPath\software.json


