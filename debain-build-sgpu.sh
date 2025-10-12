#!/bin/bash

sudo apt-get install git ninja-build build-essential xz-utils python3-pkgconfig libgio-2.0-dev libvdeslirp-dev libepoxy-dev meson acpica-tools wget libvirglrenderer1 python3-setuptools python3-pip libsdl2-dev rsync ;

export TESTIME="$(date +%Y-%m-%d-%H-%M-%S | sort)"
export BUILDIR="/home/$USER/qemu924-smoll-linux-build-$TESTIME" && 

mkdir $BUILDIR && cd $BUILDIR &&
cd ~/ &&
mkdir build-test && cd build-test &&
git clone https://github.com/JHRobotics/qemu-3dfx.git &&
cd qemu-3dfx &&
wget https://download.qemu.org/qemu-9.2.4.tar.xz &&
tar xf qemu-9.2.4.tar.xz &&
cd qemu-9.2.4 &&
rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/ &&
patch -p0 -i ../00-qemu92x-mesa-glide.patch &&
bash ../scripts/sign_commit 2>&1 | tee ~/sign-commit.txt &&
mkdir ../build && 
cd ../build &&
../qemu-9.2.4/configure  –iasl=/usr/bin/iasl  --disable-libdw --enable-tcg --disable-tcg-interpreter --enable-hv-balloon --disable-sparse --disable-guest-agent-msi --disable-plugins --disable-dmg   --enable-fdt=auto --disable-bzip2 --disable-qed --disable-parallels --enable-qcow1 --disable-vmdk --disable-keyring --disable-netmap --disable-slirp-smbd --disable-virtfs --disable-dbus-display --disable-af-xdp --disable-bpf --disable-libvduse  --disable-fuse --disable-fuse-lseek --disable-vhost-user-blk-server --disable-malloc-trim --disable-libkeyutils --disable-selinux --disable-libdaxctl --disable-libpmem --disable-usb-redir --disable-libusb --disable-u2f --disable-canokey --disable-smartcard --disable-snappy --disable-lzo --disable-auth-pam --disable-capstone --disable-nettle --disable-gcrypt  --disable-oss --disable-lzfse --disable-libssh --disable-glusterfs --disable-gnutls --disable-rbd --disable-sdl-image --disable-blkio --disable-rutabaga-gfx    --disable-libiscsi --disable-sndio --disable-spice --disable-spice-protocol --disable-jack --disable-curl --disable-vde --disable-alsa --disable-brlapi --disable-crypto-afalg --disable-pa --disable-pipewire --disable-xkbcommon --disable-cap-ng --disable-seccomp --disable-vmnet --disable-cocoa --disable-coreaudio --disable-attr --disable-libnfs --disable-gio --disable-linux-aio --disable-linux-io-uring  --disable-nvmm --disable-numa --disable-xen-pci-passthrough --disable-whpx --disable-hvf --disable-xen -Dvhost_crypto=disabled -Dvhost_vdpa=disabled -Dvduse_blk_export=disabled -Dvhost_vdpa=disabled -Dvhost_kernel=disabled -Dvhost_net=disabled -Dvfio_user_server=disabled -Dvhost_user=disabled  -Dtpm=disabled -Dmultiprocess=disabled   -Dcurses=disabled --enable-opengl --disable-pixman -Dmpath=disabled --disable-png --disable-qga-vss --disable-rdma --disable-replication --disable-gtk --disable-vnc --enable-slirp --target-list=x86_64-softmmu,i386-softmmu --enable-kvm --enable-sdl –audio-drv-list=sdl,pa --enable-relocatable --enable-strip --disable-debug-info --enable-membarrier  --disable-curses --enable-iconv --enable-lto --enable-tools --disable-guest-agent --prefix=$BUILDIR  --extra-cflags=" -mtune=generic -march=x86-64-v2 " 2>&1 | tee ~/Configure-latest.txt  && 
make -j 6 && make install -j 6 && 
mv ~/Configure-latest.txt  ${BUILDIR}/configure-latest.txt &&
mv ~/sign-commit.txt ${BUILDIR}/sign-commit.txt &&
cd ${BUILDIR}/share/qemu/ && cat edk2-i386-vars.fd edk2-x86_64-code.fd > OVMF.FD && cp OVMF.FD OVMF.BIN && cd -
