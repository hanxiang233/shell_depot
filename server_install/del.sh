#!/bin/bash
dock_id=`docker ps -a |grep -v "CONTAINER" |cut -d " " -f 1`
rm -rf /usr/tmp/*
rm -rf /usr/local/src/onpremise_app
read -p "确认是否要移除所有正在运行的容器(y/n): " del_docker

if [ $del_docker == y ]
   then
   
    for stop in $dock_id
        do
            docker stop $stop
        done

    for del in $dock_id
        do
            docker rm $del
        done
    else
	    exit
fi
