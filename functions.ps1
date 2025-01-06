function test-doIHaveRole(){
    # Determine if permission is held by the *current* user.
    # Default switch/role is 'administrator'
    # Forces user to specify a 'role' - 
    # Enumerate possibile roles with: [Security.Principal.WindowsBuiltInRole].GetEnumValues()
    param (
        [Security.Principal.WindowsBuiltInRole]$role = [Security.Principal.WindowsBuiltInRole]::Administrator
    )
    $user = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $user.IsInRole($role)
}

function get-CurrentDir(){
    # Shows casting an object into a string
    return [string]$(Get-Location)
}

function get-ScriptDir(){
    # Shows where script is, not where it's running
    # Useful for finding other files alongside the script
    return [string]$($PSScriptRoot)
}

function get-CurrentUserHomeDir(){
    # Shows returning a system environment variable
    return [string]$($env:USERPROFILE)
}

function get-ScriptName(){
    # Return Script Name (Without Path)
    # $MyInvocation.ScriptName
    return [string]$(Split-Path $MyInvocation.PSCommandPath -Leaf)
}

function get-TempDir(){
    # Get system defined temporary writeable path
    # Guaranteed writable 
    return [string]$([System.IO.Path]::GetTempPath())
}

function get-TempFile(){
    # Get system defined temporary writeable file
    # Specify extension if necessary, otherwise will be .tmp
    param (
        [Parameter(Mandatory=$False)]
        [string]$Extension,
        [Parameter(Mandatory=$False)]
        [string]$FileName
    )
   
    If ($PSBoundParameters.ContainsKey('Extension')){
        $OutputPath = [string]$([System.IO.Path]::GetTempFileName())
        If ($Extension -notmatch "^\.") {$Extension = ".$($Extension)"}
        $OutputPath = $OutputPath -replace "\.tmp$", $Extension
    } elseif ($PSBoundParameters.ContainsKey('FileName')){
        $OutputPath = Join-Path -Path $([System.IO.Path]::GetTempPath()) -ChildPath $FileName
    } else {
        $OutputPath = [string]$([System.IO.Path]::GetTempFileName())
    }

    return [string]$($OutputPath)
}

function Get-FileVersion(){
    # avoiding interface and SxS issues, returns the versioninfo from a file.
    param (
         [Parameter(Mandatory=$True)]
         [string]$FilePath
    )
    $oInfo = $(get-item -Path $FilePath).VersionInfo

    return "$($oInfo.FileMajorPart).$($oInfo.FileMinorPart).$($oInfo.FileBuildPart).$($oInfo.FilePrivatePart)"
}

function write-Log(){
    # Write log to file, make function pipeline capable as an example.
    # Use example to show validateset for input parameters (shortcut defining own enum)
    # Default to %temp%\scriptname.log 
    # Demonstrate long method of function definitions

    param (
        [Parameter(
            Mandatory=$true, 
            ValueFromPipeline=$true, 
            Position=0)]
        [ValidateNotNullorEmpty()]
        [string]$Message,
        [Parameter(Mandatory=$false)] 
        [ValidateSet("EventLog","File")]
        [String]$Destination = "File",
        [Parameter(Mandatory=$false)]
        [ValidateSet("Information","Warning","Error","Debug","Verbose")]
        [String]$Level = "Information",
        [Parameter(Mandatory=$false)]
        [string]$LogFile = [System.IO.Path]::ChangeExtension($(Join-Path -Path $(get-TempDir) -ChildPath $(get-ScriptName)),".log"),
        [Parameter(Mandatory=$false)]
        [switch]$Visible
    )

    # Iterate once per call
    Begin {
        #Convert Level to Event Log compatible value
        Switch ($Level) { 
            "information" { $ELEntryType = "Information" } 
            "warning"     { $ELEntryType = "Warning" }
            "error"       { $ELEntryType = "Error" }
            "debug"       { $ELEntryType = "Information" }
            "verbose"     { $ELEntryType = "Information" }
        }
        If ($Visible) {
            Write-Host "Writing to Logfile $LogFile"
        }
    }

    # Iterate once per item on the pipeline
    Process {
        $TotalMessage = "$((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) [$($Level)] $($Message)"

    # Write Content to File
        Switch ($Destination) { 
            "File" {
                Add-Content -Path $LogFile -Value $TotalMessage
            }
            "EventLog" {
                # If necessary - change later to add intelligence about source etc.
                # Combine this later: [System.Diagnostics.EventLogEntryType]$entryType = "Information"
                Write-EventLog -LogName "Application" -Source "Application" -EventID 1 -EntryType $ELEntryType -Message $TotalMessage
            }
        }

        If ($Visible) {
            $ScreenMessage = "$($TotalMessage)"

            Switch ($Level) { 
                "information" { Write-Host "$ScreenMessage" } 
                "warning"     { Write-Warning "$ScreenMessage" }
                "error"       { Write-Error "$ScreenMessage" }
                "debug"       { Write-Debug "$ScreenMessage" -Debug:$true }
                "verbose"     { Write-Verbose "$ScreenMessage" -Verbose:$true }
            }

        }
    }

}
