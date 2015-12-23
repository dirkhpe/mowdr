#!/usr/bin/ksh -x
# bestanden afhalen van de dropsever

# variabelen:

DROPUSERMDK=mow_mdk
DROPUSERDRUP=mow_drupal
TOSERVER=dropserver.vonet.be
FROMDIRPROD=/oracle/oradata/APEXPROD/ext_tables/dataroom/out
FROMDIRPREP=/oracle/oradata/APEXPREP/ext_tables/dataroom/out
TODIR=OUT
LOGDIR=/oracle/oradata/APEXPROD/ext_tables/dataroom/log
JOBNAME=`basename $0`
LOGFILE=${LOGDIR}/${JOBNAME}.$( date '+%d')

export DROPUSERMDK TOSERVER FROMDIRPROD FROMDIRPREP TODIR LOGDIRPROD LOGDIRPREP JOBNAME LOGFILE

#functies:

log_record() {
  DATE=$(date '+%Y%m%d')
  TIME=$(date '+%H%M%S')FROM
  echo "$0;$DATE;$TIME;$MSG" >>$LOGFILE
}

NUM=` find $FROMDIRPREP $FROMDIRPROD -type f |wc -l`

if [ $NUM -eq 0 ]; then
    MSG="geen databestanden aanwezig."
    log_record
    #indien niet beeindig het script
    exit 0

else

FILES=`find $FROMDIRPREP $FROMDIRPROD -type f`

for i in $FILES; do

case $i in

*.csv)

SIZE=`ls -al $i | awk '{print $5}'`
while [ `ls -al $i | awk '{print $5}'` -ne $SIZE ]
do
sleep 10
SIZE=`ls -al $i | awk '{print $5}'`
done
scp $i $DROPUSERMDK@$TOSERVER:$FROMDIR/$TODIR
if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record
       exit 20
    else
       MSG="$i op de dropserver geplaatst"
       log_record
	rm $i
fi

;;

*.xml)

SIZE=`ls -al $i | awk '{print $5}'`
while [ `ls -al $i | awk '{print $5}'` -ne $SIZE ]
do
sleep 10
SIZE=`ls -al $i | awk '{print $5}'`
done
scp $i $DROPUSERDRUP@$TOSERVER:$FROMDIR/$TODIR
if [ $? != 0 ]; then
       MSG="problemen met secure copy $i"
       log_record
       exit 20
    else
       MSG="$i op de dropserver geplaatst"
       log_record
	rm $i
fi

;;

esac

done

fi
