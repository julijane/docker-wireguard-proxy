docker-wireguard-proxy
======================

A docker image which creates a wireguard VPN connection and allows to tunnel
UDP and TCP connections over the VPN. It is mainly intended to be used as
a kind of reverse proxy and could be used for example as an alternative to
ngrok and similar services.

See [examples](examples) for a example configuration of server and client
setup using docker-compose.

The possibilities are endless :)

    docker pull ghcr.io/julijane/wireguard-proxy

---

How to generate keys:

    PRIV=$(wg genkey) ; echo "PRIVKEY: $PRIV" ; echo -n "PUBKEY: " ; echo "$PRIV" | wg pubkey

Example output:

    PRIVKEY: OJKD4dh02rCSuu6rcNbuNcKWFNaQkIrF7MrTdYJbYmM=
    PUBKEY: 9ji06NkIiZprRUA9TQfx0sv4W3q7lHcStsr12dQsiiY=

---

Configuration/ Environment variables:

*   **LOCAL_IP**

    Our VPN-IP

*   **LOCAL_PRIVKEY**

    Our private key

You can configure up to 20 peers, replace n with a number from 1 to 20:

*   **REMOTEn_PUBKEY**

    Public key of the peer

*   **REMOTEn_IP**

    Peer VPN-IP

*   **REMOTEn_ENDPOINT**

    Only on client: Specify hostname/ip and port where to connect to


Port forwardings are configured as following:


On the forwarding side:

*   **REMOTEn_TOVPN**

    Provide a comma separated list of specifications. Each specification consists of
    3 tuples separated by colons.

    Example: ```7000:tcp:7000```
    Forward local TCP connections incoming on port 7000 to port 7000 on the peer


On the receiving side:

*   **REMOTEn_FROMVPN**

    Provide a comma separated list of specifications.Each specification consists of
    4 tuples separated by colons.

    Example: ```7000:tcp:whoami:80```
    Forward TCP connections incoming from the other VPN side on port 7000 to
    server whoami on port 80
