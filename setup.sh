#!/bin/bash

# Unofficial Bash strict mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Failed to setup XFCE on Termux."
    echo "Please refer to the error message(s) above"
  fi
}

trap finish EXIT

print_header() {
  clear
  echo
  echo "▄▄▄▄▄▄▄                                           ▄    ▄ ▄▄▄▄▄▄   ▄▄▄  ▄▄▄▄▄▄"
  echo "   █     ▄▄▄    ▄ ▄▄  ▄▄▄▄▄  ▄   ▄  ▄   ▄          █  █  █      ▄▀   ▀ █     "
  echo "   █    █▀  █   █▀  ▀ █ █ █  █   █   █▄█            ██   █▄▄▄▄▄ █      █▄▄▄▄▄"
  echo "   █    █▀▀▀▀   █     █ █ █  █   █   ▄█▄           ▄▀▀▄  █      █      █     "
  echo "   █    ▀█▄▄▀   █     █ █ █  ▀▄▄▀█  ▄▀ ▀▄         ▄▀  ▀▄ █       ▀▄▄▄▀ █▄▄▄▄▄"
  echo "                                                                             "
  echo
}

# Enable access to storage and ensure script is executed from home directory
cd "$HOME"
# Required to do early on to install `read`` and update the repo mirror list
pkg upgrade -y || true

base_url="https://raw.githubusercontent.com/rafiazman/Termux_XFCE/develop"
timezone=$(getprop persist.sys.timezone)

print_header
echo "This install script will set up Termux with an XFCE4 Desktop and a Debian"
echo "proot-distro install."
echo
echo "⚠️ Press Enter to reselect the fastest Termux repository mirror. It is recommended"
read -r -p "to choose one that is close to your geographical location. " </dev/tty
termux-change-repo

print_header
echo "✅ Termux repository mirror set."
echo
read -r -p "⚠️ Please enter username for installation: 👤 " username </dev/tty
echo

echo "⏳ Enabling X11 repositories..."
echo
pkg install x11-repo pulseaudio -y
echo
echo "✅ Enabled X11 repositories."
echo

echo "⏳ Installing proot Debian..."

echo
pkg install proot-distro -y
echo
proot-distro install debian || true
proot-distro login debian --user root --shared-tmp

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install sudo -y

ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime

groupadd storage
groupadd wheel
groupadd video || true
useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"

# Add user to sudoers
chmod u+w /etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
chmod u-w /etc/sudoers

echo "export DISPLAY=:0" >>"/home/$username/.bashrc"
echo
echo "⏳ Installing XFCE..."
apt-get install xfce4 xfce4-goodies papirus-icon-theme pavucontrol-qt -y

curl --create-dirs -sLO "$base_url/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" --output-dir "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
curl --create-dirs -sLO "$base_url/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" --output-dir "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
curl --create-dirs -sLO "$base_url/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" --output-dir "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
curl --create-dirs -sLO "$base_url/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml" --output-dir "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"

curl --create-dirs -sLO "$base_url/.config/Mousepad/accels.scm" --output-dir "$HOME/.config/Mousepad/"
echo "✅ Installed XFCE."
echo

echo "⏳ Installing XFCE theme..."
fluent_icon_version=$(curl -sqI https://github.com/vinceliuice/Fluent-icon-theme/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}')
curl -sL "https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/$fluent_icon_version.tar.gz" -o fluent_icon_theme.tar.gz
tar -xf fluent_icon_theme.tar.gz
rm fluent_icon_theme.tar.gz
mv Fluent-icon-theme-* Fluent-icon-theme
mv Fluent-icon-theme/cursors/dist /usr/share/icons/
mv Fluent-icon-theme/cursors/dist-dark /usr/share/icons/

curl -sLO "https://github.com/vinceliuice/WhiteSur-gtk-theme/raw/master/release/WhiteSur-Dark-44-0.tar.xz"
tar -xf WhiteSur-Dark-44-0.tar.xz
rm WhiteSur-Dark-44-0.tar.xz
mv WhiteSur-Dark/ /usr/share/themes/

curl -sLO "https://besthqwallpapers.com/Uploads/22-9-2017/21311/gray-lines-geometry-strips-dark-material-art.jpg"
mv gray-lines-geometry-strips-dark-material-art.jpg /usr/share/backgrounds/xfce/
echo "✅ Installed XFCE theme."

echo "⏳ Installing Brave..."
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
apt update
apt install brave-browser -y
echo "✅ Installed Brave."

echo
logout
echo "✅ Installed proot Debian."

echo "⏳ Installing Termux-X11..."
sed -i '12s/^#//' .termux/termux.properties

apt-get install xkeyboard-config -y
curl -sL https://nightly.link/termux/termux-x11/workflows/debug_build/master/termux-companion%20packages.zip -o termux_companion_packages.zip
unzip termux_companion_packages.zip "termux-x11-nightly*.deb"
mv termux-x11-nightly*.deb termux-x11-nightly.deb
dpkg -i termux-x11-nightly.deb
rm termux_companion_packages.zip termux-x11-nightly.deb

curl -sL https://nightly.link/termux/termux-x11/workflows/debug_build/master/termux-x11-universal-debug.zip -o termux-x11.zip
unzip termux-x11.zip
termux-open app-universal-debug.apk
rm termux-x11.zip app-universal-debug.apk
echo "✅ Installed Termux-X11."
echo

curl --create-dirs -sL "$base_url/scripts/start" -o "$HOME/.local/bin/start"
chmod +x "$HOME/.local/bin/start"
{
  echo "pulseaudio --start --exit-idle-time=-1"
  echo "pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
  echo
  echo "export PATH=\"\$HOME/.local/bin\":\$PATH"
} >> "$HOME/.bashrc"
# shellcheck source=/dev/null
. "$HOME/.bashrc"
echo "✅ Installed start script."

print_header
echo
echo "✅ Completed installation of Termux XFCE!"
echo "Restart Termux to have the 'start' script available which starts XFCE4."
echo
