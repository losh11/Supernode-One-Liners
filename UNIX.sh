#!/bin/bash
echo "logging in..."
sudo su
echo "updating server"
apt-get update -y
apt-get upgrade -y
echo "getting front-side package for iptable"
apt-get install ufw -y
ufw enable allow ssh
ufw allow ssh
echo "allowed ssh access"
ufw allow 9333/tcp
echo "allowed port 9333 (required to run a supernode)"
iptables -A INPUT -p tcp --syn --dport 9333 -m connlimit --connlimit-above 8 --connlimit-mask 24 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --syn --dport 9333 -m connlimit --connlimit-above 2 -j REJECT --reject-with tcp-reset
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9333 -j ACCEPT
echo "created rules to protect from DDoS attacks"
wget https://download.litecoin.org/litecoin-0.8.7.5/linux/litecoin-0.8.7.5-linux.tar.xz
echo "downloaded litecoin 0.8.7.5"
tar xvfJ litecoin-0.8.7.5-linux.tar.xz
cd litecoin-0.8.7.5-linux/bin/64
mkdir /root/.litecoin
# echo "downloading BitTorrent Sync for bootstrap"
# echo "cd ~/watch || exit    # set your watch directory here" >> magnet.sh
# echo "[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit" >> magnet.sh
# echo "echo "d10:magnet-uri${#1}:${1}e" > "meta-${BASH_REMATCH[1]}.torrent"" >> magnet.sh
# echo "xmessage -nearmouse 'torrent added to rtorrent'" >> magnet.sh
# chmod 0755 magnet.sh
# ./magnet.sh "magnet:?xt=urn:btih:FCC23B19F4BF15E77AB668900C2B82523CC9872A"
echo "downloading bootstrap.dat making the block sync faster."
wget http://192.3.159.171/files/bootstrap/bootstrap.dat.xz -P /root/.litecoin/
cd /root/.litecoin/
echo "extracted bootstrap.dat"
echo "begining to modify litecoin.conf"
echo "creating random username and password for rpc"
rpcusername=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
rpcpass=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
echo "rpcuser=$rpcusername" >> /root/.litecoin/litecoin.conf
echo "rpcpassword=$rpcpass" >> /root/.litecoin/litecoin.conf
echo "sucessful username and passcode creation"
echo "just adding some extra things..."
echo "addnode=ltc.lurkmore.com" >> /root/.litecoin/litecoin.conf
echo "daemon=1" >> /root/.litecoin/litecoin.conf
echo "disablewallet=1" >> /root/.litecoin/litecoin.conf
echo "maxconnections=150" >> /root/.litecoin/litecoin.conf
echo "litecoin.conf has been modified"
echo "will start to run server"
./litecoind -txindex
