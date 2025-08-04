#!/bin/bash

# Update Brewfile.tmpl based on current local Homebrew state
# This script helps keep your dotfiles Brewfile in sync with local installs

set -e

CHEZMOI_DIR="$HOME/.local/share/chezmoi"
BREWFILE_TEMPLATE="$CHEZMOI_DIR/Brewfile.tmpl"
TEMP_BREWFILE="/tmp/current_brewfile_$(date +%s)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if we're in the right environment
if [ ! -f "$BREWFILE_TEMPLATE" ]; then
    print_error "Brewfile.tmpl not found at $BREWFILE_TEMPLATE"
    print_error "Make sure you're running this from a machine with chezmoi initialized"
    exit 1
fi

# Change to home directory for chezmoi commands
cd "$HOME"

print_step "Dumping current Homebrew state..."
brew bundle dump --file="$TEMP_BREWFILE"

print_warning "About to apply current Brewfile to ensure it's up to date..."
print_warning "This will install any missing packages from your Brewfile template."
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Cancelled"
    exit 0
fi

print_step "Applying current Brewfile to ensure it's up to date..."
chezmoi apply ~/Brewfile

print_step "Analyzing differences..."

# Create a temporary file with the current template applied
TEMP_TEMPLATE="/tmp/template_applied_$(date +%s)"
chezmoi cat ~/Brewfile > "$TEMP_TEMPLATE"

# Find new packages that aren't in the template
NEW_PACKAGES=()
while IFS= read -r line; do
    if [[ "$line" =~ ^(brew|cask|mas)\ \" ]]; then
        package=$(echo "$line" | sed 's/^[[:space:]]*\([^[:space:]]*\)[[:space:]]*"\([^"]*\)".*/\2/')
        if ! grep -q "\"$package\"" "$TEMP_TEMPLATE"; then
            NEW_PACKAGES+=("$line")
        fi
    fi
done < "$TEMP_BREWFILE"

# Find removed packages that are in template but not installed
REMOVED_PACKAGES=()
while IFS= read -r line; do
    if [[ "$line" =~ ^(brew|cask|mas)\ \" ]]; then
        package=$(echo "$line" | sed 's/^[[:space:]]*\([^[:space:]]*\)[[:space:]]*"\([^"]*\)".*/\2/')
        if ! grep -q "\"$package\"" "$TEMP_BREWFILE"; then
            REMOVED_PACKAGES+=("$line")
        fi
    fi
done < "$TEMP_TEMPLATE"

# Clean up temp files
rm -f "$TEMP_BREWFILE" "$TEMP_TEMPLATE"

# Report findings
if [ ${#NEW_PACKAGES[@]} -eq 0 ] && [ ${#REMOVED_PACKAGES[@]} -eq 0 ]; then
    print_success "Brewfile is up to date!"
    exit 0
fi

echo
print_step "Found changes:"

if [ ${#NEW_PACKAGES[@]} -gt 0 ]; then
    echo -e "${GREEN}New packages to add:${NC}"
    for package in "${NEW_PACKAGES[@]}"; do
        echo "  + $package"
    done
    echo
fi

if [ ${#REMOVED_PACKAGES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Packages that might be removed:${NC}"
    for package in "${REMOVED_PACKAGES[@]}"; do
        echo "  - $package"
    done
    echo
fi

# Ask user what to do
echo "Options:"
echo "1. Update Brewfile.tmpl with new packages"
echo "2. Show diff and edit manually"
echo "3. Cancel"

read -p "Choose an option (1-3): " choice

case $choice in
    1)
        print_step "Updating Brewfile.tmpl..."
        
        # Create backup
        cp "$BREWFILE_TEMPLATE" "$BREWFILE_TEMPLATE.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Add new packages to template
        for package in "${NEW_PACKAGES[@]}"; do
            # Determine if it's brew, cask, or mas
            if [[ "$package" =~ ^brew ]]; then
                # Add to brew section (before the first conditional)
                awk -v pkg="$package" '/{{ if eq .machine "work"}}/ {print pkg; print; next} {print}' "$BREWFILE_TEMPLATE" > "$BREWFILE_TEMPLATE.tmp" && mv "$BREWFILE_TEMPLATE.tmp" "$BREWFILE_TEMPLATE"
            elif [[ "$package" =~ ^cask ]]; then
                # Add to cask section (before the first conditional)
                awk -v pkg="$package" '/{{ if eq .machine "work"}}/ {print pkg; print; next} {print}' "$BREWFILE_TEMPLATE" > "$BREWFILE_TEMPLATE.tmp" && mv "$BREWFILE_TEMPLATE.tmp" "$BREWFILE_TEMPLATE"
            elif [[ "$package" =~ ^mas ]]; then
                # Add to mas section (before the first conditional)
                awk -v pkg="$package" '/{{ if eq .machine "work"}}/ {print pkg; print; next} {print}' "$BREWFILE_TEMPLATE" > "$BREWFILE_TEMPLATE.tmp" && mv "$BREWFILE_TEMPLATE.tmp" "$BREWFILE_TEMPLATE"
            fi
        done
        
        # Clean up backup files
        rm -f "$BREWFILE_TEMPLATE.bak"
        rm -f "$BREWFILE_TEMPLATE.backup."*
        
        print_success "Brewfile.tmpl updated!"
        print_step "Next steps:"
        echo "  1. Review the changes: chezmoi diff ~/Brewfile"
        echo "  2. Apply changes: chezmoi apply"
        echo "  3. Commit to git: chezmoi cd && git add . && git commit -m 'Update Brewfile'"
        ;;
    2)
        print_step "Showing diff..."
        # Show diff of the applied Brewfile instead of the template
        chezmoi diff ~/Brewfile
        echo
        print_step "To edit the template file manually:"
        echo "  1. Use: chezmoi edit ~/Brewfile"
        echo "  2. Or edit directly: $BREWFILE_TEMPLATE"
        echo "  3. Then run: chezmoi apply"
        ;;
    3)
        print_warning "Cancelled"
        exit 0
        ;;
    *)
        print_error "Invalid option"
        exit 1
        ;;
esac 