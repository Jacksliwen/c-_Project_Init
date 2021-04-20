#!/bin/bash

##最多启动32个进程
MAX_NUM=32
PROCESS_NUM=$1
PROJ_NAME="xfpr"
WORK_DIR=${PWD}

#1.判断参数是否为数字
if [[ $# -ge 1 ]]; then
    isdigit=`awk 'BEGIN { if (match(ARGV[1],"^[0-9]+$") != 0) print "true"; else print "false" }' ${PROCESS_NUM}`
    if [[ $isdigit == "false" ]]; then
        echo "param invalid."
        echo "usage: ./package.sh num(default 1)"
        exit
    fi
    if [[ ${PROCESS_NUM} -ge MAX_NUM ]]; then
        PROCESS_NUM=32
    fi
else
    PROCESS_NUM=1
fi

#2.打包
echo "-- WORK_DIR "${WORK_DIR}
echo "-- PROCESS_NUM -"${PROCESS_NUM}"-"

mkdir -p ${WORK_DIR}/${PROJ_NAME}
cd ${WORK_DIR}/${PROJ_NAME}
echo "-- Create "${WORK_DIR}/$PROJ_NAME
rm -rf *

#2.1 拷贝lib
DEP_LIST=$( ldd ${WORK_DIR}/build/bin/${PROJ_NAME} | awk '{if (match($3,"/")){ print $3}}' )  
mkdir lib
cp -L -n ${DEP_LIST} lib

# #2.2 拷贝bin conf 服务部署个数
# ((PROCESS_NUM--)) #自减 1
# for i in $(seq 0 ${PROCESS_NUM})  
# do  
#     mkdir -p ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}
#     echo "-- Create "${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}
#     cp -r ${WORK_DIR}/build/bin/* ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}
#     cp -r ${WORK_DIR}/conf ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}
#     #gpunum
#     if [[ $i -ge 10 ]]; then
#         sed -i "s/50300/503${i}/g" ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/conf/${PROJ_NAME}.cfg
#     else
#         sed -i "s/50300/5030${i}/g" ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/conf/${PROJ_NAME}.cfg
#     fi
#     sed -i "s/\[0\]/\[${i}\]/g" ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/conf/${PROJ_NAME}.cfg  
#     #start.sh
#     if [[ $i -eq 0 ]]; then
#         echo "nohup ./${PROJ_NAME} -c 127.0.0.1:8500 >/dev/null &" >  ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/start.sh 
#     else
#         echo "nohup ./${PROJ_NAME} -c 127.0.0.1:8500 -i ${PROJ_NAME}${i} >/dev/null &" >  ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/start.sh 
#     fi
#     chmod +x ${WORK_DIR}/${PROJ_NAME}/${PROJ_NAME}${i}/start.sh
# done

# #start_all.sh
# cp ${WORK_DIR}/start_all.sh ${WORK_DIR}/${PROJ_NAME}

#VERSION   
echo "$PROJ_NAME VERSION : `git describe --tags`" > ${WORK_DIR}/${PROJ_NAME}/VERSION.txt
chmod 777 ${WORK_DIR}/${PROJ_NAME}/VERSION.txt

echo "--pack done--" 
