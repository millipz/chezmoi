#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Emoji helpers
print_step() {
    echo -e "${BLUE}🚀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Ask for admin password upfront
print_step "Requesting administrator privileges..."
sudo -v

# Keep sudo alive in background
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Install Xcode Command Line Tools if not present
install_xcode_tools() {
    print_step "Checking for Xcode Command Line Tools..."
    if ! xcode-select -p &>/dev/null; then
        print_step "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation to complete
        print_warning "Please complete the Xcode Command Line Tools installation in the dialog, then press any key to continue..."
        read -n 1 -s
        
        # Verify installation
        if ! xcode-select -p &>/dev/null; then
            print_error "Xcode Command Line Tools installation failed or incomplete"
            exit 1
        fi
    fi
    print_success "Xcode Command Line Tools are installed"
}

# Install Homebrew
install_homebrew() {
    print_step "Checking for Homebrew..."
    if ! command -v brew &>/dev/null; then
        print_step "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        if [[ $(uname -m) == 'arm64' ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        print_success "Homebrew is already installed"
    fi
    
    # Verify brew is working
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew installation failed or not in PATH"
        exit 1
    fi
    
    print_step "Updating Homebrew..."
    brew update
    print_success "Homebrew is ready"
}

# Add Homebrew to shell profile permanently
setup_brew_path() {
    print_step "Setting up Homebrew in shell profile..."
    
    local shell_profile=""
    case "$SHELL" in
        */zsh) shell_profile="$HOME/.zprofile" ;;
        */bash) shell_profile="$HOME/.bash_profile" ;;
        *) shell_profile="$HOME/.profile" ;;
    esac
    
    local brew_path_cmd=""
    if [[ $(uname -m) == 'arm64' ]]; then
        brew_path_cmd='eval "$(/opt/homebrew/bin/brew shellenv)"'
    else
        brew_path_cmd='eval "$(/usr/local/bin/brew shellenv)"'
    fi
    
    if ! grep -q "brew shellenv" "$shell_profile" 2>/dev/null; then
        echo "$brew_path_cmd" >> "$shell_profile"
        print_success "Added Homebrew to $shell_profile"
    else
        print_success "Homebrew already in shell profile"
    fi
}

# Install chezmoi
install_chezmoi() {
    print_step "Installing chezmoi..."
    if ! command -v chezmoi &>/dev/null; then
        brew install chezmoi
    else
        print_success "chezmoi is already installed"
    fi
}

# No GitHub authentication needed for public repos

# Prompt for work or home setup
choose_environment() {
    # Check if environment is already set via environment variable
    if [[ -n "${MACHINE:-}" ]]; then
        case "${MACHINE}" in
            "home"|"work")
                CHEZMOI_ENV="${MACHINE}"
                print_success "Using environment from MACHINE variable: $CHEZMOI_ENV"
                return 0
                ;;
        esac
    fi
    
    echo
    echo "============================================"
    print_step "Choose your environment setup:"
    echo "============================================"
    echo "1) Home"
    echo "2) Work"
    echo "============================================"
    echo
    
    while true; do
        printf "Enter choice (1 or 2): "
        read choice < /dev/tty
        case $choice in
            1) 
                CHEZMOI_ENV="home"
                break
                ;;
            2) 
                CHEZMOI_ENV="work"
                break
                ;;
            *) 
                print_warning "Please enter 1 or 2"
                ;;
        esac
    done
    
    print_success "Environment set to: $CHEZMOI_ENV"
    echo
}

# Initialize chezmoi with your dotfiles
init_chezmoi() {
    print_step "Initializing chezmoi with your dotfiles..."
    
    # Set the template variable for chezmoi
    export CHEZMOI_MACHINE="$CHEZMOI_ENV"
    
    if [ ! -d "$HOME/.local/share/chezmoi" ]; then
        chezmoi init --apply https://github.com/millipz/chezmoi.git
    else
        print_warning "chezmoi already initialized, updating..."
        chezmoi update --apply
    fi
    
    print_success "chezmoi initialization complete"
}

# Install Homebrew packages
install_brew_packages() {
    print_step "Installing Homebrew packages..."
    
    # chezmoi should have created the Brewfile, let's use it
    if [ -f "$HOME/Brewfile" ]; then
        brew bundle --file="$HOME/Brewfile"
    elif [ -f "$HOME/.Brewfile" ]; then
        brew bundle --file="$HOME/.Brewfile"
    else
        print_warning "No Brewfile found, skipping brew bundle install"
        return 0
    fi
    
    print_success "Homebrew packages installed"
}

# Final steps
finish_setup() {
    print_success "Boomstrap complete! 🎉"
    echo
    print_step "Next steps:"
    echo "1. Restart your terminal to load new shell configuration"
    echo "2. Run 'chezmoi edit-config' to customize chezmoi settings"
    echo "3. Use 'chezmoi add <file>' to track new dotfiles"
    echo "4. Use 'chezmoi apply' to apply changes"
    echo "5. Use 'chezmoi cd' to edit your dotfiles repository"
    echo
    print_warning "Some applications may require manual configuration or login"
}

# Main execution
main() {
    echo "🚀 macOS Bootstrap Script"
    echo "========================="
    echo
    
    install_xcode_tools
    install_homebrew
    setup_brew_path
    install_chezmoi
    choose_environment
    init_chezmoi
    install_brew_packages
    run_post_install_scripts
    finish_setup
}

# Run main function
main "$@"
