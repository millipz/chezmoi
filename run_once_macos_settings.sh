#!/bin/bash

# macOS System Settings Configuration
# This script configures macOS system preferences consistently across machines

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "🎛️  Configuring macOS System Settings"
echo "====================================="

# Dock Configuration
print_step "Configuring Dock settings..."

# Remove all apps from the dock
defaults write com.apple.dock persistent-apps -array
print_success "Cleared all apps from Dock"

# Turn on auto-hiding dock
defaults write com.apple.dock autohide -bool true
print_success "Enabled Dock auto-hide"

# Optional: Set dock size and position
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-recents -bool false
print_success "Set Dock size and behavior"

# Sound Configuration
print_step "Configuring sound settings..."

# Turn off all alert sounds
defaults write com.apple.systemsound "com.apple.sound.beep.volume" -float 0
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0
defaults write com.apple.sound.beep.volume -float 0

# Turn off UI sound effects
defaults write com.apple.systemsound "com.apple.sound.uiaudio.enabled" -int 0
defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

print_success "Disabled alert sounds"

# Turn on flashing alerts (visual bell)
defaults write NSGlobalDomain com.apple.sound.beep.flash -bool true
print_success "Enabled visual flash alerts"

# Keyboard Shortcuts
print_step "Setting up keyboard shortcuts..."
echo
echo "📋 Manual Step Required:"
echo "1. Open System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts"
echo "2. Click the '+' button to add a new shortcut"
echo "3. Application: System Settings"
echo "4. Menu Title: (leave blank)"
echo "5. Keyboard Shortcut: Press ⌘⌥, (cmd-alt-comma)"
echo "6. Click 'Add'"
echo
read -p "Press any key when you've completed the keyboard shortcut setup..." -n1 -s
echo
print_success "Keyboard shortcut setup acknowledged"

# Display Configuration
print_step "Configuring display settings..."
echo
echo "🖥️  Manual Step Required:"
echo "1. Open System Settings > Displays"
echo "2. Select 'More Space' (this gives you the highest effective resolution)"
echo "3. If you have multiple displays, repeat for each one"
echo
read -p "Press any key when you've set the display resolution..." -n1 -s
echo
print_success "Display resolution setup acknowledged"

# Additional useful settings
print_step "Applying additional system settings..."

# Finder settings
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"  # Search current folder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
print_success "Configured Finder settings"

# Trackpad settings
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
print_success "Enabled tap to click"

# Keyboard settings
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
print_success "Configured keyboard repeat settings"

# Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
print_success "Configured screenshot settings"

# Menu bar
defaults write NSGlobalDomain _HIHideMenuBar -bool false
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss a"
print_success "Configured menu bar"

# Restart affected services
print_step "Restarting system services..."

# Kill affected applications to apply changes
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true
killall cfprefsd 2>/dev/null || true

print_success "Restarted system services"

echo
print_success "macOS configuration complete! 🎉"
echo
print_step "All settings applied successfully. Some changes may require a logout/login to take full effect."