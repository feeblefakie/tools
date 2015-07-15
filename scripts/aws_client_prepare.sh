#!/bin/sh

# you need to run this script from one of midori servers

# replace it with your setting
: <<'#__COMMENT_OUT__'
hosts="ec2-54-238-204-146.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-206-3.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-67.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-212.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-207.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-154.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-70.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-242.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-230.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-95.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-92.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-152.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-224.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-206-1.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-204-158.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-204-242.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-205-231.ap-northeast-1.compute.amazonaws.com"
#__COMMENT_OUT__
#hosts="ec2-54-199-163-8.ap-northeast-1.compute.amazonaws.com"

: <<'#__COMMENT_OUT__'
hosts="ec2-54-238-235-244.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-231-50.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-232-162.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-235-29.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-232-220.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-232-143.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-234-183.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-237-1.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-231-77.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-237-24.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-231-21.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-232-24.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-231-254.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-234-83.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-234-235.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-235-72.ap-northeast-1.compute.amazonaws.com \
ec2-54-238-237-44.ap-northeast-1.compute.amazonaws.com"
#__COMMENT_OUT__

hosts="ec2-54-238-232-135.ap-northeast-1.compute.amazonaws.com"

key="aws.pem"

package=hadooode-package-20140313.tgz
cdh=cloudera-cdh-4-0.x86_64.rpm

for host in $hosts
do
    ./aws_client_prepare_impl.sh $key $host $package $cdh
done
wait

echo "127.0.0.1   localhost   localhost.localdomain" > /tmp/hosts
hostn=1

echo "Adding the following to /etc/hosts"
for host in $hosts
do
    hostid=`echo $hostn | awk '{printf "new-aws%03d", $1}'`
    ssh -i ~/.ssh/$key root@$host "/sbin/ifconfig eth0 | grep inet | awk -F ':' '{print \$2}' | awk '{print \$1}'" >> /tmp/hosts
    echo "$hostid " >> /tmp/hosts
    ssh -i ~/.ssh/$key root@$host "hostname $hostid"
    ssh -i ~/.ssh/$key root@$host "echo -e \"HOSTNAME=$hostid\nNETWORKING=yes\nNOZEROCONF=true\nNETWORKING_IPV6=no\" > /etc/sysconfig/network"
    hostn=`expr $hostn + 1`
done

: <<'#__COMMENT_OUT__'

for host in $hosts
do
    scp -i ~/.ssh/$key /tmp/hosts root@$host:/etc/
done
#__COMMENT_OUT__
