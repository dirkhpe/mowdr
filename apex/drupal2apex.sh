#!/usr/bin/ksh -x
# Drupal *.xml bestanden afhalen van de vonet dropsever naar localhost uv162942

# variabelen:

DROPUSERDRUP=mow_drupal
FROMSERVER=dropserver.vonet.be
FROMDIR=IN
TODIRPREP=/oracle/oradata/APEXPREP/ext_tables/dataroom/in
TODIRPROD=/oracle/oradata/APEXPROD/ext_tables/dataroom/in
LOGDIRPREP=/oracle/oradata/APEXPREP/ext_tables/dataroom/log
LOGDIRPROD=/oracle/oradata/APEXPROD/ext_tables/dataroom/log
JOBNAME=`basename $0`
LOGFILEPREP=${LOGDIRPREP}/${JOBNAME}.$( date '+%d')
LOGFILEPREP=${LOGDIRPROD}/${JOBNAME}.$( date '+%d')

export DROPUSERMDK ROMSERVER FROMDIR TODIRPREP TODIRPROD LOGDIRPREP LOGDIRPROD JOBNAME LOGFILEPREP LOGFILEPROD

#functies:

log_record_prep() {
  DATE=$(date '+%Y%m%d')
  TIME=$(date '+%H%M%S')FROM
  echo "$0;$DATE;$TIME;$MSG" >>$LOGFILEPREP
}

log_record_prod() {
  DATE=$(date '+%Y%m%d')
  TIME=$(date '+%H%M%S')FROM
  echo "$0;$DATE;$TIME;$MSG" >>$LOGFILEPREP
}

listremotefiles() {
sftp $DROPUSERDRUP@$FROMSERVER << EOF |tee /var/tmp/drupftplogfile
cd $FROMDIR
ls -l
bye
EOF
}

listremotefiles

NUM=`grep ".xml" /var/tmp/drupftplogfile |wc -l`

if [ $NUM -eq 0 ]; then
    MSG="geen databestanden aanwezig."
    log_record_prep
    log_record_prod
    #indien niet beeindig het script
    exit 0

else

FILES=`grep "prep_" /var/tmp/drupftplogfile |awk '{print $9}'`

for i in $FILES; do

SIZE=`grep $i /var/tmp/drupftplogfile | awk '{print $5}'`
sleep 10
listremotefiles
while [ `grep $i /var/tmp/drupftplogfile | awk '{print $5}'` -ne $SIZE ]
do
listremotefiles
sleep 10
SIZE=`grep $i /var/tmp/drupftplogfile | awk '{print $5}'`
done
scp $DROPUSERDRUP@$FROMSERVER:$FROMDIR/$i $TODIRPREP
if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record_prep
       exit 20
    else
       MSG="databestand $i van de dropserver afgehaald"
       log_record_prep

sftp $DROPUSERDRUP@$FROMSERVER << EOF
cd $FROMDIR
rm $i
bye
EOF

fi
done

FILES=`grep ".xml" /var/tmp/drupftplogfile | grep -v "prep" | awk '{print $9}'`

for i in $FILES; do

SIZE=`grep $i /var/tmp/drupftplogfile |grep -v "prep" | awk '{print $5}'`
sleep 10
listremotefiles
while [ `grep $i /var/tmp/drupftplogfile |grep -v "prep" | awk '{print $5}'` -ne $SIZE ]
do
listremotefiles
sleep 10
SIZE=`grep $i /var/tmp/drupftplogfile |grep -v "prep" | awk '{print $5}'`
done
scp $DROPUSERDRUP@$FROMSERVER:$FROMDIR/$i $TODIRPROD
if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record_prod
       exit 20
    else
       MSG="databestand $i van de dropserver afgehaald"
       log_record_prod

sftp $DROPUSERDRUP@$FROMSERVER << EOF
cd $FROMDIR
rm $i
bye
EOF

fi
done

fi
