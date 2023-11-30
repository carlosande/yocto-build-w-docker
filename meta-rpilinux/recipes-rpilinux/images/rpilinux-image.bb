require recipes-core/images/core-image-minimal-dev.bb 

IMAGE_INSTALL += " libstdc++ mtd-utils " 
IMAGE_INSTALL += " openssh openssl openssh-sftp-server "
IMAGE_INSTALL += " sudo python3 python3-pip rpi-gpio raspi-gpio "
IMAGE_INSTALL += " bluez5 pi-bluetooth rsync "
 
IMAGE_FEATURES:append = " ssh-server-openssh "
 
IMAGE_FSTYPES = " tar.bz2 wic "
 
LICENSE_FLAGS_ACCEPTED = " commercial synaptics-killswitch "

# Adds Bluetooth support (manually starts with sudo systemctl start bluetooth.service)
INIT_MANAGER = "systemd"
CORE_IMAGE_EXTRA_INSTALL = " rsync "
COMBINED_FEATURES = " bluetooth wifi "

ENABLE_UART = "1"

INHERIT+="toaster buildhistory"

