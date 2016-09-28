<#
.Synopsis
   Detects if computers have pending reboots.
.DESCRIPTION
   Takes a string array of computer names and returns 
   the computer's reboot status.
.EXAMPLE
   Get-RebootStatus $ComputerNames
.EXAMPLE
   $ComputerNames | Get-RebootStatus
#>
Function Get-RebootStatus
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]$ComputerNames
    )

    Process
    {
        Foreach ($ComputerName in $ComputerNames)
        {
            Try
            {
                $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
                $RegistryKey = $Registry.OpenSubKey('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired')

                If ($RegistryKey.ValueCount -gt 0)
                {
                    $Reboot = 'Pending'
                }
                Else
                {
                    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $ComputerName)
                    $RegistryKey= $Registry.OpenSubKey('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending')

                    If ($RegistryKey.ValueCount -gt 0)
                    {
                        $Reboot = 'Pending'
                    }
                    Else
                    {
                        $Reboot = 'No'
                    }
                }

            }
            Catch
            {
                $Reboot = "Unable to connect to system's registry"
            }

            [psobject]$System = @{
                'Name' = $ComputerName;
                'Reboot' = $Reboot
                }

            $System
        }
    }
}