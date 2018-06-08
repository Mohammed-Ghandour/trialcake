#
# Add tx-2g.elf to the file-system 
#

SUMMARY = "Install elf file to an image"
SECTION = "examples"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://tx_2g.elf"

S = "${WORKDIR}"

do_install() {
	     install -d ${D}${bindir}
	     install -m 0777 tx_2g.elf ${D}${bindir}
}
