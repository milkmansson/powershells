# Script enables all systray icons at once.
# Suggestion: make a scheduled task and run this every so often so updates to things like discord don't disappear the icon from the systray.

# To schedule, save this somewhere, like:
$scriptLocation = "$($env:userprofile)\Scripts\Show-AllSystrayIcons.ps1"

# Taskbar Icon Location
$subkeys = Get-ChildItem -Path "HKCU:\Control Panel\NotifyIconSettings"

foreach ($subkey in $subkeys) {
    # Retrieve the properties of the current subkey
    $properties = Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue
    
    # Check if the 'IsPromoted' property exists, if 0, change to 1
    if ($properties.PSObject.Properties.Name -contains "IsPromoted") {
        if ($properties.IsPromoted -eq 0) {
            # Change 'IsPromoted' value to 1
            Set-ItemProperty -Path $subkey.PSPath -Name "IsPromoted" -Value 1
            Write-Output "Updated: $($subkey.PSChildName) - IsPromoted set to 1"
        } else {
            Write-Output "No change needed: $($subkey.PSChildName) - IsPromoted is already $($properties.IsPromoted)"
        }
    } else {
        # Documentation lies a little - sets the IsPromoted for items without the key already so they will still show.
        #Write-Output "Skipping: $($subkey.PSChildName) - IsPromoted property not found"
        Write-Output "$($subkey.PSChildName) - IsPromoted property not found but doing it anyway"
        Set-ItemProperty -Path $subkey.PSPath -Name "IsPromoted" -Value 1
    }
}

# Documentation suggests that a restart of explorer is necessary to make this effective.  However, sending WM_SETTINGCHANGE message is significantly less severe.
$signature = @'
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SendMessageTimeout(IntPtr hWnd, int Msg, IntPtr wParam, string lParam, int fuFlags, int uTimeout, out IntPtr lpdwResult);
'@

$User32 = Add-Type -MemberDefinition $signature -Name "Win32SendMessageTimeout" -Namespace Win32Functions -PassThru
$HWND_BROADCAST = [IntPtr]0xFFFF
$WM_SETTINGCHANGE = 0x1A
$null = $User32::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [IntPtr]::Zero, "TraySettings", 2, 5000, [ref]([IntPtr]::Zero))

# When you can be bothered, put error checking on the previous line and then make this one more accurate.
Write-Output "Explorer has been notified to refresh settings!"
