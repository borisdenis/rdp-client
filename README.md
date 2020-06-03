dhcp-identifier: mac



sudo add-apt-repository ppa:remmina-ppa-team/remmina-next
sudo add-apt-repository ppa:oibaf/graphics-drivers

Создаем файл /etc/apt/preferences.d.repo с содержимым:

Package: *
Pin: release o=LP-PPA-remmina-ppa-team-remmina-next,n=bionic
Pin-Priority: 1000

Установить ubuntu без графики

sudo systemctl edit getty@tty1
Вставить
    [Service]
    ExecStart=
    ExecStart=-/sbin/agetty -a tonk --noclear %I $TERM
        

Для 18.04

sudo apt install --install-recommends xserver-xorg-hwe-18.04 xserver-xorg-input-all-hwe-18.04 x11-xserver-utils xinit openbox numlockx pulseaudio alsa alsa-utils alsa-tools moc gawk x11-utils yad zenity xfonts-100dpi xfonts-75dpi xfonts-scalable xterm freerdp2-x11 linux-generic-hwe-18.04 fdutils 



sudo adduser ${USER} audio
sudo nano /etc/xdg/openbox/autostart
Вставить в конец этого файла

xset s off
xset s noblank
xset -dpms
setxkbmap -option srvrkeys:none
/usr/bin/numlockx on
# Allow quitting the X server with CTRL-ATL-Backspace
#setxkbmap -option terminate:ctrl_alt_bksp
# Start Remmina in kiosk mode
/opt/xfreerdp-gui.sh
#xterm

В папке пользователя создать файл .bash_profile и вставить в него
    [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx
        
в /etc/systemd/system/ скопировать файл usb-mount@.service
sudo systemctl daemon-reload

в /etc/udev/rules.d скопировать файл 99-local.rules
sudo udevadm control --reload-rules

в /opt скопировать usb-mount.sh и xfreerdp-gui.sh
usb-mount.sh и xfreerdp-gui.sh сделать запускаемыми
