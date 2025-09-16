Assumed filesystem name is bre2

1.) Unmount the filesystem everywhere
mmumount bre2 -a

2.) Delete the filesystem
mmdelfs bre2 -p

3.) Clean up NSDs if you’re never reusing them
List the NSDs:
mmlsnsd
Delete the NSDs tied to bre2:
mmdelnsd <NSD-names>

3A.) Delete Disks
Next, delete the disk definitions from the filesystem. This command removes the 
physical disk information from the GPFS configuration for bre2.
mmdeldisk bre2 all

4.) Change the multipath mapper file.
blacklist {
    devnode "sdb"
    devnode "sdc"
}
blacklist_exceptions {
    devnode "sd[e-z]"
}
multipaths {
    multipath {
        wwid    3600508b4001234567890abcdef000001
        alias   gpfs_lun01
    }
    multipath {
        wwid    3600508b4001234567890abcdef000002
        alias   gpfs_lun02
    }
    multipath {
        wwid    3600508b4001234567890abcdef000003
        alias   gpfs_lun03
    }
    ...

5.) Create a new nsdfile.txt for the 16 luns:
%nsd:
  device=/dev/mapper/gpfs_lun0
  nsd=bre2nsd01
  usage=dataAndMetadata
  servers=node1,node2

%nsd:
  device=/dev/mapper/gpfs_lun1
  nsd=bre2nsd02
  usage=dataAndMetadata
  servers=node1,node2

%nsd:
  device=/dev/mapper/gpfs_lun2
  nsd=bre2nsd03
  usage=dataAndMetadata
  servers=node1,node2

6.) Create the NSD's:
mmcrnsd -F nsdfile.txt

7.) Create the filesystem:
mmcrfs bre2 -F nsdfile.txt -A yes -T /gpfs/bre2 -B 256M
