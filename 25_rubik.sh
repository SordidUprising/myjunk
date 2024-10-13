sudo pacman -Sy --noconfirm pacman-contrib
cd ttf-rubik-vf
updpkgsums
makepkg -si
cd -
