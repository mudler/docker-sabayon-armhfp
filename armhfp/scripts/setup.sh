#!/bin/bash

/usr/sbin/env-update
. /etc/profile

sd_enable() {
    local srv="${1}"
    local ext=".${2:-service}"
    [[ -x /usr/bin/systemctl ]] && \
        systemctl --no-reload enable -f "${srv}${ext}"
}

sd_disable() {
    local srv="${1}"
    local ext=".${2:-service}"
    [[ -x /usr/bin/systemctl ]] && \
        systemctl --no-reload disable -f "${srv}${ext}"
}

setup_displaymanager() {
    if [ -n "$(equo match --installed gnome-base/gdm -qv)" ]; then
        sd_enable gdm
    elif [ -n "$(equo match --installed lxde-base/lxdm -qv)" ]; then
        sd_enable lxdm
    elif [ -n "$(equo match --installed x11-misc/lightdm-base -qv)" ]; then
        sd_enable lightdm
    elif [ -n "$(equo match --installed kde-base/kdm -qv)" ]; then
        sd_enable kdm
    else
        sd_enable xdm
    fi
}

setup_desktop_environment() {
    local session=
    if [ -f "/usr/share/xsessions/LXDE.desktop" ]; then
        session="LXDE"
    elif [ -f "/usr/share/xsessions/xfce.desktop" ]; then
        session="xfce"
    elif [ -f "/usr/share/xsessions/gnome.desktop" ]; then
        session="gnome"
    elif [ -f "/usr/share/xsessions/mate.desktop" ]; then
        session="mate"
    elif [ -f "/usr/share/xsessions/KDE-4.desktop" ]; then
        session="KDE-4"
    fi

    if [ -n "${session}" ]; then
        echo "[Desktop]" > /etc/skel/.dmrc || return 1
        echo "Session=${session}" >> /etc/skel/.dmrc || return 1
    fi
}

setup_boot() {
    sd_enable sshd
    sd_enable ntpd
    sd_enable vixie-cron
    sd_enable NetworkManager
    #eselect uimage set 1
}

setup_users() {
    # setup root password to... root!
    echo root:root | chpasswd
    # setup normal user "sabayon"
    (
        if [ ! -x "/sbin/sabayon-functions.sh" ]; then
            echo "no /sbin/sabayon-functions.sh found"
            exit 1
        fi
        . /sbin/sabayon-functions.sh
        sabayon_setup_live_user "sabayon" || exit 1
        # setup "sabayon" password to... sabayon!
        echo "sabayon:sabayon" | chpasswd

      	# setup sudoers
      	[ -e /etc/sudoers ] && echo "sabayon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

        # also add "sabayon" to disk group
        usermod -a -G disk sabayon
        usermod -a -G tty sabayon
        usermod -a -G input sabayon
        usermod -a -G video sabayon
    ) || return 1
}

setup_boot
setup_users

exit 0
