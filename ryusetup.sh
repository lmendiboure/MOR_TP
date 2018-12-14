#Author : Ajinkya Kadam
#Email : ajinkya.kadam@nyu.edu
#Program : To install RYU SDN controller and its required dependencies

sudo apt-get update
sudo apt-get -y install git python-pip python-dev
sudo apt-get -y install python-eventlet python-routes python-webob python-paramiko
sudo apt-get -y install openvswitch-switch
git clone https://github.com/osrg/ryu.git
cd ryu/;
sudo pip install six --upgrade
sudo pip install eventlet --upgrade
sudo pip install oslo.config msgpack-python
sudo pip install -r tools/pip-requires
sudo python ./setup.py install

