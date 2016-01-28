
function Get-Macadresses-By-OU {
    # Fetches all mac addresses in a given OU, and returns a table
    # containing <ip, mac_addresses> key, value pairs.

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [String]$OU_path
    )


    # Get all computers in a given OU
    $OU_computers = Get-ADComputer -Filter {ObjectClass -eq "computer"} -SearchBase $OU_path -Properties IPv4Address
    # Retrieve all computers from the SCCM server
    $SCCM_computers = Get-WmiObject -Class SMS_R_SYSTEM -Namespace "root\sms\site_UIO" -ComputerName "SCCM-PROD.UIO.NO"
 
    # Hash table containing <ip, mac-addresses> as a <[String]key, [String[]]value> pair
    $mac_address_table = @{}

    # Counter for objects matching between SCCM computers and OU computers
    $matching_objects = 0

    # Todo: Faster solution. Bikkjetregt!
    foreach($SCCM_computer in $SCCM_computers) {
        foreach($OU_computer in $OU_computers) {
            # Computer found in both the OU and SCCM list
            if($SCCM_computer.Name -eq $OU_computer.Name) {
                $matching_objects++
                $mac_address_table.Add($OU_computer.IPv4Address, $SCCM_computer.MACAddresses)
            }
        }
    }

    # For testing purposes.
    if($matching_objects -ne $OU_computers.Length) {
        Write-Host "Warning: Not all objects in OU could be found in SCCM."`
        "Incomplete table of mac addresses" -ForegroundColor Red
    }
    
    return $mac_address_table
}

#$infoterm_OU = "OU=hf,OU=infoterminal,OU=hf,OU=clients,DC=uio,DC=no"
#$terminalstueklient_OU = "OU=terminalstueklient,OU=hf,OU=clients,DC=uio,DC=no"
#$eksamensklient_OU = "OU=eksamensklient,OU=hf,OU=clients,DC=uio,DC=no"

#Get-Macadresses-By-OU -OU_path $eksamensklient_OU