#!/usr/bin/ksh -x
# bestanden afhalen van de dropsever

# variabelen:

DROPUSERMDK=mow_mdk
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
sftp $DROPUSERMDK@$FROMSERVER << EOF |tee /var/tmp/mdkftplogfile
cd $FROMDIR
ls -l
bye
EOF
}

listremotefiles

NUM=`grep ".csv" /var/tmp/mdkftplogfile |wc -l`

if [ $NUM -eq 0 ]; then
    MSG="geen databestanden aanwezig."
    log_record_prep
    log_record_prod
    #indien niet beeindig het script
    exit 0

else

FILES=`grep "prep_" /var/tmp/mdkftplogfile |awk '{print $9}'`

for i in $FILES; do

# initial size =
SIZE=`grep $i /var/tmp/mdkftplogfile | awk '{print $5}'`

# wacht effe
sleep 10

# ververs de checkfile
listremotefiles

# vergelijk en herhaal indien verschillend
while [ `grep $i /var/tmp/mdkftplogfile | awk '{print $5}'` -ne $SIZE ]
do
sleep 10
SIZE=`grep $i /var/tmp/mdkftplogfile | awk '{print $5}'`
done
scp $DROPUSERMDK@$FROMSERVER:$FROMDIR/$i $TODIRPREP
# sftp $DROPUSERMDK@$FROMSERVER <<EOF
# lcd $TODIRPREP
# cd $FROMDIR
# get $i
# bye
# EOF

if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record_prep
       exit 20
    else
       MSG="databestand $i van de dropserver afgehaald"
       log_record_prep

sftp $DROPUSERMDK@$FROMSERVER << EOF
cd $FROMDIR
rm $i
bye
EOF

fi
done

FILES=`grep ".csv" /var/tmp/mdkftplogfile |grep -v "prep" |awk '{print $9}'`

for i in $FILES; do

SIZE=`grep $i /var/tmp/mdkftplogfile |grep -v "prep" | awk '{print $5}'`
sleep 10
listremotefiles
while [ `grep $i /var/tmp/mdkftplogfile |grep -v "prep" | awk '{print $5}'` -ne $SIZE ]
do
listremotefiles
SIZE=`grep $i /var/tmp/mdkftplogfile |grep -v "prep" | awk '{print $5}'`
done
scp $DROPUSERMDK@$FROMSERVER:$FROMDIR/$i $TODIRPROD

# sftp $DROPUSERMDK@$FROMSERVER <<EOF
# lcd $TODIRPROD
# cd $FROMDIR
# get $i
# bye
# EOF

if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record_prod
       exit 20
    else
       MSG="databestand $i van de dropserver afgehaald"
       log_record_prod

sftp $DROPUSERMDK@$FROMSERVER << EOF
cd $FROMDIR
rm $i
bye
EOF

fi
done

fi
