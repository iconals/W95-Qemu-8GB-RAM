These scripts can be run together from power shell 6/7, provided, paths tp msys2_shell.cmd are correct:

``` 
 g:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64 -c "~/qemu924-sgpu-build.sh" ; 
 g:/msys64/msys2_shell.cmd -defterm -here -no-start -mingw32 -c "~/qemu924-sgpu-build-wrappers.sh" ; 
 g:/msys64/msys2_shell.cmd -defterm -here -no-start -ucrt64 -c "~/qemu924-sgpu-build-iso.sh"
```

```
$ cat ./qemu924-sgpu-build.sh
#!/bin/bash

export DEPDIR=/home/$USER/qemu-sgpu-deps &&
export BUILDIR="/home/$USER/qemu-924-sgpu-3dfx" &&
export SRCDIR="sgpu-3dfx-build-924-current" &&

echo "preparing depndancies for qemu-3dfx and soft-gpu" ;
cd ~/  ;
mkdir $DEPDIR  &&
cd $DEPDIR &&

wget https://download.qemu.org/qemu-9.2.4.tar.xz &&
wget https://github.com/open-watcom/open-watcom-v2/releases/download/Last-CI-build/ow-snapshot.tar.xz &&
wget https://github.com/andrewwutw/build-djgpp/releases/download/v3.4/djgpp-mingw-gcc1220-standalone.zip &&
wget https://github.com/JHRobotics/softgpu/releases/download/v0.8.2025.53/softgpu-0.8.2025.53.zip &&
wget http://download.wsusoffline.net/mkisofs.exe  &&
wget raw.githubusercontent.com/iconals/W95-Qemu-8GB-RAM/refs/heads/main/iasl.patch &&
wget https://gist.githubusercontent.com/iconals/a17c1bf16e8af24937358e638817e8a2/raw/52face922fb477d877f9f5062061591c1dfdd495/mingw-copy-deps.sh &&

echo "qemu build starting, proceeding to build prep" ;
cd ~/ &&
mkdir ${BUILDIR} &&
mkdir ${SRCDIR} &&
cd ${SRCDIR} &&
git clone https://github.com/JHRobotics/qemu-3dfx.git &&
cd qemu-3dfx &&
tar xf $DEPDIR/qemu-9.2.4.tar.xz ;
cd qemu-9.2.4 &&
rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/ &&
patch -p0 -i  $DEPDIR/iasl.patch &&
patch -p0 -i ../00-qemu92x-mesa-glide.patch &&
bash ../scripts/sign_commit 2>&1 | tee ~/sign-commit.txt &&
mkdir ../build &&
cd ../build &&
#../qemu-9.2.4/configure –iasl=/home/$USER/qemu-sgpu-deps/iasl --enable-tcg --disable-tcg-interpreter --enable-hv-balloon --enable-fdt=auto --enable-qcow1 --disable-kvm --disable-hvf --enable-opengl --enable-slirp --target-list=x86_64-softmmu,i386-softmmu --enable-whpx --enable-sdl –audio-drv-list=sdl,pa --enable-relocatable --enable-strip --enable-membarrier --enable-iconv --enable-lto --enable-tools --prefix=$BUILDIR --extra-cflags="-Wno-deprecated-declarations -Wno-unused-function -D__USE_MINGW_ANSI_STDIO=1 -mtune=generic -march=x86-64-v2 " 2>&1 | tee ~/Configure-latest.txt  &&
../qemu-9.2.4/configure  –iasl=/home/$USER/qemu-sgpu-deps/iasl  --disable-libdw --enable-tcg --disable-tcg-interpreter --enable-hv-balloon --disable-sparse --disable-guest-agent-msi --disable-plugins --disable-dmg   --enable-fdt=auto --disable-bzip2 --disable-qed --disable-parallels --enable-qcow1 --disable-vmdk --disable-keyring --disable-netmap --disable-slirp-smbd --disable-virtfs --disable-dbus-display --disable-af-xdp --disable-bpf --disable-libvduse  --disable-fuse --disable-fuse-lseek --disable-vhost-user-blk-server --disable-malloc-trim --disable-libkeyutils --disable-selinux --disable-libdaxctl --disable-libpmem --disable-usb-redir --disable-libusb --disable-u2f --disable-canokey --disable-smartcard --disable-snappy --disable-lzo --disable-auth-pam --disable-capstone --disable-nettle --disable-gcrypt  --disable-oss --disable-lzfse --disable-libssh --disable-glusterfs --disable-gnutls --disable-rbd --disable-sdl-image --disable-blkio --disable-rutabaga-gfx    --disable-libiscsi --disable-sndio --disable-spice --disable-spice-protocol --disable-jack --disable-curl --disable-vde --disable-alsa --disable-brlapi --disable-crypto-afalg --disable-pa --disable-pipewire --disable-xkbcommon --disable-cap-ng --disable-seccomp --disable-vmnet --disable-cocoa --disable-coreaudio --disable-attr --disable-libnfs --disable-gio --disable-linux-aio --disable-linux-io-uring  --disable-nvmm --disable-numa --disable-xen-pci-passthrough --disable-kvm --disable-hvf --disable-xen -Dvhost_crypto=disabled -Dvhost_vdpa=disabled -Dvduse_blk_export=disabled -Dvhost_vdpa=disabled -Dvhost_kernel=disabled -Dvhost_net=disabled -Dvfio_user_server=disabled -Dvhost_user=disabled  -Dtpm=disabled -Dmultiprocess=disabled   -Dcurses=disabled --enable-opengl --disable-pixman -Dmpath=disabled --disable-png --disable-qga-vss --disable-rdma --disable-replication --disable-gtk --disable-vnc --enable-slirp --target-list=x86_64-softmmu,i386-softmmu --enable-whpx --enable-sdl –audio-drv-list=sdl,pa --enable-relocatable --enable-strip --disable-debug-info --enable-membarrier  --disable-curses --enable-iconv --enable-lto --enable-tools --disable-guest-agent --prefix=$BUILDIR  --extra-cflags="-Wno-deprecated-declarations -D__USE_MINGW_ANSI_STDIO=1  -mtune=generic -march=x86-64-v2 " 2>&1 | tee ~/Configure-latest.txt  &&
make -j$(( $(nproc) - 2 )) && make install -j$(( $(nproc) - 2 )) &&
cd ~/ &&
mv ~/Configure-latest.txt  ${BUILDIR}/configure-latest.txt &&
bash $DEPDIR/mingw-copy-deps.sh /ucrt64/bin/ ${BUILDIR}/qemu-system-x86_64.exe &&
mv ~/sign-commit.txt ${BUILDIR}/. &&
cd ${BUILDIR}/share/ && cat edk2-i386-vars.fd edk2-x86_64-code.fd > OVMF.FD && cp OVMF.FD OVMF.BIN && cd - ;
echo "qemu build complete" ;
cd ~/ ;
echo "done"
```

```
$ cat ./qemu924-sgpu-build-wrappers.sh
#!/bin/bash
# This script needs to be run from mingw32 shell

export DEPDIR=/home/$USER/qemu-sgpu-deps &&
export BUILDIR="/home/$USER/qemu-924-sgpu-3dfx" &&
export SRCDIR="sgpu-3dfx-build-924-current" &&

cd $DEPDIR &&
unzip ./djgpp-mingw-gcc1220-standalone.zip &&
tar xjf ./djgpp-linux64-gcc1220.tar.bz2 &&
mkdir -p owatcom &&
cd owatcom &&
tar xf ../ow-snapshot.tar.xz  &&
cd .. &&
export PATH="${PATH}:$DEPDIR/owatcom/binnt64" ;
export PATH="${PATH}:$DEPDIR/djgpp/bin" ;
export PATH="${PATH}:$DEPDIR/djgpp/i586-pc-msdosdjgpp/bin" ;
cd  /home/$USER/$SRCDIR/qemu-3dfx/ &&
cd wrappers/3dfx &&
mkdir build && cd build &&
bash ../../../scripts/conf_wrapper &&
make && make clean &&
cd  /home/$USER/$SRCDIR/qemu-3dfx/ &&
cd wrappers/mesa &&
mkdir build && cd build &&
bash ../../../scripts/conf_wrapper &&
make && make clean &&
echo "wrapper build is complete transferring wrapper to buildir" ;
mkdir ${BUILDIR}/wrappers &&
mkdir ${BUILDIR}/wrappers/3dfx && mkdir ${BUILDIR}/wrappers/mesa &&
rsync -avHp /home/$USER/$SRCDIR/qemu-3dfx/wrappers/mesa/build/ $BUILDIR/wrappers/mesa &&
rsync -avHp /home/$USER/$SRCDIR/qemu-3dfx/wrappers/3dfx/build/ $BUILDIR/wrappers/3dfx &&
cd ~/ ;
echo "done"
```

This builds ISO from SoftGPU release with wrappers builts previously, and updates signature in registry file.
```
$ cat ./qemu924-sgpu-build-iso.sh
#!/bin/bash

export DEPDIR=/home/$USER/qemu-sgpu-deps ;
export ISODIR=/home/$USER/softgpu-iso ;

unzip $DEPDIR/softgpu-0.8.2025.53.zip -d $ISODIR ;

export BUILDIR="/home/$USER/qemu-924-sgpu-3dfx" &&
export SRCDIR="sgpu-3dfx-build-924-current" &&

export OHASH="$(cat $ISODIR/extras/qemu3dfx/set-sign.reg  | grep "REV_QEMU3DFX"  | grep -v ";" |  cut -c 17-23)" ;
export BHASH="$(head -1 $BUILDIR/sign-commit.txt | cut -c 1-7)" ;


cd $ISODIR/extras/qemu3dfx/ ;
echo $OHASH ;
echo $BHASH ;
sed -i "s/$OHASH/$BHASH/g" ./set-sign.reg ;
cd ~/ ;
cp $BUILDIR/wrappers/mesa/qmfxgl32.dll $ISODIR/extras/qemu3dfx/. ;
cp $BUILDIR/wrappers/mesa/wglinfo.exe $ISODIR/extras/qemu3dfx/. ;
cp $BUILDIR/wrappers/3dfx/fxmemmap.vxd $ISODIR/extras/qemu3dfx/. ;
$DEPDIR/mkisofs.exe -o $ISODIR-$BHASH.iso -J -R -V "sgpu" $ISODIR ;
echo "cd-creation complete"
```
