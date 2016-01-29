. "C:\Users\me-drift\Desktop\Get-Macaddresses-By-OU.ps1"
. "C:\Users\me-drift\Desktop\Send-WOL.ps1"

function Wake-OU {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [String]$OU_path
    )
    Write-Host "Fetching ip and mac addresses. This will take a while." -ForegroundColor Yellow
    $ip_and_macaddresses = Get-Macadresses-By-OU -OU_path $OU_path
    $ip_and_macaddresses
    Write-Host "`nDone fetching ip and mac addresses." -ForegroundColor Yellow 
    Write-Host "Sending WOL packets to" $ip_and_macaddresses.Count "ip addresses." -ForegroundColor Yellow

    # Send WOL packets to all ips in the table
    foreach($ip in $ip_and_macaddresses.keys.getenumerator()) {
        if($ip_and_macaddresses.Get_Item($ip).Length -eq 1) {
            # TODO! Fix this ghetto solution
            Send-WOL -ip $ip -mac_adr $ip_and_macaddresses.Get_Item($ip)[0]
        }
    }
}

$timer = [Diagnostics.Stopwatch]::StartNew()
Wake-OU -OU_path $infoterm_OU
$timer.Stop()
$timer.Elapsed
