export PATH=/usr/java6_64/bin:$PATH
/filemanager/BIN/spoon-5.0.1/data-integration/kitchen.sh -file=$(cd $(dirname "$0"); pwd)"/main.kjb" "-param:P_PAIS=$1" --level=Basic 
echo $?

