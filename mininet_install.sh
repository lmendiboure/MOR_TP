https://github.com/lmendiboure/mininet.git

mkdir mininet/mininet_build

./mininet/util/install.sh -s mininet/mininet_build -a 

# Note : if a server is unreachable ("Cloning...") you will maybe need to replace two lines in the install.sh file :
# line 200 :     git clone git://github.com/mininet/openflow =>     git clone https://github.com/mininet/openflow.git
# line588 :     git clone git://github.com/floodlight/oftest =>      git clone https://github.com/floodlight/oftest.git

sudo mn --test pingall
