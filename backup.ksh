#! /bin/ksh
## SOURCEPATH:STOREPLACE"
TGT=rconf

mkdir $TGT

CFGS="
/etc/pf.conf
/root/pfcheck.sh
/root/dumppf.sh
/etc/dhcpd.conf
/etc/hostname.{em0,em1,em2}
/var/unbound/etc/unbound.conf
/root/backup.ksh
/etc/dhcpd6.conf
/etc/rc.conf.local
/etc/rad.conf
/root/reload-*.sh
/etc/httpd.conf
/etc/sysctl.conf
"

function runBackup {
for c in $CFGS;
do
cp -f  $c ./${TGT}/$(echo $c | sed s/^\\/etc\\/// |sed s/^\\/root\\/// | sed s/\\//_/g )
done

echo  tar cvzf rconf.tar.gz $TGT
tar cvzf rconf.tar.gz $TGT
}

yesterdayhash="$(cat /root/yesterdayhash)"
todayhash=$(LANG=C ls -lf $CFGS | md5)

echo today $todayhash
echo yeste $yesterdayhash

if [ "$todayhash" != "$yesterdayhash" ];then
        runBackup
        echo -n "$todayhash" > /root/yesterdayhash
        echo NewHashCreated $todayhash
else
        echo backup not required
fi

