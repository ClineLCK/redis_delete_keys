#!/bin/sh

# 批量模糊删除redis key

redis_list=("10.213.3.18:6379" "10.213.3.17:6379" "10.213.6.107:6379")
key_pre="$1"
password=""

# 判断是否为空  为空下面的命令执行没意义
if [ -z $key_pre ]
then
    echo "key can not be empty."
        exit
# 判断是否为*
elif [ "${key_pre}" = "*" ]
then
        echo "Warning!!! You can not clean all caches."
        exit
fi

# 确认操作
while true
do
        read -r -p "The key is $key_pre, confirm it? [Y/n] " input

        case $input in
            [yY][eE][sS]|[yY])
                        # 循环集群ip及端口处理
                        for info in ${redis_list[@]}
							do
								echo "开始执行:$info"  
								ip=`echo $info | cut -d : -f 1`
								port=`echo $info | cut -d : -f 2`
								/home/admin/redis/bin/redis-cli -c -h $ip -p $port --scan --pattern "${key_pre}" | xargs -r -t -n1 /home/admin/redis/bin/redis-cli -h $ip -p $port -a $password -c del
							done
							echo "完成"
                        exit 1
                        ;;
         
            [nN][oO]|[nN])
                        echo "exit.."
                        exit 1
                        ;;
            *)
                        echo "Invalid input...   Try it again"
                        ;; 
        esac
done

# xargs接收前面命令执行的结果进行处理
# -t参数则是打印出最终要执行的命令，然后直接执行，不需要用户确认
