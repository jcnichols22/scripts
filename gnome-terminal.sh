#!/bin/bash
set -e

echo "Updating package list..."
sudo apt update

# Install Zsh
echo "Installing Zsh..."
sudo apt install -y zsh

# Set Zsh as default shell for current user (assumes passwordless or that user can sudo chsh)
echo "Setting Zsh as the default shell for user $USER..."
sudo chsh -s "$(which zsh)" "$USER"

# Install Oh My Zsh (without running it interactively)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

# Define custom zsh directory
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install Zsh plugins
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install Powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Install FiraMono Nerd Font
FONT_DIR="$HOME/.local/share/fonts"
if ! fc-list | grep -qi "FiraMono Nerd Font"; then
  echo "Installing FiraMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  cd /tmp
  FIRA_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraMono.zip"
  wget -O FiraMono.zip "$FIRA_URL"
  unzip -o FiraMono.zip -d "$FONT_DIR"
  fc-cache -fv
  cd -
else
  echo "FiraMono Nerd Font already installed, skipping."
fi

# Update .zshrc to use Powerlevel10k theme and enable plugins
ZSHRC="$HOME/.zshrc"

# Set ZSH_THEME
if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC"
else
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC"
fi

# Set plugins
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$ZSHRC"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

# Add POWERLEVEL9K_MODE if absent
if ! grep -q '^POWERLEVEL9K_MODE=' "$ZSHRC"; then
  echo 'POWERLEVEL9K_MODE="nerdfont-complete"' >> "$ZSHRC"
fi

echo "Configured .zshrc with theme and plugins."

# Configure GNOME Terminal profile to use zsh and dark theme
echo "Configuring GNOME Terminal profile for Zsh and dark theme..."

PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"

# Set custom command to zsh
if [[ "$(gsettings get org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH custom-command)" != "'zsh'" ]]; then
  gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH custom-command 'zsh'
  gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH use-custom-command true
fi

# Set dark theme colors and Linux Console palette
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH visible-name 'Default (Zsh Dark)'
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH palette "['#000000', '#aa0000', '#00aa00', '#aa5500', '#0000aa', '#aa00aa', '#00aaaa', '#aaaaaa', '#555555', '#ff5555', '#55ff55', '#ffff55', '#5555ff', '#ff55ff', '#55ffff', '#ffffff']"
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH background-color '#171421'
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH foreground-color '#f8f8f2'

echo "GNOME Terminal profile configured."

echo "Terminal setup complete. Please restart your terminal or log out/in for changes to take effect."
