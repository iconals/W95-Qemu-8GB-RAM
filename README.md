# W95-Qemu-8GB-RAM
Guide to install Windows 95B in qemu with WHPX/KVM support


Qemu invocation:
```
./qemu-system-i386.exe -net none -m 8192 \
 -rtc base=localtime -machine pc,accel=whpx,kernel-irqchip=off,hpet=off,acpi=off  \
-L ./share/  -drive file=/l/vxd-test95b.vhd,format=vpc,media=disk \
-device VGA,addr=0x09 -display sdl,gl=on \
-audiodev id=sdl,driver=sdl  \
-device AC97,audiodev=sdl,addr=0x07 \
-fda /l/wproj-w95/oWindows95b.img
```

Or if you want a sound blaster 16 card:
```
 -audiodev id=sdl,driver=sdl   -device sb16,audiodev=sdl,irq=5,dma=1,dma16=5,iobase=0x220,version=0x404
```

For installation, you would want to boot to a windows floppy to fdisk and format drive.

Then use ```xcopy /s /e R: c:\\win95``` to copy contents from cdrom to hdd.

I turn off acpi in qemu, and run "setup.exe /p i;m /is" from MS DOS.

This will avoid PNP issues and if you have chipset drivers for Pc or Q35 in windows setup folder these will be used during install.

The setup command needs to be run from dos prompt as it will use mini windows mode and skip disk checks.

After install completes and initial devices are detected you can turn on acpi for qemu and it will be detected.

This command specifies whpx, you would use kvm on linux.
```
-machine pc,accel=whpx,kernel-irqchip=off,hpet=off,acpi=off
```

If on other platforms without accelerator, or if OS is not booting;
Also, if install is not compatible with kvm/whpx:
Use tcg with kernel-irqchip=on
```
-machine pc,accel=whpx,kernel-irqchip=off,hpet=off,acpi=off
```

During the setup phase (running setup.exe) you can use whpx.
However, the next boot is the 2nd stage, and this is not compatible with whpx. You need to use tcg, to complete initial install and first boot into windows.
After windows is installed, you should enable DMA for HDD/CD-DVD.
After DMA is setup you can reboot and use WHPX.

Shutdown/Reboot from windows with WHPX/KVM can be wonky when using start menu to do so.
It is recommended to find and use reboot shutdown .com files for dos and set these up as bat files/shortcuts to avoid windows asking to scan on bad shutdown. Instructions:

https://support.novell.com/techcenter/tips/ant19980404.html

The quit and reboot from this github will work to safely reboot windows using whpx:
https://github.com/crgimenes/shutdown

Or (not recommended) add autoscan=0 to msdos.sys to avoid scans on bad shutdowns.

At some point you need to use patch9x, this can be done before install or after install is complete.
You will need to use rloews patchmem after windows installs, then you can set higher memory limits >512.
After pachmem us run you can enable himemex using sysenter method (in my case). 
Then you can setup ramdrives.

Readme source for Rloew projects: (Https warning)
```
https://rloewelectronics.com/distribute/RAMDISK/RAMDISK2.0/README.TXT
https://rloewelectronics.com/distribute/PATCHMEM/PRO7.2/README.TXT
```

You may want to grab winset (on win95 cd) and use this to change temp location if you do want to move temp to another drive. Setting temp/tmp variables in config.sys works for dos but might not for all windows apps.

```
https://jeffpar.github.io/kbarchive/kb/140/Q140574/
```

Example config for -m 2048/2G RAM

```
Config.sys
lastdrive=z
device=c:\Himemex.sys /S /L:100000
```

```
Autoexec.bat
u/echo off
c:\ramdsk32.com X: 1048576
LABEL x: DATA
mkdir x:\temp
set TEMP=x:\temp
set TMP=X:\temp
```

You can also use ramdsk64 if using more than 4GB, then you would add
Ramdsk64 to autoexec with drive letter assigned. It will use any memory past 4Gb.

For ramdsk32 if using more than 1Gb you need to adjust size to fit between himemx limit and end of pae limits or /4Gb in qemu. README for ramdsk32.
