export PATH=/usr/java8_64/bin:$PATH


echo $KETTLE_HOME
now="$(date +'%Y%m%d')"
logfilepath="/filemanager/BIN/CREDITS/CAMP_AUTOMATICAS/CMP_INACT_1/notif_automaticas_"${now}".log"
jobfilepath="/filemanager/BIN/CREDITS/CAMP_AUTOMATICAS/CMP_INACT_1/CAMP_AUTOMATICAS_INAC_SC_SQL_MAIN.kjb"
sh /filemanager/BIN/spoon-5.0.1/data-integration/kitchen.sh  "-file=$jobfilepath" "-param:P_PAIS=$1" "-logfile=$logfilepath" "-level=Detailed"  2>&1 | tee -a $logfilepath
echo "-----------------------------------------------------------------------------------------------------------------" | tee -a $logfilepath
