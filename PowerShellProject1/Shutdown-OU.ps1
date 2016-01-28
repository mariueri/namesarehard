function Shutdown-OU {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        [String]$OU_path
    )

    $OU_computers = Get-ADComputer -Filter {ObjectClass -eq "computer"} -SearchBase $OU_path

    foreach($computer in $OU_computers) {
        $is_online = Test-Connection -ComputerName $computer.Name -Quiet -Count 1

        if($is_online -eq $True) {
            Stop-Computer -ComputerName $computer.Name -Force
        }
    }
}