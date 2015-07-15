#!/bin/sh

if [ $# -ne 4 ]; then
    echo "$0 key host hadooode_package cdh"
    exit 1
fi

key=$1
host=$2
package=$3
cdh=$4

scp -i ~/.ssh/$key -r ~/.zshrc root@$host:~/
scp -i ~/.ssh/$key -r ~/.screenrc root@$host:~/
scp -i ~/.ssh/$key -r ~/.vimrc root@$host:~/
scp -i ~/.ssh/$key -r ~/.ssh root@$host:~/ssh
ssh -i ~/.ssh/$key root@$host "cp ~/ssh/id* ~/.ssh/"
ssh -i ~/.ssh/$key root@$host "cp ~/ssh/config ~/.ssh/"
ssh -i ~/.ssh/$key root@$host "cat ~/ssh/authorized_keys >> ~/.ssh/authorized_keys"
scp -i ~/.ssh/$key -r ~/git/hadooode/packages/$package root@$host:~/
scp -i ~/.ssh/$key -r ~/rpm/$cdh root@$host:~/
scp -i ~/.ssh/$key -r ~/rpm/rpmforge-release-0.5.2-2.el5.rf.x86_64.rpm root@$host:~/
scp -i ~/.ssh/$key -r ~/aws-hadoop-conf root@$host:~/
scp -i ~/.ssh/$key -r ~/aws-hadooode-conf root@$host:~/
ssh -i ~/.ssh/$key root@$host "svn co svn+ssh://svnserv/home/mogwaing/repos/misc/dev/rawdevice io-benchmark"
ssh -i ~/.ssh/$key root@$host "svn co svn+ssh://svnserv/home/mogwaing/repos/misc/dev/scripts scripts"
