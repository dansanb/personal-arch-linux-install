# My Personal Arch Linux Install
*Warning - This is a highly personalized arch install script for my personal workstation. I try to comment every step so that it can be helpful to others.
## Usage:
1. Boot Arch Install from USB (ensure UEFI)
2. Install Git
```
    pacman -Sy
    reflector 
    pacman -S git
```
3. Clone this repository
```
    git clone https://github.com/dansanb/personal-arch-linux-install.git /tmp/arch-install
    cd /tmp/arch-install
```
4. Set install options documented at the top of the script:
```
    vim install.sh
```
5. Install Arch
```
    chmod +x install.sh
    ./install.sh

## After Install
After the script is finished, 2 things remain:
1. edit /etc/fstab to mount additional drives / network points
2. Install dotfiles

## Enjoy! (Hopefully)
