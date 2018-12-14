git clone git://github.com/mininet/mininet

mkdir mininet/mininet_build

mininet/util/install.sh -s mininet/mininet_build -a 

sudo mn --test pingall
