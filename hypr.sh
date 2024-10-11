#!/bin/bash
#source /path/to/env
#source /path/to/functions

test=true

inst() { if [ $test = false ]; then "$@"; fi }
prevent_sudo_or_root(){
  case $(whoami) in
    root)echo -e "\e[31m[$0]: This script is NOT to be executed with sudo or as root. Aborting...\e[0m";exit 1;;
  esac
}


prevent_sudo_or_root
if [ ! -f ".stage1" ] ; then
    echo "Stage 1: Installing git and yay"
    inst sudo pacman -Syyu
    inst sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay-bin.git /tmp/buildyay
    cd /tmp/buildyay
    makepkg -o
    inst makepkg -se
    inst makepkg -i --noconfirm
    cd -
    rm -rf /tmp/buildyay
    touch .stage1
fi
if [ ! -f ".stage2" ] ; then
    echo "Stage 2: Installing nvidia"
    inst sudo pacman -Sy --needed --noconfirm nvidia-open nvidia-utils lib32-nvidia-utils egl-wayland
    inst sudo sed -i 's/MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
    echo "options nvidia_drm modeset=1 fbdev=1" | inst sudo tee /etc/modprobe.d/nvidia.conf
    inst sudo mkinitcpio -P
    inst sudo reboot now
    touch .stage2
fi
if [ ! -f ".stage3" ] ; then
    echo "Stage 3: Installing Hyperland"
    if [ -f ".git" ] ; then
        echo "yay"
        inst yay -S --noconfirm --asdeps gdb ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite xorg-xinput libxrender pixman wayland-protocols cairo pango seatd libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang hyprcursor hyprwayland-scanner xcb-util-errors hyprutils-git
        inst sudo pacman -Sy  --needed --noconfirm aquamarine
        git clone --recursive https://github.com/hyprwm/Hyprland /tmp/buildHyprland
        cd /tmp/buildHyprland
        inst make all
        inst sudo make install
        cd -
        rm -rf /tmp/buildHyprland
    else
        #pacman
        echo "pacman"
        inst sudo pacman -Sy --needed --noconfirm hyprland
    fi
    touch .stage3
fi
if [ ! -f ".stage4" ] ; then
    echo "Stage 4: Installing sddm"
    inst sudo pacman -Sy -needed --noconfirm sddm qt6-5compat qt6-svg
    wget -O test.zip https://gitlab.com/Matt.Jolly/sddm-eucalyptus-drop/-/archive/v2.0.0/sddm-eucalyptus-drop-v2.0.0.zip
    inst sudo sddmthemeinstaller --install test.zip
    rm test.zip
    echo "[Theme]" | inst sudo tee /etc/sddm.conf.d/sddm.conf
    echo "Current=eucalyptus-drop" | inst sudo tee -a /etc/sddm.conf.d/sddm.conf
    touch .stage4
fi
