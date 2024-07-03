#!/bin/bash

# 检查是否以root用户运行脚本
if [ "$(id -u)" != "0" ]; then
    echo "此脚本需要以root用户权限运行。"
    echo "请尝试使用 'sudo -i' 命令切换到root用户，然后再次运行此脚本。"
    exit 1
fi

cd $HOME
FOLDER=nubit-node
FILE_NUBIT=$FOLDER/bin/nubit
FILE_NKEY=$FOLDER/bin/nkey
STORE=.nubit-light-nubit-alphatestnet-1

# 清空之前的安装数据
pkill -9 nubit
rm -rf nubit-node-linux-x86_64.tar
rm -rf nubit-node-linux-x86_64
rm -rf nubit-node
rm -rf lightnode_data.tgz
rm -rf .nubit-light-nubit-alphatestnet-1
rm -rf nubit-address.txt
rm -rf nubit-mnemonic.txt
rm -rf nubit-publicKey.txt
rm -rf nubit-node.log
rm -rf .nubit-validator


# 直接下nubit节点安装包，跳过官方脚本中的检查系统版本、md5等操作
echo "下载nubit节点安装包"
curl -sLO https://nubit.sh/nubit-bin/nubit-node-linux-x86_64.tar # 对应linux-x86_64系统
echo "安装nubit节点"
tar -xvf nubit-node-linux-x86_64.tar
if [ ! -d $FOLDER ]; then
    mkdir $FOLDER
fi
if [ ! -d $FOLDER/bin ]; then
    mkdir $FOLDER/bin
fi
mv nubit-node-linux-x86_64/bin/nubit $FOLDER/bin/nubit
mv nubit-node-linux-x86_64/bin/nkey $FOLDER/bin/nkey
rm -rf nubit-node-linux-x86_64
rm -rf nubit-node-linux-x86_64.tar


# 直接下载nubit节点数据包
echo "下载nubit节点数据包"
curl -sLO https://nubit.sh/nubit-data/lightnode_data.tgz
echo "安装nubit节点数据包"
mkdir $STORE
tar -xvf lightnode_data.tgz -C $STORE
rm -rf lightnode_data.tgz


# 下载nubit节点启动脚本，并以nohup启动，避免影响下面流程
curl -sL1 https://nubit.sh/start.sh -o $FOLDER/start.sh
chmod +x $FOLDER/start.sh
nohup ./$FOLDER/start.sh > nubit-node.log 2>&1 &

# 等待30秒
sleep 30
echo "nubit节点运行成功"
echo "读取钱包地址、助记词、publicKey"
# 获取钱包地址、助记词、publicKey并写入文件
ADDRESS=$(./$FILE_NUBIT state account-address  --node.store $STORE | grep -o '"result": *"[^"]*"' | sed 's/"result": "\(.*\)"/\1/')
MNEMONIC=$(cat $FOLDER/mnemonic.txt)
PUBLICKEY=$(./$FILE_NKEY list --p2p.network nubit-alphatestnet-1 --node.type light | grep -o '"key":"[^"]*"' | sed -n 's/.*"key":"\([^"]*\)".*/\1/p')
echo "钱包地址: $ADDRESS"
echo "助记词: $MNEMONIC"
echo "publicKey: $PUBLICKEY"
echo $ADDRESS > $HOME/nubit-address.txt
echo $MNEMONIC > $HOME/nubit-mnemonic.txt
echo $PUBLICKEY > $HOME/nubit-publicKey.txt

echo "执行完毕"
