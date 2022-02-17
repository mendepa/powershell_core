param(
    $folderName
)


$Path = Get-Location

$InstallatorName = [String]((Invoke-WebRequest -Uri "https://sfc-repo.azure.snowflakecomputing.com/odbc/win32/latest/index.html").Links.Href | Select-String -Pattern "snowflake")
$DownloadLink = "https://sfc-repo.azure.snowflakecomputing.com/odbc/win32/latest/$InstallatorName"
$DownloadPath = "$Path\download\$folderName"

if(!(Test-Path $DownloadPath)){New-Item -Path "$Path\download\" -Name $folderName -ItemType Directory}

if (!(Get-Item $DownloadPath\$InstallatorName -ErrorAction SilentlyContinue ))
{   
    Invoke-WebRequest -Uri $DownloadLink -OutFile "$DownloadPath\$InstallatorName" -PassThru

    $InstallatorVersion = $InstallatorName.Split("-")[1].Split(".msi")[0]
    $result = [PSCustomObject]@{
        Version = $InstallatorVersion 
        Date = Get-Date -Format "MM/dd/yyyy HH:mm"
    }

    return $result

}
return -1


