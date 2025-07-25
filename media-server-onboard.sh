#!/bin/bash
set -e

# Install prerequisites
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release wget snapd git

# Ensure snapd is enabled and up to date
sudo systemctl enable --now snapd



# ---------------------------
# Install snap Applications
# ---------------------------
sudo snap install brave
sudo snap install obsidian --classic

# ---------------------------
# Install apt Applications
# ---------------------------

sudo apt install -y 1password
sudo apt install -y code
sudo apt install -y git curl

# ---------------------------
# Configure git with user details
# ---------------------------
echo "Configuring git with user details..."
git config --global user.email "jcnichols22@gmail.com"
git config --global user.name "Josh Nichols"


# ---------------------------
# Clone dotfiles repo and symlink .bash_aliases
# ---------------------------
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone https://github.com/jcnichols22/dotfiles.git "$DOTFILES_DIR"
else
  echo "Dotfiles repository already cloned, pulling latest changes..."
  git -C "$DOTFILES_DIR" pull
fi

# Create symlink for .bash_aliases in home directory
if [ -L "$HOME/.bash_aliases" ] && [ "$(readlink "$HOME/.bash_aliases")" = "$DOTFILES_DIR/.bash_aliases" ]; then
  echo "Symlink for .bash_aliases already exists and is correct, skipping."
elif [ -e "$HOME/.bash_aliases" ] || [ -L "$HOME/.bash_aliases" ]; then
  echo "Backing up existing .bash_aliases to .bash_aliases.backup"
  mv "$HOME/.bash_aliases" "$HOME/.bash_aliases.backup"
  ln -s "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  echo "Symlink created for .bash_aliases"
else
  ln -s "$DOTFILES_DIR/.bash_aliases" "$HOME/.bash_aliases"
  echo "Symlink created for .bash_aliases"
fi

# Source .bashrc to activate aliases immediately (optional)
echo "Sourcing ~/.bashrc to apply changes..."
source "$HOME/.bashrc"

# ---------------------------
# Pin apps to GNOME Dash
# ---------------------------
FAVORITES=$(gsettings get org.gnome.shell favorite-apps)

# Helper function to add an app if not already present
add_to_favorites() {
  local app="$1"
  if [[ $FAVORITES != *"$app"* ]]; then
    FAVORITES=$(echo "$FAVORITES" | sed "s/]$/, '$app']/")
  fi
}

# Pin apps to GNOME Dash only if not already present
FAVORITES=$(gsettings get org.gnome.shell favorite-apps)
add_to_favorites() {
  local app="$1"
  if [[ $FAVORITES != *"$app"* ]]; then
    FAVORITES=$(echo "$FAVORITES" | sed "s/]$/, '$app']/")
  fi
}
for app in "brave_brave.desktop" "1password.desktop" "obsidian_obsidian.desktop" "code.desktop"; do
  add_to_favorites "$app"
done
FAVORITES=$(echo "$FAVORITES" | sed "s/'',/','/g" | sed "s/ ,/,/g")
gsettings set org.gnome.shell favorite-apps "$FAVORITES"

# Set GNOME Dash favorites in a specific order (including Files and App Center)
FAVORITES="[
'brave_brave.desktop', 
'1password.desktop', 
'obsidian_obsidian.desktop', 
'code.desktop',
'org.gnome.Terminal.desktop',
'org.gnome.Nautilus.desktop', 
'io.snapcraft.Store.desktop' 
]"
gsettings set org.gnome.shell favorite-apps "$FAVORITES"

echo "Applications pinned to the GNOME Dash."

echo "All packages installed and dotfiles configured successfully."

# ---------------------------
# Remove Firefox if Brave is installed
# ---------------------------
if snap list | grep -q "^brave\s"; then
  echo "Brave is installed. Removing Firefox..."
  sudo apt remove -y firefox || true
  sudo snap remove firefox || true
else
  echo "Brave is not installed, skipping Firefox removal."
fi

# ---------------------------
# Install ZSH and set as default shell
# ---------------------------
echo "Installing Zsh..."
sudo apt install -y zsh

echo "Setting Zsh as the default shell for user $USER..."
sudo chsh -s "$(which zsh)" josh


# ---------------------------
# Install Oh My Zsh
# ---------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

# ---------------------------
# Install Zsh plugins
# ---------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ---------------------------
# Install Powerlevel10k theme
# ---------------------------
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ---------------------------
# Download and install FiraMono Nerd Font
# ---------------------------
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

# ---------------------------
# Update .zshrc for theme and plugins
# ---------------------------
ZSHRC="$HOME/.zshrc"

# Set ZSH_THEME to powerlevel10k
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

# Add POWERLEVEL9K_MODE if not present
if ! grep -q '^POWERLEVEL9K_MODE=' "$ZSHRC"; then
  echo 'POWERLEVEL9K_MODE="nerdfont-complete"' >> "$ZSHRC"
fi

echo "Zsh, Oh My Zsh, plugins, Powerlevel10k, and FiraMono Nerd Font installed and configured."
echo "You may need to set FiraMono Nerd Font in your GNOME Terminal profile for best appearance."

# ---------------------------
# Ensure GNOME Terminal uses Zsh and GNOME dark theme with Linux Console palette
# ---------------------------
echo "Configuring GNOME Terminal profile for Zsh and dark theme..."

# Get the default profile UUID
PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d \')
PROFILE_PATH="/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"

# Set custom command to zsh
if [[ "$(gsettings get org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH custom-command)" != "'zsh'" ]]; then
  gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH custom-command 'zsh'
  gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH use-custom-command true
fi

# Set GNOME Terminal to use built-in dark scheme
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH use-theme-colors false
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH visible-name 'Default (Zsh Dark)'

# Set palette to Linux Console
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH palette "['#000000', '#aa0000', '#00aa00', '#aa5500', '#0000aa', '#aa00aa', '#00aaaa', '#aaaaaa', '#555555', '#ff5555', '#55ff55', '#ffff55', '#5555ff', '#ff55ff', '#55ffff', '#ffffff']"

# Set background and foreground colors for GNOME dark
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH background-color '#171421'
gsettings set org.gnome.Terminal.Legacy.Profile:$PROFILE_PATH foreground-color '#f8f8f2'

echo "GNOME Terminal profile configured for Zsh, dark style, and Linux Console palette."

# ---------------------------
# Install Tailscale (using official install script)
# ---------------------------
if command -v tailscale >/dev/null 2>&1; then
  echo "Tailscale is already installed, skipping installation."
else
  echo "Installing Tailscale using the official install script..."
  
  # Run the official Tailscale installation script from their site
  curl -fsSL https://tailscale.com/install.sh | sh
  
  echo "Tailscale installation complete."
fi

# Start Tailscale (authenticate) regardless of fresh install or already installed
echo "Starting Tailscale and logging in (if not already up)..."
sudo tailscale up || echo "Tailscale 'up' command failed or was already connected."

echo "Tailscale setup complete."

# Install Docker Engine and Docker Compose plugin

# Add Docker's official GPG key and repository (if not already added)
if ! sudo apt-key list | grep -q "Docker"; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
fi

sudo apt update

# Install Docker Engine, CLI, containerd, and Docker Compose plugin
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group if not already a member (requires re-login)
if ! groups "$USER" | grep -q docker; then
  sudo usermod -aG docker "$USER"
fi

# Clone media repository if not already cloned
if [ ! -d "$HOME/media" ]; then
  git clone https://github.com/jcnichols22/media "$HOME/media"
fi

echo "Docker, Docker Compose, and media repo setup completed."
echo "If added to the docker group, please log out and back in."



# ---------------------------
# Clean up
# ---------------------------
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean