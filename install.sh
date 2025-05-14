#!/bin/bash

set -e

# === CONFIG ===
DOTFILES_DIR="$HOME/dotfiles" # Change this if your dotfiles are elsewhere
FILES_TO_LINK=(".zshrc" ".p10k.zsh") # Add more files if needed

echo "🔗 Symlinking dotfiles from $DOTFILES_DIR..."

for file in "${FILES_TO_LINK[@]}"; do
    src="$DOTFILES_DIR/$file"
    dest="$HOME/$file"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "⚠️  Backing up existing $file to $file.backup"
        mv "$dest" "$dest.backup"
    fi

    ln -s "$src" "$dest"
    echo "✅ Linked $file"
done

# === INSTALL ZSH & DEPENDENCIES ===
echo "🔧 Installing Zsh and fonts..."
sudo apt update
sudo apt install -y zsh curl git wget unzip fonts-powerline

echo "✅ Setting Zsh as default shell..."
chsh -s $(which zsh)

# === OH-MY-ZSH ===
echo "🎩 Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# === POWERLEVEL10K ===
echo "🌈 Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

# === PLUGINS ===
echo "🔌 Installing Zsh plugins..."

git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
git clone https://github.com/rupa/z.git "$ZSH_CUSTOM/plugins/z"

# Modify plugin line only if not symlinked from dotfiles
if ! [[ -L "$HOME/.zshrc" ]]; then
    sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab z)/' ~/.zshrc
fi

# === FONT INSTALLATION ===
echo "🔤 Installing Meslo Nerd Font..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip
unzip -o Meslo.zip
rm Meslo.zip
fc-cache -fv

# === POST-INSTALL SETUP ===
echo "📦 Finalizing setup..."

if ! [[ -L "$HOME/.zshrc" ]]; then
cat << 'EOF' >> ~/.zshrc

# Syntax Highlighting
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Z plugin
source ~/.oh-my-zsh/custom/plugins/z/z.sh
EOF
fi

echo "✅ Zsh environment configured!"
echo "👉 Remember to set VS Code terminal font to 'MesloLGS NF'"
echo "💡 Restart terminal or run 'zsh' now to enter Zsh."

