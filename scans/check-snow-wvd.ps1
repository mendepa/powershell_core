
[CmdletBinding()]
param (
    [Parameter()]
    [TypeName]
    $NetworkPath,

    [Parameter()]
    [String]
    $IgnoreScanned = $false
)

if($IgnoreScanned -xor [datetime](((Get-ChildItem "C:\Program Files\Snow Software\Inventory\Agent\data\" -Filter "*.snowpack") | Sort-Object LastWriteTime)[-1]).LastWriteTime.AddMinutes(30) -lt (Get-Date))
{
    return 0
}

$hostname = $env:COMPUTERNAME
Push-Location "C:\Program Files\Snow Software\Inventory\Agent"

try {
    Start-Process snowagent.exe -ArgumentList "scan" -Wait

    try {
        [void](New-PSDrive -Root "\\danece\CPZ-Wymiana\mendepa\WVD_scans" -PSProvider FileSystem -Name "X" -Credential $using:cred)
        
        Copy-Item -Path ((Get-ChildItem "C:\Program Files\Snow Software\Inventory\Agent\data\" -Filter "*.snowpack") | Sort-Object LastWriteTime)[-1].FullName -Destination "X:\$hostname.snowpack"
        
        Remove-PSDrive -Name "X"
        
        Start-Process snowagent.exe -ArgumentList "send" -Wait
        Write-Host "Report sent from: $hostname"
    }
    catch {Write-Warning $Error[0]}
}
catch {
    Write-Error "snowagent.exe not found"
}


