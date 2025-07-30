# W95-Qemu-8GB-RAM
Guide to install Windows 95B in qemu with WHPX/KVM support

<img width="1929" height="1232" alt="8gb-95b" src="https://github.com/user-attachments/assets/8bfb7ffb-de05-4f1c-a7f5-45d676ed8bca" />
<img width="1931" height="1231" alt="8gb-95b2" src="https://github.com/user-attachments/assets/a7f36ad0-77cd-40ba-9786-6878bb7b6988" />


Qemu invocation:
```
./qemu-system-i386.exe -net none -m 8192 \
 -rtc base=localtime -machine pc,accel=whpx,kernel-irqchip=off,hpet=off,acpi=on  \
-L ./share/  -drive file=/l/vxd-test95b.vhd,format=vpc,media=disk \
-device VGA,addr=0x09 -display sdl,gl=on \
-audiodev id=sdl,driver=sdl  \
-device AC97,audiodev=sdl,addr=0x07 \
-fda /l/wproj-w95/oWindows95b.img
```

Or if you want a sound blaster 16 card:
```
-audiodev id=sdl,driver=sdl   \
-device sb16,audiodev=sdl,irq=5,dma=1,dma16=5,iobase=0x220,version=0x404 \
 -device adlib,audiodev=sdl,freq=32000
```

For installation, you would want to boot to a windows floppy to fdisk and format drive.

Then use ```xcopy /s /e R: c:\\win95``` to copy contents from cdrom to hdd.

Then run ```setup.exe /p i;m /is``` from MS DOS.

The listed setup command will avoid PNP issues due to ACPI/BIOS conflicts and if you have chipset drivers for Pc or Q35 in windows setup folder these will be used during install.

The setup command needs to be run from dos prompt as it will use mini windows mode and skip disk checks.

After install completes and initial devices are detected you can install drivers for the ACPI PCI Device.

This command specifies whpx, you would use kvm on linux.
```
-machine pc,accel=whpx,kernel-irqchip=off,hpet=off,acpi=on
```

If on other platforms without accelerator, or if OS is not booting;
Also, if install is not compatible with kvm/whpx:
Use tcg with kernel-irqchip=on
```
-machine pc,accel=tcg,kernel-irqchip=on,hpet=off,acpi=on
```

During the setup phase (running setup.exe) you can use whpx.
However, the next boot is the 2nd stage, and this is not compatible with whpx. You need to use tcg, to complete initial install and first boot into windows.
After windows is installed, you should enable DMA for HDD/CD-DVD.
After DMA is setup you can reboot and use WHPX.

Shutdown/Reboot from windows with WHPX/KVM can be wonky when using start menu to do so.
It is recommended to find and use reboot.com shutdown.com files for dos and set these up as bat files/shortcuts to avoid windows asking to scan on bad shutdown. 
Instructions:

https://support.novell.com/techcenter/tips/ant19980404.html

The quit and reboot from this github will work to safely reboot windows using whpx:

https://github.com/crgimenes/shutdown

Or (not recommended) add autoscan=0 to msdos.sys to avoid scans on bad shutdowns.

At some point you need to use patch9x, this can be done before install or after install is complete.

https://github.com/JHRobotics/patcher9x


You will need to use rloews patchmem after windows installs, then you can set higher memory limits >512.
After pachmem has run you can enable himemex using sysenter method (in my case). 
Then you can setup ramdrives.

Readme source for Rloew projects: (Https warning)
```
https://rloewelectronics.com/distribute/RAMDISK/RAMDISK2.0/README.TXT
https://rloewelectronics.com/distribute/PATCHMEM/PRO7.2/README.TXT
```

You may want to grab winset (on win95 cd) and use this to change temp location if you do want to move temp to another drive. Setting temp/tmp variables in config.sys works for dos but might not for all windows apps.


https://jeffpar.github.io/kbarchive/kb/140/Q140574/


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


Note on networking:

The provided instructions do not cover setting up network, however you can still get to google.com from explorer in windows 95.
You would want to select a compatible network card and specify to add TCP/IP support for network adapter during initial install.
Adding networking later can be problamatic if you used any specific setup switches to skip networking installation. 
None of the 1GB NIC's provided by qemu seem to work in windows 9x. The Tulip adapter counts as 1GB, but does not have TCP in win9x. 
Some of the early Intel nics (i82557a,b,c) provided by qemu will work in win95B/X using intels drivers:  PRO95_6.2.EXE tested on my end.

Note on Q35:

The Q35 machine is compatible with installing windows 9X provided that you add a secondary controller like piix3-ide or piix4-ide and set up drives on that controller.
The SATA controller provided by Q35 is not compatible with Win9x; the device can be detected and installed however drive access will crash the VM.
Using PCIE topology works fine in windows9x and you can setup pcie-pci bridging if needed:


```
./qemu-system-i386.exe  -display sdl,gl=on -M q35,acpi=on,hpet=off,sata=off -m 384 \
 -rtc base=localtime,clock=host  \
-k en-us -cpu "qemu32,+hv-relaxed,+hv-vpindex,+hv-runtime,+hv-time,+hv-frequencies,hv-no-nonarch-coresharing=on"  \
-audiodev id=sdl,driver=sdl   \
-device pcie-pci-bridge,id=pcie_pci_bridge1,bus=pcie.0  \
-device pci-bridge,id=pci_bridge1,bus=pcie_pci_bridge1,chassis_nr=1,addr=0x3 \
-device vmware-svga,bus=pcie.0,id=video0,vgamem_mb=128  \
-device AC97,bus=pcie.0,audiodev=sdl \
-device piix4-ide,bus=pcie.0,id=ide1  \
-netdev user,id=net \
-device rtl8139,addr=0x4,netdev=net,bus=pci_bridge1 \
-device ide-cd,bus=ide1.0,drive=disk2 \
-drive file='L:',id=disk2,if=none,format=raw,media=cdrom   \
 -device ide-hd,bus=ide1.0,drive=disk1 \
-drive file=/o/6g.img,id=disk1,if=none,format=raw
```

Note on Chipset Drivers:

As per OEM instructions for Win9X you can add driver files to windows setup folder and these will be used if newer than drivers provided by Windows.

To simplify doing this I reccomend using uniextract to extract files from chipset utility:

https://github.com/Bioruebe/UniExtract2

For PC machine 

https://www.philscomputerlab.com/intel-chipset-drivers.html
3.20.1008.zip

For Q35 machine 
INF_AllOS_8.3.1.1009_PV_Intel

You would need to extract archive into folder, then you can use unitextract to extract the setup program, then you would need to extract the data1.cab file. 
Then pull *.cat files and *.inf files from related folders and place into setup folder. 

VGA Drivers:
if the basic display adapter does not fit your needs softgpu is a free driver that can support windows 95b. Win98/se is better supported:
https://github.com/JHRobotics/softgpu

There are various releases for softgpu, some options may need to be disabled for win95. Make sure to select Qemu. 
Vaanilla qemu does work with these drivers, the author provides a fork of qemu-3dfx to provide more features.
Softgpu does support pc/q35 machines using qemu to run win9x OS with either tcg or KVM/TCG.


Note on Vmware Display device in Qemu:


Qemu does use the vmware-display device provided by Vmware and this does work with related drivers in Qemu Guests running windows 95 up to windos 10/11.
However NO 3d acceleration is provided and 256 color modes / 640x480 resolution is impacted and games needing this will not function.
External OpenGL acceleration can work with the driver but it is not provided by the driver. 

Instructions for extracting VMware drivers on host to prepare for guest:

https://knowledge.broadcom.com/external/article?legacyId=2032184

You would proceed to install the display device drivers through control panel/display properties in guest VM and add the device drivers for related OS. 
You can tryout various driver versions as there are a range available depending on OS. 




Extras, these might not be needed; however I have tested and they do work in qemu:


https://github.com/mintsuki/cregfix


Boot disk app to help with boot issues for old OS.

https://nuangel.net/2018/06/the-secret-to-a-stable-windows-95-98-98se-or-millennium-edition-me/


Bat file that extracts some extra VXD's from windows CD-ROM for better stability.

If you do wish to use VXD_FIX, please run before patch9x, and then run patchmem lastly after installing patch9x.

Notes If you want to try automating patching / unattended install: 

In my testing I modified win95b boot floppy and vxd_fix to check C and not D. 
After Initial windows setup use win95b bootfloppy to install VXD FIX, then you can run patch9x from its boot image.
After windows setup phase, shutdown. Run patchmem from modified win95b boot floppy.
Then you can set large mem size and perform first boot of windows with large memory.
Remember first boot and 2nd stage of windows setup wont work with acceleration KVM/WHPX.

