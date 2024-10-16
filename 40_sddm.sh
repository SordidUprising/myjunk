#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Script to apply post install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                      |-/ /--|#
#|/ /---+--------------------------------------+/ /---|#

scrDir="."
source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

# sddm
sudo pacman -Sy --noconfirm sddm qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects


echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m detected // sddm"
if [ ! -d /etc/sddm.conf.d ]; then
    sudo mkdir -p /etc/sddm.conf.d
fi

if [ ! -f /etc/sddm.conf.d/kde_settings.t2.bkp ]; then
    echo -e "\033[0;32m[DISPLAYMANAGER]\033[0m configuring sddm..."
    echo -e "Select sddm theme:\n[1] Candy\n[2] Corners"
    read -p " :: Enter option number : " sddmopt

    case $sddmopt in
    1) sddmtheme="Candy" ;;
    *) sddmtheme="Corners" ;;
    esac

    sudo tar -xzf ./Sddm_${sddmtheme}.tar.gz -C /usr/share/sddm/themes/
    sudo touch /etc/sddm.conf.d/kde_settings.conf
    sudo cp /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.t2.bkp
    sudo cp /usr/share/sddm/themes/${sddmtheme}/kde_settings.conf /etc/sddm.conf.d/
else
    echo -e "\033[0;33m[SKIP]\033[0m sddm is already configured..."
fi

sudo systemctl enable --now sddm

# flatpak
if [ "a" = "b" ]; then

    echo -e "\033[0;32m[FLATPAK]\033[0m flatpak application list..."
    awk -F '#' '$1 != "" {print "["++count"]", $1}' "${scrDir}/.extra/custom_flat.lst"
    prompt_timer 60 "Install these flatpaks? [Y/n]"
    fpkopt=${promptIn,,}

    if [ "${fpkopt}" = "y" ]; then
        echo -e "\033[0;32m[FLATPAK]\033[0m installing flatpaks..."
        "${scrDir}/.extra/install_fpk.sh"
    else
        echo -e "\033[0;33m[SKIP]\033[0m installing flatpaks..."
    fi

else
    echo -e "\033[0;33m[SKIP]\033[0m flatpak is already installed..."
fi
