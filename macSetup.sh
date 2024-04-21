set -e

if test ! $(which git); then
  echo "Installing xcode-stuff"
  xcode-select --install
fi

# Check for Homebrew,
# Install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/cshort/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Update homebrew recipes
echo "Updating homebrew..."
brew update

echo "Installing Git..."
brew install git

echo "Git config"

git config --global user.name "Chris Short"
git config --global user.email shortwchris@gmail.com

brew_pkgs=(
  colima
  docker 
  docker-compose
  docker-credential-helper
  docker-Buildx
  gcc
  git
  fd
  fzf
  lazygit
  make
  neovim
  nvm
  pnpm
  ripgrep
  starship
  stow
  unzip
  vscode-langservers-extracted
  yazi
  zellij
  zsh-autosuggestions
  zsh-syntax-highlighting
)

echo "Install brew packages"
brew install ${brew_pkgs[@]}

echo "Cleaning up brew"
brew cleanup

#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $HOME/.zshrc
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc

echo "Copying dotfiles from Github"
cd ~
git clone git@github.com:shortc/dotfiles.git .dotfiles
cd .dotfiles
mv ~/.zshrc ~/.zshrc.bak
stow .

mkdir -p ~/.docker/cli-plugins

echo "Setting up docker compose"
sudo ln -sfn $(brew --prefix)/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose

echo "Setting up docker buildx"
sudo ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx

echo "Installing node lts"
nvm install --lts
nvm use --lts

echo "Installing cargo"
curl https://sh.rustup.rs -sSf | sh

echo "Cloning and building latest Helix"
mkdir -p ~/Code
cd ~/Code
git clone https://github.com/helix-editor/helix
cd helix
cargo install --path helix-term --locked
ln -s $PWD/runtime ~/.config/helix/runtime
hx --grammar fetch
hx --grammar build

echo "Installing homebrew cask"
brew install caskroom/cask/brew-cask

# Apps
apps=(
  alfred
  aldente
  alacritty
  appcleaner
  arc
  balenaetcher
  betterdisplay
  cleanmymac
  cyberduck
  font-caskaydia-cove-nerd-font
  font-symbols-only-nerd-font
  google-chrome
  istat-menus
  iterm2
  kitty
  notion
  sensiblesidebuttons
  suspicious-package
  tailscale
  the-unarchiver
  vial
  zoomus
  zed
)

# Install apps to /Applications
echo "Installing apps with Cask..."
brew install --cask ${apps[@]}
brew cleanup

personal_apps=(
  discord
  epic-games
  gog-galaxy
  obs
  steam
)

# Install personal apps. Comment this out if work computer
echo "Installing person apps with Cask..."
brew install --cask ${personal_apps[@]}
brew cleanup


echo "Setting some Mac settings..."

#"Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

killall Finder

echo "Done!"
