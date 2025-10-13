#!/bin/bash

sudo apt-get install git ninja-build build-essential xxd xz-utils mingw-w64-tools python3-pkgconfig libgio-2.0-dev libvdeslirp-dev libepoxy-dev meson acpica-tools wget libvirglrenderer1 python3-setuptools python3-pip libsdl2-dev rsync gcc-mingw-w64-i686 libfl2;

export TESTIME="$(date +%Y-%m-%d-%H-%M-%S | sort)"
export BUILDIR="/home/$USER/qemu924-smoll-linux-build" &&
export SRCDIR="sgpu-build" &&

cd ~/Downloads
wget https://download.qemu.org/qemu-9.2.4.tar.xz &&
wget https://github.com/open-watcom/open-watcom-v2/releases/download/Last-CI-build/ow-snapshot.tar.xz &&
wget https://github.com/andrewwutw/build-djgpp/releases/download/v3.4/djgpp-linux64-gcc1220.tar.bz2 &&

echo "qemu build starting, proceeding to build prep" ;
cd ~/ &&
mkdir ${BUILDIR} &&
mkdir ${SRCDIR} && 
cd ${SRCDIR} &&
git clone https://github.com/JHRobotics/qemu-3dfx.git &&
cd qemu-3dfx &&
tar xf ~/Downloads/qemu-9.2.4.tar.xz &&
cd qemu-9.2.4 &&
rsync -r ../qemu-0/hw/3dfx ../qemu-1/hw/mesa ./hw/ &&
patch -p0 -i ../00-qemu92x-mesa-glide.patch &&
bash ../scripts/sign_commit 2>&1 | tee ~/sign-commit.txt &&
mkdir ../build &&
cd ../build &&
../qemu-9.2.4/configure –iasl=/usr/bin/iasl --enable-tcg --disable-tcg-interpreter --enable-hv-balloon --enable-fdt=auto --enable-qcow1 --disable-whpx --disable-hvf --enable-opengl --enable-slirp --target-list=x86_64-softmmu,i386-softmmu --enable-kvm --enable-sdl –audio-drv-list=sdl,pa --enable-relocatable --enable-strip --enable-membarrier --enable-iconv --enable-lto --enable-tools --prefix=$BUILDIR --extra-cflags=" -mtune=generic -march=x86-64-v2 " 2>&1 | tee ~/Configure-latest.txt  && 
make -j 6 && make install -j 6 &&
cd ~/ &&
mv ~/Configure-latest.txt  ${BUILDIR}/configure-latest.txt &&
mv ~/sign-commit.txt ${BUILDIR}/sign-commit.txt &&
cd ${BUILDIR}/share/qemu/ && cat edk2-i386-vars.fd edk2-x86_64-code.fd > OVMF.FD && cp OVMF.FD OVMF.BIN && cd - ;
echo "qemu build complete, proceeding to building wrappers" ;
mkdir -p /tmp/wrapper-deps/ &&
cd /tmp/wrapper-deps &&
tar xjf ~/Downloads/djgpp-linux64-gcc1220.tar.bz2 &&
mkdir -p /tmp/wrapper-deps/owatcom && 
cd /tmp/wrapper-deps/owatcom &&
tar xf ~/Downloads/ow-snapshot.tar.xz  &&
export PATH="${PATH}:/tmp/wrapper-deps/djgpp/bin"  &&
export PATH="${PATH}:/tmp/wrapper-deps/djgpp/i586-pc-msdosdjgpp/bin"  &&
export PATH="${PATH}:/tmp/wrapper-deps/owatcom/binl64" &&
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
