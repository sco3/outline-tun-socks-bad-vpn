pkill -9 ss-local
ss-local -c outline.json  -f ~/.local/ss-local.pid


curl --socks5 127.0.0.1:1080 myip.wtf