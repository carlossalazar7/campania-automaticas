export PATH=/usr/java6_64/bin:$PATH
/filemanager/BIN/spoon-5.0.1/data-integration/kitchen.sh -file=$(cd $(dirname "$0"); pwd)"/main.kjb"  --level=Basic >> $(cd $(dirname "$0"); pwd)/exec_log.log /norep
echo $?

