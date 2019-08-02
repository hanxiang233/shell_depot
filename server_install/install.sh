#/bin/bash
ins_dir=/usr/local/src
read -p "请输入docker容器的volumes使用路径(例:dir1/dir2..):" volumes
sqldata=usr/tmp/mysql_data
datadir=/usr/tmp/aidvoice-voiceprint-local
dockerfile=/usr/local/src/onpremise_app/devops/docker-compose.yml 

tar zxf $ins_dir/install/docker-18.06.3-ce.tgz -C $ins_dir/install
cp $ins_dir/install/docker/* /usr/bin/ | cp $ins_dir/install/docker-compose /usr/bin/ | chmod +x /usr/bin/docker-compose
dockerd &
pid=`ps -aux |awk -F " "  '$11=="dockerd" {print $2}'`

if [ -z $pid ]
    then 
        echo -e "\033[31m docker install error. not in runing."
    else
        docker load --input $ins_dir/images/devops_api_v1.4.img && docker tag 23b86da0372b devops_celery:latest
        docker load --input $ins_dir/images/mysql.images && docker tag a1aa4f76fab9 mysql:5.7
        docker load --input $ins_dir/images/redis.images && docker tag 3c41ce05add9 redis:latest
fi

mkdir -p $datadir && mkdir -p /usr/tmp/mysql_data
while :; do
    true
if [ -z $datadir ]
    then 
        echo "指定目录不存在，请重新指定或创建"
    else
        mkdir -p $datadir/{113mkdir/,114mkdir/,ubm/{113mkdir/,114/}}
        cp -rf  $ins_dir/model/* /$datadir/ubm/ 
        tar zxf $ins_dir/onpremise_app_*.tgz -C $ins_dir/
        #修改sed替换路径,aidvoice-voiceprint-local的上级目录的相对路径
        sed -i 's#data/vpr_share/tmp#'$volumes'#g' $dockerfile && sed -i 's#data/vpr_share/mysql_data#'$sqldata'#g' $dockerfile
        cd $ins_dir/onpremise_app/devops && docker-compose up & 
fi
    sleep 200
  break
done


dnumber=`docker ps |egrep 'devops_api|mysql|redis|devops_celery' |wc -l`
dockerid=`docker ps |awk -F " " '/mysql:5.7/ {print $1}'`

if [ $dnumber -eq 4 ]
    then
        cp $ins_dir/voiceprint.sql /$sqldata/
        docker exec -it $dockerid /bin/bash -c 'mysql -uroot -p123456  voiceprint < /var/lib/mysql/voiceprint.sql'
        voicend=`curl --request POST --url http://127.0.0.1:8000/voiceprint/model/sync/family002/tester4  --header 'authorization: access_key 2d2575dc-be1f-4074-a26f-20d873dcf790' --form 'model_ser=aaaaaaaaaaaaaaa' --form sdk_version=dxyt_v1`
        echo -e "\033[32m 正在运行容器数量$dnumber,服务运行状态"
        echo "$voicend"
    else
        echo "\033[31m docker not runint,it exit..."
fi

