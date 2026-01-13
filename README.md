# Projet Réseaux — Tunnel IPv4 sur TCP/IPv6

Ce projet met en place un **tunnel IPv4 encapsulé dans un flux TCP transporté sur IPv6** afin de restaurer la connectivité entre deux LAN IPv4 lorsque **VM2 est hors service**. :contentReference[oaicite:1]{index=1}

## Objectif (résumé)
- VM2 est arrêtée ⇒ VM1 ne peut plus joindre VM3 en IPv4 directement. :contentReference[oaicite:2]{index=2}
- On encapsule les paquets IPv4 via une interface **TUN** et on les transporte dans un **TCP/IPv6** entre **VM1-6** et **VM3-6** (extrémités du tunnel). :contentReference[oaicite:3]{index=3}
- On valide :
  - Couche 3 : `ping VM1 -> VM3` :contentReference[oaicite:4]{index=4}
  - Couche 4 : envoi d’un message TCP (ex: `HELLO_TUNNEL`) :contentReference[oaicite:5]{index=5}
  - Couche 4 débit : `iperf3` avec tailles 10, 2K, 128K, 1M :contentReference[oaicite:6]{index=6}

## Plan d’adressage (extrait)
- VM1 : `172.16.2.151/28` (LAN3)
- VM3 : `172.16.2.183/28` (LAN4)
- VM1-6 : `172.16.2.156/28` (LAN3) + IPv6 `fc00:1234:1::16`
- VM3-6 : `172.16.2.186/28` (LAN4) + IPv6 `fc00:1234:2::36` :contentReference[oaicite:7]{index=7}

## Structure du dépôt
- `src/` : code Python (iftun, extremite, tunnel46d…)
- `script/net/` : scripts d’adressage + routage
- `VM/` et `VM-6/` : environnements Vagrant des machines
- `docs/` : captures / images
- `captures/` : (optionnel) logs de démo, pcap, screenshots
- `Makefile` : commandes standardisées

## Pré-requis (machine hôte)
- VirtualBox + Vagrant
- GNU Make
- Python 3 (dans les VMs)
- Outils dans les VMs : `iproute2`, `tcpdump`, `iperf3`, `netcat` (ou `nc`)


## Démarrage rapide

### 1) Démarrer toutes les VMs
```bash
make up
