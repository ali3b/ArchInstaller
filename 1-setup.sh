#!/usr/bin/env bash
#-------------------------------------------------------------------------
#░█████╗░██████╗░░█████╗░██╗░░██╗
#██╔══██╗██╔══██╗██╔══██╗██║░░██║
#███████║██████╔╝██║░░╚═╝███████║
#██╔══██║██╔══██╗██║░░██╗██╔══██║
#██║░░██║██║░░██║╚█████╔╝██║░░██║
#╚═╝░░╚═╝╚═╝░░╚═╝░╚════╝░╚═╝░░╚═╝
#
#██╗███╗░░██╗░██████╗████████╗░█████╗░██╗░░░░░██╗░░░░░███████╗██████╗░
#██║████╗░██║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░██╔════╝██╔══██╗
#██║██╔██╗██║╚█████╗░░░░██║░░░███████║██║░░░░░██║░░░░░█████╗░░██████╔╝
#██║██║╚████║░╚═══██╗░░░██║░░░██╔══██║██║░░░░░██║░░░░░██╔══╝░░██╔══██╗
#██║██║░╚███║██████╔╝░░░██║░░░██║░░██║███████╗███████╗███████╗██║░░██║
#╚═╝╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝╚══════╝╚═╝░░╚═╝
#-------------------------------------------------------------------------
echo "--------------------------------------"
echo "--          Network Setup           --"
echo "--------------------------------------"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
echo "-------------------------------------------------"
echo "Setting up mirrors for optimal download          "
echo "-------------------------------------------------"
pacman -S --noconfirm pacman-contrib curl
pacman -S --noconfirm reflector rsync
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTALMEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
echo "Changing the compression settings for "$nc" cores."
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi
echo "-------------------------------------------------"
echo "       Setup Language to US and set locale       "
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone America/Chicago
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"

# Set keymaps
localectl --no-ask-password set-keymap us

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#Para/Para/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

echo -e "\nInstalling Base System\n"

PKGS=(
	#SYSTEM
	'base'
	'linux'
	'linux-firmware'
	'linux-headers'

	#XORG
	'xorg-server'           # XOrg server
	'xorg-apps'             # XOrg apps group
	'xorg-xinit'            # XOrg init
	'xf86-video-intel'      # 2D/3D video driver
	'mesa'                  # Open source version of OpenGL
	
	#XFCE
	'xfce4'                 # XFCE Desktop
	'xfce4-goodies'         # All the extras
	
	#NETWORK
	'wpa_supplicant'            # Key negotiation for WPA wireless networks
	'dialog'                    # Enables shell scripts to trigger dialog boxex
	'networkmanager'            # Network connection manager
	'openvpn'                   # Open VPN support
	'networkmanager-openvpn'    # Open VPN plugin for NM
	'networkmanager-vpnc'       # Open VPN plugin for NM. Probably not needed if networkmanager-openvpn is installed.
	'network-manager-applet'    # System tray icon/utility for network connectivity
	'dhclient'                  # DHCP client
	'libsecret'                 # Library for storing passwords

	#AUDIO
	'alsa-utils'        # Advanced Linux Sound Architecture (ALSA) Components https://alsa.opensrc.org/
	'alsa-plugins'      # ALSA plugins
	'pulseaudio'        # Pulse Audio sound components
	'pulseaudio-alsa'   # ALSA configuration for pulse audio
	'pavucontrol'       # Pulse Audio volume control
	'volumeicon'        # System tray volume control

    # TERMINAL UTILITIES --------------------------------------------------

    'bash-completion'       # Tab completion for Bash
    #'bc'                    # Precision calculator language
    #'bleachbit'             # File deletion utility
    'curl'                  # Remote content retrieval
    #'elinks'                # Terminal based web browser
    #'feh'                   # Terminal-based image viewer/manipulator
    #'file-roller'           # Archive utility
    'gnome-keyring'         # System password storage
    'gtop'                  # System monitoring via terminal
    'gufw'                  # Firewall manager
    'hardinfo'              # Hardware info app
    'htop'                  # Process viewer
    'inxi'                  # System information utility
    'jq'                    # JSON parsing library
    'jshon'                 # JSON parsing library
    'neofetch'              # Shows system info when you launch terminal
    'ntp'                   # Network Time Protocol to set time via network.
    'numlockx'              # Turns on numlock in X11
    'openssh'               # SSH connectivity tools
    'rsync'                 # Remote file sync utility
    'speedtest-cli'         # Internet speed via terminal
    'terminus-font'         # Font package with some bigger fonts for login terminal
    'tlp'                   # Advanced laptop power management
    'unrar'                 # RAR compression program
    'unzip'                 # Zip compression program
    'wget'                  # Remote content retrieval
    'xfce4-terminal'        # Terminal emulator
    'zenity'                # Display graphical dialog boxes via shell scripts
    'zip'                   # Zip compression program
    'zsh'					# ZSH shell
	'zsh-syntax-highlighting'
	'zsh-autosuggestions'                   
    'zsh-completions'       # Tab completion for ZSH

    # DISK UTILITIES ------------------------------------------------------

    'autofs'                # Auto-mounter
    'exfat-utils'           # Mount exFat drives
    'gparted'               # Disk utility
    'gnome-disks'           # Disk utility
    'ntfs-3g'               # Open source implementation of NTFS file system
    'parted'                # Disk utility

    # GENERAL UTILITIES ---------------------------------------------------

    #'catfish'               # Filesystem search
    #'conky'                 # System information viewer
    #'nemo'                  # Filesystem browser
    #'veracrypt'             # Disc encryption utility
    #'variety'               # Wallpaper changer
    #'xfburn'                # CD burning application

    # DEVELOPMENT ---------------------------------------------------------

    #'atom'                  # Text editor
    #'apache'                # Apache web server
    'clang'                 # C Lang compiler
    'cmake'                 # Cross-platform open-source make system
    #'electron'              # Cross-platform development using Javascript
    'git'                   # Version control system
    'gcc'                   # C/C++ compiler
    'glibc'                 # C libraries
    #'mariadb'               # Drop-in replacement for MySQL
    #'meld'                  # File/directory comparison
    'nodejs'                # Javascript runtime environment
    'npm'                   # Node package manager
    #'php'                   # Web application scripting language
    #'php-apache'            # Apache PHP driver
    #'postfix'               # SMTP mail server
    'python'                # Scripting language
    #'qtcreator'             # C++ cross platform IDE
    #'qt5-examples'          # Project demos for Qt
    #'yarn'                  # Dependency management (Hyper needs this)

    # WEB TOOLS -----------------------------------------------------------

    'chromium'              # Web browser
    'firefox'               # Web browser
    #'filezilla'             # FTP Client
    #'flashplugin'           # Flash

    # COMMUNICATIONS ------------------------------------------------------

    #'hexchat'               # Multi format chat
    #'irssi'                 # Terminal based IIRC

    # MEDIA ---------------------------------------------------------------

    #'lollypop'              # Music player
    #'simplescreenrecorder'  # Record your screen
    #'vlc'                   # Video player
    #'xfce4-screenshooter'   # Screen capture.

    # GRAPHICS AND DESIGN -------------------------------------------------

    #'gcolor2'               # Colorpicker
    #'gimp'                  # GNU Image Manipulation Program
    #'inkscape'              # Vector image creation app
    #'imagemagick'           # Command line image manipulation tool
    #'nomacs'                # Image viewer
    #'pngcrush'              # Tools for optimizing PNG images
    #'ristretto'             # Multi image viewer

    # PRODUCTIVITY --------------------------------------------------------

    'galculator'            # Gnome calculator
    'hunspell'              # Spellcheck libraries
    'hunspell-en'           # English spellcheck library
    #'libreoffice-fresh'     # Libre office with extra features
    'mousepad'              # XFCE simple text editor
    'xpdf'                  # PDF viewer

    # VIRTUALIZATION ------------------------------------------------------

    #'virtualbox'
    #'virtualbox-host-modules-arch'
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

#
# determine processor type and install microcode
# 
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
case "$proc_type" in
	GenuineIntel)
		print "Installing Intel microcode"
		pacman -S --noconfirm intel-ucode
		proc_ucode=intel-ucode.img
		;;
	AuthenticAMD)
		print "Installing AMD microcode"
		pacman -S --noconfirm amd-ucode
		proc_ucode=amd-ucode.img
		;;
esac	

# Graphics Drivers find and install
if lspci | grep -E "NVIDIA|GeForce"; then
    pacman -S nvidia --noconfirm --needed
	nvidia-xconfig
elif lspci | grep -E "Radeon"; then
    pacman -S xf86-video-amdgpu --noconfirm --needed
elif lspci | grep -E "Integrated Graphics Controller"; then
    pacman -S libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils --needed --noconfirm
fi

echo -e "\nDone!\n"
if ! source install.conf; then
	read -p "Please enter username:" username
echo "username=$username" >> ${HOME}/ArchTitus/install.conf
fi
if [ $(whoami) = "root"  ];
then
    useradd -m -G wheel,libvirt -s /bin/bash $username 
	passwd $username
	cp -R /root/ArchTitus /home/$username/
    chown -R $username: /home/$username/ArchTitus
	read -p "Please name your machine:" nameofmachine
	echo $nameofmachine > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi
