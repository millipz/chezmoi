# 🏠 millipz's dotfiles

Managed with [chezmoi](https://www.chezmoi.io/) for easy setup across multiple machines.

## 🚀 Quick Install

Run this single command to bootstrap a new macOS machine:

```bash
curl -fsSL https://raw.githubusercontent.com/millipz/chezmoi/main/bootstrap.sh | bash
```

This will:
- ✅ Install Xcode Command Line Tools
- ✅ Install Homebrew
- ✅ Install chezmoi
- ✅ Set up GitHub authentication
- ✅ Clone and apply these dotfiles
- ✅ Install all Homebrew packages from Brewfile
- ✅ Configure macOS system settings

## 🎯 What's Included

- **Shell Configuration**: Zsh with custom aliases and functions
- **Development Tools**: Git config, VS Code settings
- **macOS Settings**: Sensible defaults for Dock, Finder, keyboard, and more
- **Homebrew Bundle**: Automated installation of apps and tools
- **Environment-specific configs**: Different settings for work/home machines

## 💻 Environments

During installation, you'll be prompted to choose between:
- **Home**: Personal machine configuration
- **Work**: Work machine configuration with company-specific settings

To skip the prompt, set the `MACHINE` environment variable:

```bash
# For work setup
MACHINE=work curl -fsSL https://raw.githubusercontent.com/millipz/chezmoi/main/bootstrap.sh | bash

# For home setup
MACHINE=home curl -fsSL https://raw.githubusercontent.com/millipz/chezmoi/main/bootstrap.sh | bash
```

## 🔧 Manual Setup (Alternative)

If you prefer to run the steps manually:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install chezmoi
brew install chezmoi

# Initialize chezmoi with this repo
chezmoi init --apply https://github.com/millipz/chezmoi.git
```

## 📝 Daily Usage

### Update dotfiles from the repo
```bash
chezmoi update
```

### Edit a tracked file
```bash
chezmoi edit ~/.zshrc
chezmoi apply
```

### Add a new file to track
```bash
chezmoi add ~/.config/some-app/config.json
chezmoi cd
git add .
git commit -m "Add some-app config"
git push
```

### See what changes would be applied
```bash
chezmoi diff
```

### Edit chezmoi configuration
```bash
chezmoi edit-config
```

## 🗂️ Structure

```
.
├── bootstrap.sh                    # macOS setup script
├── run_once_macos_settings.sh     # macOS system preferences
├── dot_gitconfig.tmpl             # Git configuration (templated)
├── dot_zshrc                      # Zsh configuration
├── Brewfile                       # Homebrew packages
└── private_dot_config/            # Application configs
    └── ...
```

## 🔒 Secrets Management

Sensitive data is managed using chezmoi's built-in features:
- Templates for environment-specific values
- Encrypted files for secrets (if needed)
- Integration with 1Password CLI (optional)

## 🛠️ Troubleshooting

### Multiple config files error
```bash
rm -f ~/.config/chezmoi/chezmoi.yaml ~/.config/chezmoi/chezmoi.toml
```

### Start fresh
```bash
chezmoi purge
rm -rf ~/.local/share/chezmoi
# Then run the install command again
```

### Update Homebrew packages
```bash
brew bundle --file="$HOME/Brewfile"
```

## 📦 Key Software Installed

The Brewfile includes:
- **Development**: Git, VS Code, Docker, Node.js
- **Productivity**: Rectangle, Alfred, 1Password
- **Utilities**: ripgrep, fzf, bat, eza
- **Communication**: Slack, Discord
- And more...

## 🤝 Contributing

Feel free to explore, fork, and adapt these dotfiles for your own use! If you find something useful or have suggestions, I'd love to hear about it.

## 📄 License

MIT - Use these dotfiles however you'd like!

---

**Note**: These dotfiles are optimized for macOS. Linux support may require modifications.
