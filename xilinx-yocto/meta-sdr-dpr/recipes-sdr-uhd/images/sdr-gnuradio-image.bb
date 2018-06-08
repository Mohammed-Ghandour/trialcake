SUMMARY = "A small image contains UHD driver and Python"

IMAGE_INSTALL = "packagegroup-core-boot ${ROOTFS_PKGMANAGE_BOOTSTRAP} ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_LINGUAS = " "

LICENSE = "MIT"

inherit core-image

# IMAGE_ROOTFS_SIZE ?= "8192"
IMAGE_ROOTFS_EXTRA_SPACE_append = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", " + 4096", "" ,d)}"

# Add 30 Mega bytes extra space to the root file-system
# IMAGE_ROOTFS_EXTRA_SPACE_append += "+ 30720"

IMAGE_INSTALL += "  nano \
					vim \
					rsync \
					python \
					python-cheetah \
    				python-modules \
    				python-argparse \
    				python-distutils \
    				python-numpy \
    		    	python-pip \
    				python-mako \
    				python-pyyaml \
    				python-six \
    				python-twisted \
    			    python-cython \
    				boost \
    				fftwf \
    				libudev \
    				uhd \
    				uhd-examples \
    				gsl \
    				alsa-lib \
    				cppunit  \
    				volk \
    				gnuradio \
    				gr-osmosdr \
    				gr-baz \
    				gr-burst \
    				gr-eventstream \
    				gr-framers \
    				gr-mac \
    				gr-mapper \
    				gr-message-tools \
    				rtl-sdr \
    				libbladerf \
    				libbladerf-bin \
    				nfs-utils-client \
    				openssh-sftp \
    				openssh-sftp-server \
    				sshfs-fuse \
    				ssh \
    				gcc \
    			 "
