# AI-Kit Industrial IoT - Simple Virtual Desktop Creator
# Uses keyboard shortcuts to create character desktops reliably

param(
    [switch]$CreateAll,
    [switch]$Menu,
    [string]$Character = ""
)

# Character definitions
$Characters = @{
    "Kyoko" = @{
        Color = "Magenta"
        Port = 1881
        URLs = @("http://localhost:1881", "http://localhost:1881/api/ui")
        Specialization = "Investigation & Analysis"
    }
    "Byakuya" = @{
        Color = "Yellow" 
        Port = 1882
        URLs = @("http://localhost:1882", "http://localhost:1882/api/ui")
        Specialization = "Quality Control"
    }
    "Chihiro" = @{
        Color = "Green"
        Port = 1883
        URLs = @("http://localhost:1883", "http://localhost:1883/api/ui")
        Specialization = "System Integration"
    }
    "Celestia" = @{
        Color = "Red"
        Port = 1884
        URLs = @("http://localhost:1884", "http://localhost:1884/api/ui")
        Specialization = "UI/UX Design"
    }
    "Sakura" = @{
        Color = "DarkYellow"
        Port = 1885
        URLs = @("http://localhost:1885", "http://localhost:1885/api/ui")
        Specialization = "Reliability Testing"
    }
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Create-NewDesktop {
    Write-ColorOutput "🖥️ Creating new virtual desktop..." "Blue"
    
    # Create new desktop using Ctrl+Win+D
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("^#{d}")
    Start-Sleep -Seconds 2
    
    Write-ColorOutput "✅ Desktop created!" "Green"
}

function Switch-DesktopRight {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("^#{Right}")
    Start-Sleep -Milliseconds 500
}

function Switch-DesktopLeft {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("^#{Left}")
    Start-Sleep -Milliseconds 500
}

function Open-CharacterURLs {
    param([hashtable]$CharacterData)
    
    foreach ($url in $CharacterData.URLs) {
        Write-ColorOutput "🌐 Opening: $url" "Blue"
        Start-Process $url
        Start-Sleep -Seconds 2
    }
}

function Setup-CharacterDesktop {
    param(
        [string]$CharacterName,
        [hashtable]$CharacterData
    )
    
    Write-ColorOutput "`n🎭 Setting up desktop for $CharacterName" $CharacterData.Color
    Write-ColorOutput "   Specialization: $($CharacterData.Specialization)" "Gray"
    
    # Create new desktop
    Create-NewDesktop
    
    # Open character's applications
    Open-CharacterURLs -CharacterData $CharacterData
    
    # Optional: Set desktop wallpaper based on character
    # This would require additional Windows API calls
    
    Write-ColorOutput "✅ $CharacterName desktop ready!" $CharacterData.Color
}

function Create-AllCharacterDesktops {
    Write-ColorOutput "🏭 AI-Kit Industrial IoT - Virtual Desktop Setup" "Cyan"
    Write-ColorOutput "Creating desktops for all characters..." "White"
    
    # Start from main desktop
    Write-ColorOutput "`n🏠 Starting from main desktop..." "Blue"
    
    # Create desktop for each character
    foreach ($characterName in $Characters.Keys | Sort-Object) {
        Setup-CharacterDesktop -CharacterName $characterName -CharacterData $Characters[$characterName]
        Start-Sleep -Seconds 1
    }
    
    # Return to main desktop
    Write-ColorOutput "`n🏠 Returning to main desktop..." "Blue"
    for ($i = 0; $i -lt $Characters.Count; $i++) {
        Switch-DesktopLeft
    }
    
    Write-ColorOutput "`n✅ All character desktops created!" "Green"
    Show-NavigationHelp
}

function Show-NavigationHelp {
    Write-ColorOutput "`n🎮 Virtual Desktop Navigation:" "Yellow"
    Write-ColorOutput "• Ctrl + Win + Left/Right: Switch between desktops" "White"
    Write-ColorOutput "• Win + Tab: Open Task View to see all desktops" "White"
    Write-ColorOutput "• Ctrl + Win + D: Create new desktop" "White"
    Write-ColorOutput "• Ctrl + Win + F4: Close current desktop" "White"
    
    Write-ColorOutput "`n📋 Character Desktop Order:" "Yellow"
    Write-ColorOutput "Desktop 1: Main/Overview" "White"
    $index = 2
    foreach ($name in $Characters.Keys | Sort-Object) {
        Write-ColorOutput "Desktop $index`: $name - $($Characters[$name].Specialization)" $Characters[$name].Color
        $index++
    }
}

function Show-Menu {
    do {
        Clear-Host
        Write-ColorOutput "🎭 AI-Kit Virtual Desktop Manager" "Cyan"
        Write-ColorOutput "=================================" "Cyan"
        Write-ColorOutput "1. Create all character desktops" "White"
        Write-ColorOutput "2. Create single character desktop" "White"
        Write-ColorOutput "3. Switch to next desktop" "White"
        Write-ColorOutput "4. Switch to previous desktop" "White"
        Write-ColorOutput "5. Show navigation help" "White"
        Write-ColorOutput "6. Open main dashboard" "White"
        Write-ColorOutput "0. Exit" "White"
        
        $choice = Read-Host "`nEnter choice"
        
        switch ($choice) {
            "1" { 
                Create-AllCharacterDesktops
                Read-Host "Press Enter to continue..."
            }
            "2" {
                Write-ColorOutput "`nAvailable characters:" "Blue"
                $charList = $Characters.Keys | Sort-Object
                for ($i = 0; $i -lt $charList.Count; $i++) {
                    $char = $charList[$i]
                    Write-ColorOutput "$($i+1). $char - $($Characters[$char].Specialization)" $Characters[$char].Color
                }
                $selection = Read-Host "Select character (1-$($charList.Count))"
                if ($selection -match '^\d+$' -and [int]$selection -ge 1 -and [int]$selection -le $charList.Count) {
                    $selectedChar = $charList[[int]$selection - 1]
                    Setup-CharacterDesktop -CharacterName $selectedChar -CharacterData $Characters[$selectedChar]
                }
                Read-Host "Press Enter to continue..."
            }
            "3" {
                Switch-DesktopRight
                Write-ColorOutput "🔄 Switched to next desktop" "Green"
                Start-Sleep -Seconds 1
            }
            "4" {
                Switch-DesktopLeft
                Write-ColorOutput "🔄 Switched to previous desktop" "Green"
                Start-Sleep -Seconds 1
            }
            "5" {
                Show-NavigationHelp
                Read-Host "Press Enter to continue..."
            }
            "6" {
                Write-ColorOutput "🌐 Opening main AI-Kit dashboard..." "Blue"
                Start-Process "http://localhost:4321"
                Start-Sleep -Seconds 1
            }
            "0" { break }
            default {
                Write-ColorOutput "Invalid choice. Please try again." "Red"
                Start-Sleep -Seconds 1
            }
        }
    } while ($true)
}

# Main execution logic
if ($Menu) {
    Show-Menu
}
elseif ($CreateAll) {
    Create-AllCharacterDesktops
}
elseif ($Character -and $Characters.ContainsKey($Character)) {
    Setup-CharacterDesktop -CharacterName $Character -CharacterData $Characters[$Character]
}
else {
    Write-ColorOutput "🎭 AI-Kit Virtual Desktop Manager" "Cyan"
    Write-ColorOutput "Usage:" "White"
    Write-ColorOutput "  .\windows-virtual-desktops-simple.ps1 -Menu" "Yellow"
    Write-ColorOutput "  .\windows-virtual-desktops-simple.ps1 -CreateAll" "Yellow"
    Write-ColorOutput "  .\windows-virtual-desktops-simple.ps1 -Character 'Kyoko'" "Yellow"
    Write-ColorOutput ""
    Write-ColorOutput "Available characters: $($Characters.Keys -join ', ')" "Blue"
}
