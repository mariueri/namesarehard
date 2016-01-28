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
        [int]$port=1337
    )
    
    $target_ip = [Net.IPAddress]::Parse($ip)

    # Convert the mac address to byte form. Supports formats separated by ". : -"
    $byte_mac_adr =  $mac_adr -split "[:\-\.]" | ForEach-Object { [Byte] "0x$_"} 
    $WOL_packet = (,[byte]255 * 6) + ($byte_mac_adr * 16)
 
    $UDPclient = new-Object System.Net.Sockets.UdpClient
    
    $UDPclient.Connect($target_ip, $port)

    $bytes_sent = $UDPclient.Send($WOL_packet, $WOL_packet.Length)

    Write-Host "`nPacket sent to:" $target_ip -ForegroundColor Yellow
    Write-Host "Packet size in bytes:" $WOL_packet.Length -ForegroundColor Yellow
    Write-Host "Bytes sent to target ip: " $bytes_sent -ForegroundColor Yellow

    if($bytes_sent -lt $WOL_packet.Length) {
        Write-Host "Partial or no WOL packet sent to" $ip -ForegroundColor Red
    }

    $UDPclient.Close()

}

# Send-WOL -mac_adr "84:8F:69:F8:A8:29" -ip 129.240.162.171 -port 9001
# Stop-Computer "hf-162-171" -Force
