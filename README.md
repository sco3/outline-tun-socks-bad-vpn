# Life of a Packet

```mermaid
flowchart LR
  A(Apps) <--> S(Socket)
  subgraph Operating System
    S <--> R(Routing Table)
  end
  R <-- TUN Route OFF --> IF(Network Interface)
  IF <--> INET(((Internet)))
  R <-- TUN Route ON --> TUN(Tun Device)
  TUN <--> T2S(badvpn-tun2socks)
  subgraph Outline Client
    T2S <--> SC(ss-local -c outline.json -f /var/run/ss-local.pid)
  end
  SC <--> IF
  click TUN "https://en.wikipedia.org/wiki/TUN/TAP" _blank
```
