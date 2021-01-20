#!/bin/bash

for num in $(seq 1 20)
do
  declare -n REMOTE_IP="REMOTE${num}_IP"
  declare -n REMOTE_PUBKEY="REMOTE${num}_PUBKEY"
  declare -n REMOTE_TOVPN="REMOTE${num}_TOVPN"
  declare -n REMOTE_FROMVPN="REMOTE${num}_FROMVPN"
  declare -n REMOTE_ENDPOINT="REMOTE${num}_ENDPOINT"

  if [ -n "${REMOTE_IP}" -a -n "${REMOTE_PUBKEY}" ]
  then
    peers="${peers}[Peer]\nPublicKey = ${REMOTE_PUBKEY}\nAllowedIPs = ${REMOTE_IP}\n"
    if [ -n "${REMOTE_ENDPOINT}" ]
    then
      peers="${peers}EndPoint = ${REMOTE_ENDPOINT}\nPersistentKeepalive = 25"
    fi
  fi

  if [ -n "${REMOTE_IP}" -a -n "${REMOTE_TOVPN}" ]
  then
    IFS=,
    for TOVPN in ${REMOTE_TOVPN}
    do
      IFS=:
      read -r -a params <<< "$TOVPN"
      uprules="${uprules}; iptables -t nat -A PREROUTING -j DNAT -p ${params[1]} --dport ${params[0]} --to-destination ${REMOTE_IP}:${params[2]}"
      downrules="${downrules}; iptables -t nat -D PREROUTING -j DNAT -p ${params[1]} --dport ${params[0]} --to-destination ${REMOTE_IP}:${params[2]}"
    done
  fi

  if [ -n "${REMOTE_IP}" -a -n "${REMOTE_FROMVPN}" ]
  then
    IFS=,
    for FROMVPN in ${REMOTE_FROMVPN}
    do
      IFS=:
      read -r -a params <<< "$FROMVPN"
      targethost=${params[2]}
      resolved=$(getent hosts ${targethost} | awk '{print $1}')
      if [ -n "${resolved}" ]
      then
        targethost=${resolved}
      fi
      uprules="${uprules}; iptables -t nat -A PREROUTING -j DNAT -p ${params[1]} --dport ${params[0]} --to-destination ${targethost}:${params[3]}"
      downrules="${downrules}; iptables -t nat -D PREROUTING -j DNAT -p ${params[1]} --dport ${params[0]} --to-destination ${targethost}:${params[3]}"
    done
  fi
done

IFS=

exec 3>&1 4>&2 1>/etc/wireguard/wg0.conf 2>&1

echo "[Interface]"
echo "Address = ${LOCAL_IP}"
echo "ListenPort = 51820"
echo "PrivateKey = ${LOCAL_PRIVKEY}"
echo "PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -A POSTROUTING -o %i -j MASQUERADE${uprules}"
echo "PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -t nat -D POSTROUTING -o %i -j MASQUERADE${downrules}"
echo -e ${peers}

exec 1>&3 2>&4

cat /etc/wireguard/wg0.conf
wg-quick up wg0

sleep infinity &
wait
