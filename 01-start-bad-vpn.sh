sudo ip tuntap add dev tun0 mode tun user my_user
sudo ip a add 10.0.0.1/24 dev tun0
sudo ip link set dev tun0 up
sudo badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:1080
sudo ip r a 35.195.20.190 via 192.168.1.1

sudo ip r a default via 10.0.0.2 metric 10
