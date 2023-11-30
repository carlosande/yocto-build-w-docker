SUMMARY = "Recipe to copy overlays directory to bootfiles directory in the image deploy directory that contains overlays and trimmed version of config.txt"

#### S = "~/Documents/poky/rpi4-64/tmp/work/raspberrypi4_64-poky-linux/rpi-bootfiles/20230509~buster/raspberrypi-firmware-1.20230509~buster/boot"

do_after_deploy() {
#    install -d ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}
#
#    for i in ${S}/*.elf ; do
#        cp $i ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}
#    done
#    for i in ${S}/*.dat ; do
#        cp $i ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}
#    done
#    for i in ${S}/*.bin ; do
#        cp $i ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}
#    done
#       
#    cp -r ${S}/overlays ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/overlays

    # Make a simple config.txt
#    touch ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt
#    echo 'kernel=kernel_rpilinux.img' >> ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt
#    echo 'arm_64bit=1' >> ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt
#    echo 'enable_uart=1' >> ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt

    # Make a simple cmdline.txt
#    touch ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/cmdline.txt
#    echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=ttyS0 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait' >> ${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/cmdline.txt
#############################################################    
    install -d ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}

    for i in ${S}/*.elf ; do
        cp $i ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    done
    for i in ${S}/*.dat ; do
        cp $i ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    done
    for i in ${S}/*.bin ; do
        cp $i ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}
    done

    # Add stamp in deploy directory
    touch ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/${PN}-${PV}.stamp

    cp -r ${S}/overlays ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/overlays

    # Make a simple config.txt
    touch ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo 'kernel=kernel_rpilinux.img' >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo 'arm_64bit=1' >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt
    echo 'enable_uart=1' >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/config.txt

    # Make a simple cmdline.txt
    touch ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/cmdline.txt
    echo 'dwc_otg.lpm_enable=0 console=serial0,115200 console=ttyS0 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait' >> ${DEPLOYDIR}/${BOOTFILES_DIR_NAME}/cmdline.txt          
}

addtask after_deploy before do_build after do_install do_deploy
