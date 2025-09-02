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
  TUN <--> T2S(badvpn-tun2socks --tundev ... )
  subgraph Outline Client
    T2S <--> SC(ss-local -c outline.json ...)
  end
  SC <--> IF
  click TUN "https://en.wikipedia.org/wiki/TUN/TAP" _blank
```
