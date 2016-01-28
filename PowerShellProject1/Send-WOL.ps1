#TODO: Several objects has multiple mac addresses, update so the function
# can take a lits of mac addresses.

function Send-WOL {
    # Sends a wake-up packet to devices that needs to be turned on.
    # The structure of the packet is 6 * 0xFF, followed by the byte
    # representation of the mac address * 16.
    #
    # Since the UDP protocol is used, there are no guarantees that the 
    # packets sent are recieved. This means that there will be no error 
    # messages if they fail to reach the target device.


    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [string]$mac_adr,
        [string]$ip,
        [int]$port
    )
    try {
        $target_ip = [Net.IPAddress]::Parse($ip)
    } catch {
        Write-Host "Warning: IP error." $_.Exception.Message " WOL packet not sent." -ForegroundColor Red
        Break
    }

    # Convert the mac address to byte form. Supports formats separated by ". : -"
    $byte_mac_adr =  $mac_adr -split "[:\-\.]" | ForEach-Object { [Byte] "0x$_"} 
    $WOL_packet = (,[byte]255 * 6) + ($byte_mac_adr * 16)
 
    $UDPclient = new-Object System.Net.Sockets.UdpClient
    
    $UDPclient.Connect($target_ip, $port)

    $bytes_sent = $UDPclient.Send($WOL_packet, $WOL_packet.Length)

    if($bytes_sent -lt $WOL_packet.Length) {
        Write-Host "Partial or no WOL packet sent to" $ip -ForegroundColor Red
    }

    $UDPclient.Close()

}
