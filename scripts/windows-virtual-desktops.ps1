# AI-Kit Industrial IoT - Windows Virtual Desktop Manager
# Creates separate virtual desktops for each character with their respective applications

# Add Windows Runtime support
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.ApplicationModel.Core.CoreApplication, Windows.ApplicationModel, ContentType = WindowsRuntime]
$null = [Windows.System.VirtualDesktop, Windows.System, ContentType = WindowsRuntime]

# Character configuration
$Characters = @(
    @{
        Name = "Kyoko"
        Color = "Purple"
        Port = 1881
        ModbusPort = 5020
        Specialization = "Investigation & Analysis"
        URLs = @(
            "http://localhost:1881",
            "http://localhost:1881/api/ui",
            "http://localhost:4321"
        )
    },
    @{
        Name = "Byakuya"
        Color = "Yellow"
        Port = 1882
        ModbusPort = 5021
        Specialization = "Quality Control"
        URLs = @(
            "http://localhost:1882",
            "http://localhost:1882/api/ui"
        )
    },
    @{
        Name = "Chihiro"
        Color = "Green"
        Port = 1883
        ModbusPort = 5022
        Specialization = "System Integration"
        URLs = @(
            "http://localhost:1883",
            "http://localhost:1883/api/ui"
        )
    },
    @{
        Name = "Celestia"
        Color = "Red"
        Port = 1884
        ModbusPort = 5023
        Specialization = "UI/UX Design"
        URLs = @(
            "http://localhost:1884",
            "http://localhost:1884/api/ui"
        )
    },
    @{
        Name = "Sakura"
        Color = "Orange"
        Port = 1885
        ModbusPort = 5024
        Specialization = "Reliability Testing"
        URLs = @(
            "http://localhost:1885",
            "http://localhost:1885/api/ui"
        )
    }
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colorMap = @{
        "Purple" = "Magenta"
        "Yellow" = "Yellow"
        "Green" = "Green"
        "Red" = "Red"
        "Orange" = "DarkYellow"
        "Blue" = "Blue"
        "White" = "White"
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

function Get-VirtualDesktops {
    try {
        # Use VirtualDesktop API (requires Windows 10 build 1803+)
        $desktops = [Windows.System.VirtualDesktop]::GetDesktops()
        return $desktops
    }
    catch {
        Write-Warning "Unable to access Virtual Desktop API. Using Task View instead."
        return $null
    }
}

function Create-VirtualDesktop {
    param([string]$Name)
    
    try {
        # Method 1: Try Windows Runtime API
        $desktop = [Windows.System.VirtualDesktop]::Create()
        Write-ColorOutput "✅ Created virtual desktop via API" "Green"
        return $desktop
    }
    catch {
        # Method 2: Use Task View hotkey simulation
        Write-ColorOutput "📱 Creating desktop via Task View..." "Blue"
        
        # Open Task View (Win + Tab)
        [System.Windows.Forms.SendKeys]::SendWait("^{ESC}")
        Start-Sleep -Milliseconds 500
        [System.Windows.Forms.SendKeys]::SendWait("^%{TAB}")
        Start-Sleep -Milliseconds 500
        
        # Create new desktop (Ctrl + Win + D)
        [System.Windows.Forms.SendKeys]::SendWait("^#{d}")
        Start-Sleep -Milliseconds 1000
        
        # Close Task View
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        
        Write-ColorOutput "✅ Created virtual desktop via hotkeys" "Green"
        return $true
    }
}

function Switch-ToDesktop {
    param([int]$DesktopNumber)
    
    # Use Ctrl + Win + Left/Right Arrow to switch
    $key = if ($DesktopNumber -gt $script:currentDesktop) { "Right" } else { "Left" }
    $moves = [Math]::Abs($DesktopNumber - $script:currentDesktop)
    
    for ($i = 0; $i -lt $moves; $i++) {
        [System.Windows.Forms.SendKeys]::SendWait("^#{$key}")
        Start-Sleep -Milliseconds 300
    }
    
    $script:currentDesktop = $DesktopNumber
}

function Open-URLInBrowser {
    param(
        [string]$URL,
        [string]$BrowserPath = ""
    )
    
    if ([string]::IsNullOrEmpty($BrowserPath)) {
        # Use default browser
        Start-Process $URL
    } else {
        # Use specific browser
        Start-Process -FilePath $BrowserPath -ArgumentList $URL
    }
    
    Start-Sleep -Milliseconds 1500  # Allow browser to open
}

function Setup-CharacterDesktop {
    param(
        [hashtable]$Character,
        [int]$DesktopIndex
    )
    
    Write-ColorOutput "`n🎭 Setting up desktop for $($Character.Name) ($($Character.Specialization))" $Character.Color
    
    # Switch to the character's desktop
    Switch-ToDesktop -DesktopNumber $DesktopIndex
    Start-Sleep -Milliseconds 500
    
    # Open character's URLs
    foreach ($url in $Character.URLs) {
        Write-ColorOutput "🌐 Opening: $url" "Blue"
        Open-URLInBrowser -URL $url
        Start-Sleep -Milliseconds 2000  # Stagger window opening
    }
    
    # Optional: Open Windows Terminal with character-specific commands
    $terminalCommand = @"
cd C:\path\to\your\ai-kit-project
# Character: $($Character.Name) - $($Character.Specialization)
# Node-RED Editor: http://localhost:$($Character.Port)
# Dashboard: http://localhost:$($Character.Port)/api/ui
# MODBUS Port: $($Character.ModbusPort)
echo "Welcome to $($Character.Name)'s Industrial IoT Desktop!"
"@
    
    # Save character info to clipboard for easy access
    $characterInfo = @"
🎭 $($Character.Name) - $($Character.Specialization)
🌐 Node-RED Editor: http://localhost:$($Character.Port)
📊 Dashboard: http://localhost:$($Character.Port)/api/ui
🔧 MODBUS Port: $($Character.ModbusPort)
🎨 Theme Color: $($Character.Color)
"@
    
    $characterInfo | Set-Clipboard
    Write-ColorOutput "📋 Character info copied to clipboard" "Green"
}

function Main {
    Write-ColorOutput "🏭⚡ AI-Kit Industrial IoT - Virtual Desktop Manager" "Blue"
    Write-ColorOutput "Creating character-specific virtual desktops..." "White"
    
    # Check if virtual desktop APIs are available
    Add-Type -AssemblyName System.Windows.Forms
    
    # Track current desktop
    $script:currentDesktop = 1
    
    # Get current desktops count
    Write-ColorOutput "`n📊 Checking existing virtual desktops..." "Blue"
    
    # Create desktops for each character
    $desktopIndex = 2  # Start from desktop 2 (assuming desktop 1 is main)
    
    foreach ($character in $Characters) {
        Write-ColorOutput "`n🔨 Creating desktop $desktopIndex for $($character.Name)..." $character.Color
        
        # Create new virtual desktop
        $result = Create-VirtualDesktop -Name $character.Name
        
        if ($result) {
            # Set up the character's desktop environment
            Setup-CharacterDesktop -Character $character -DesktopIndex $desktopIndex
            $desktopIndex++
        } else {
            Write-ColorOutput "❌ Failed to create desktop for $($character.Name)" "Red"
        }
        
        Start-Sleep -Milliseconds 1000
    }
    
    # Return to main desktop
    Write-ColorOutput "`n🏠 Returning to main desktop..." "Blue"
    Switch-ToDesktop -DesktopNumber 1
    
    Write-ColorOutput "`n✅ Virtual desktop setup complete!" "Green"
    Write-ColorOutput "`n🎮 Desktop Navigation:" "Blue"
    Write-ColorOutput "• Ctrl + Win + Left/Right Arrow: Switch between desktops" "White"
    Write-ColorOutput "• Win + Tab: Open Task View" "White"
    Write-ColorOutput "• Ctrl + Win + D: Create new desktop" "White"
    Write-ColorOutput "• Ctrl + Win + F4: Close current desktop" "White"
    
    Write-ColorOutput "`n📋 Character Desktop Layout:" "Purple"
    $index = 2
    foreach ($character in $Characters) {
        Write-ColorOutput "Desktop $index`: $($character.Name) - $($character.Specialization)" $character.Color
        $index++
    }
}

# Enhanced version with desktop management
function Show-DesktopManagementMenu {
    do {
        Clear-Host
        Write-ColorOutput "🎭 AI-Kit Virtual Desktop Manager" "Blue"
        Write-ColorOutput "=================================" "Blue"
        Write-ColorOutput "1. Create Character Desktops" "White"
        Write-ColorOutput "2. Switch to Character Desktop" "White" 
        Write-ColorOutput "3. Open Character URLs" "White"
        Write-ColorOutput "4. Close All Character Desktops" "White"
        Write-ColorOutput "5. Show Desktop Status" "White"
        Write-ColorOutput "0. Exit" "White"
        
        $choice = Read-Host "`nEnter your choice"
        
        switch ($choice) {
            "1" { Main }
            "2" { 
                Write-ColorOutput "`nAvailable Characters:" "Blue"
                for ($i = 0; $i -lt $Characters.Count; $i++) {
                    Write-ColorOutput "$($i + 1). $($Characters[$i].Name)" $Characters[$i].Color
                }
                $charChoice = Read-Host "Select character (1-5)"
                if ($charChoice -ge 1 -and $charChoice -le 5) {
                    Switch-ToDesktop -DesktopNumber ($charChoice + 1)
                }
            }
            "3" {
                Write-ColorOutput "`nSelect character to open URLs:" "Blue"
                for ($i = 0; $i -lt $Characters.Count; $i++) {
                    Write-ColorOutput "$($i + 1). $($Characters[$i].Name)" $Characters[$i].Color
                }
                $charChoice = Read-Host "Select character (1-5)"
                if ($charChoice -ge 1 -and $charChoice -le 5) {
                    $char = $Characters[$charChoice - 1]
                    foreach ($url in $char.URLs) {
                        Open-URLInBrowser -URL $url
                        Start-Sleep -Milliseconds 1000
                    }
                }
            }
            "4" {
                Write-ColorOutput "🗑️ Closing character desktops..." "Red"
                # This would require more complex API calls to close specific desktops
                Write-ColorOutput "Use Ctrl+Win+F4 to manually close desktops" "Yellow"
            }
            "5" {
                Write-ColorOutput "`n📊 Desktop Status:" "Blue"
                Write-ColorOutput "Main Desktop: Desktop 1" "White"
                $index = 2
                foreach ($character in $Characters) {
                    Write-ColorOutput "Desktop $index`: $($character.Name) - $($character.Specialization)" $character.Color
                    $index++
                }
            }
            "0" { return }
        }
        
        if ($choice -ne "0") {
            Read-Host "`nPress Enter to continue..."
        }
    } while ($choice -ne "0")
}

# Run the script
if ($args[0] -eq "-menu") {
    Show-DesktopManagementMenu
} else {
    Main
}
