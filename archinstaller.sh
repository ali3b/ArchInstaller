#!/bin/bash

    bash 0-preinstall.sh
    arch-chroot /mnt /root/ArchInstaller/1-setup.sh
    source /mnt/root/ArchInstaller/install.conf
    arch-chroot /mnt /usr/bin/runuser -u $username -- /home/$username/ArchInstaller/2-user.sh
    arch-chroot /mnt /root/ArchInstaller/3-post-setup.sh