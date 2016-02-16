function Get-Computer-Report {
    <#
    .SYNOPSIS
        Retrieves all computer models and their frequency in a given OU
    .DESCRIPTION
        Gets all computer objects from a given OU path. The model
        frequencies are then gathered and written to the screen.
    .PARAMETER OU_path
        The OU path provided as parameter is used as the searchbase
        for the Get-ADComputer function
    .NOTES
        This script can be executed from lita-ts.
        While gathering information from larger OUs, the script is 
        quite slow. 173 computers took 1 min 27 seconds.
    .EXAMPLE
        Get-Computer-Report -OU_path "OU=terminalstueklient,OU=hf,OU=clients,DC=uio,DC=no"
        
        This will generate a report for the terminalstueklient OU
        
        Output:
    Count Name                     
    ----- ----                     
    72 OptiPlex 7010            
     1 HP Compaq 8200 Elite S...
     1 HP Compaq Elite 8300 SFF 
    16 HP Compaq 8200 Elite U...
    12 OptiPlex 780          ...
    19 OptiPlex 760          ...
     1 OptiPlex 7020            
    35 OptiPlex 790             
        
    #>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=1)]
        [String] $OU_path
    )

    # A list containing the model of a computer
    $models = @()
    # Get all the computers of a given OU
    $computer_list = Get-ADComputer -Filter {ObjectClass -eq "computer"} -searchBase $OU_path
  

    foreach($computer in $computer_list) {
        
        $is_online = Test-Connection $computer.Name -Quiet -Count 1
        
        if($is_online -eq $true) {
            $models += Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer.Name | select Model
        }
    }

    $models | Group-Object Model -NoElement
}

$OU_path = "OU=terminalstueklient,OU=hf,OU=clients,DC=uio,DC=no"

$timer = [Diagnostics.Stopwatch]::StartNew()
Get-Computer-Report -OU_path $OU_path
$timer.Stop()
$timer.Elapsed
