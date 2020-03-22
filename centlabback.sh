function dbdiffcheck (){
echo "select UTIME,DESCRIPTION from IPADDRESS order by DESCRIPTION,UTIME" | mysql -uDBUSER -pDBPASSW DBNAME | md5sum
LANG=C ls -l /var/www/html/ | md5sum
}

function runbackup(){
set -xe
mkdir -p ./bktemp
mysqldump -uDBUSER -pDBPASSW DBNAME TABLENAME > ./bktemp/ladump_$(date +%F).sql
## ladump_$(date +%F).sql
SRCLIST="all.php  daract.php  dbcred.php  free.php   ip.php      poundmenu.php  used.php davmrc.php  editor.php  index.php  ipedit.php  stat.php ladump_$(date +%F).sql"
ARNAME=labbk_$(date +%F).tar.gz
TARGET=/var/www/html
cp -rf $TARGET/*.php ./bktemp/
cd ./bktemp/
tar cvzf ${ARNAME} ${SRCLIST}
scp -i ~/.ssh/id_rsa_labbk -P 22222 ${ARNAME} labbak@${BACKUPTARGET_SERVER}:/home/labbak/labbakdir/
rm -f  ${ARNAME} ${SRCLIST}
}


yesterdayhash="$(cat /root/yesterdayhash)"

todayhash="$(dbdiffcheck)"
if  [ "$todayhash" != "$yesterdayhash" ];then
        echo change detected and run
        runbackup
        echo -n "$todayhash" > /root/yesterdayhash
else
        echo no change detected
fi


