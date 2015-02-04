sudo su
echo "updating server"
apt-get update upgrade
echo "getting front-side package for iptable"
apt-get install ufw
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
echo "downloading bootstrap.dat making the block sync faster."
wget http://192.3.159.171/files/bootstrap/bootstrap.dat.xz -P /root/.litecoin/
cd /root/.litecoin/
xz -d bootstrap.dat.xz
echo "extracted bootstrap.dat"
echo "begining to modify litecoin.conf"
echo "creating random username and passwork for rpc"
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
echo "now rebooting setup will continue in a minuite"
reboot