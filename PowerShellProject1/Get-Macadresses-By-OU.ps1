
function Get-Macadresses-By-OU {
    # Fetches all mac addresses in a given OU, and returns a table
    # containing <computer_name, mac_address> key, value pairs.

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [String]$OU_path
    )


    # Get all computers in a given OU
    $OU_computers = Get-ADComputer -Filter {ObjectClass -eq "computer"} -SearchBase $OU_path -Properties *
    # Retrieve all computers from the SCCM server
    $SCCM_computers = Get-WmiObject -Class SMS_R_SYSTEM -Namespace "root\sms\site_UIO" -ComputerName "SCCM-PROD.UIO.NO"
 
    # Hash table containing <ip, mac-address> as a <key, value> pair
    $mac_address_table = @{}
    [String[]] $OU_computer_name_list = @()

    # Populate the name list with the computer names
    foreach($computer in $OU_computers) {
        $OU_computer_name_list += $computer.Name
        Write-Host $OU_computer_name_list
    }

    # Counter for objects matching between SCCM computers and OU computers
    $matching_objects = 0

    foreach($computer in $SCCM_computers) {
        # If a computer from sccm can be found in the OU, add the name and mac addr to the table
        if($OU_computer_name_list -contains $computer.Name) {
            $matching_objects++
            $mac_address_table.Add($computer.Name, $computer.MACAddresses)
        }
    }

    # For testing purposes.
    if($matching_objects -ne $OU_computer_name_list.Length) {
        Write-Host "Warning: Not all objects in OU could be found in SCCM."`
        "Incomplete table of mac addresses" -ForegroundColor Red
    }
    
    return $mac_address_table
}

#$infoterm_OU = "OU=hf,OU=infoterminal,OU=hf,OU=clients,DC=uio,DC=no"
$terminalstueklient_OU = "OU=terminalstueklient,OU=hf,OU=clients,DC=uio,DC=no"
#$eksamensklient_OU = "OU=eksamensklient,OU=hf,OU=clients,DC=uio,DC=no"

Get-Macadresses-By-OU -OU_path $terminalstueklient_OU