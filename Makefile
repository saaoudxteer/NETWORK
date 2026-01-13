
---

## Makefile (à la racine)

> Remarque : ce Makefile pilote Vagrant **en entrant dans les bons dossiers**, et lance tes scripts `/vagrant/script/net/*.sh`. Il ajoute aussi des cibles tunnel et tests.

```makefile
SHELL := /bin/bash
.ONESHELL:
.DEFAULT_GOAL := help

# ---------- Dossiers Vagrant ----------
VM1_DIR   := VM/VM1
VM2_DIR   := VM/VM2
VM3_DIR   := VM/VM3
VM1_6_DIR := VM-6/VM1-6
VM2_6_DIR := VM-6/VM2-6
VM3_6_DIR := VM-6/VM3-6

# ---------- IPs / params tunnel (adapte si besoin) ----------
IP_VM1      := 172.16.2.151
IP_VM3      := 172.16.2.183
IP_VM1_6_V6  := fc00:1234:1::16
IP_VM3_6_V6  := fc00:1234:2::36
TUN_PORT    := 123

LAN3_NET    := 172.16.2.144/28
LAN4_NET    := 172.16.2.176/28

# IPv4 point-à-point pour tun0 (évite chevauchements)
TUN1_ADDR   := 10.200.0.1/30
TUN2_ADDR   := 10.200.0.2/30

ECHO_PORT   := 12345
ECHO_MSG    := HELLO_TUNNEL

# ---------- Helpers ----------
define vup
	cd $(1) && vagrant up
endef

define vhalt
	cd $(1) && vagrant halt -f || true
endef

define vssh
	cd $(1) && vagrant ssh -c "$(2)"
endef

define vssh_sudo
	cd $(1) && vagrant ssh -c "sudo -s <<'EOS'\nset -e\n$(2)\nEOS"
endef

.PHONY: help
help:
	@echo "Targets:"
	@echo "  up           - Démarre toutes les VMs"
	@echo "  halt         - Stop toutes les VMs"
	@echo "  destroy      - Détruit toutes les VMs (vagrant destroy -f)"
	@echo "  net          - Applique scripts script/net (addr + routes)"
	@echo "  vm2-down     - Coupe VM2 (panne)"
	@echo "  tunnel-start - Lance tunnel46d (VM3-6 listen, VM1-6 connect)"
	@echo "  tun-config   - Configure tun0 + routes LAN3/LAN4 via tun0"
	@echo "  tunnel-stop  - Stop tunnel46d + supprime tun0"
	@echo "  test-l3      - Ping VM1 -> VM3 (couhe 3)"
	@echo "  test-l4      - Test TCP HELLO_TUNNEL vers VM3:12345"
	@echo "  test-iperf   - iperf3 (10,2K,128K,1M)"
	@echo "  show-routes  - Affiche ip addr/ip route sur VMs clés"
	@echo "  tunnel-logs  - Affiche /tmp/tunnel46d.log sur VM1-6 et VM3-6"
	@echo "  demo         - Lance script/demo/demo.sh si présent"

.PHONY: up
up:
	$(call vup,$(VM1_DIR))
	$(call vup,$(VM2_DIR))
	$(call vup,$(VM3_DIR))
	$(call vup,$(VM1_6_DIR))
	$(call vup,$(VM2_6_DIR))
	$(call vup,$(VM3_6_DIR))

.PHONY: halt
halt:
	$(call vhalt,$(VM1_DIR))
	$(call vhalt,$(VM2_DIR))
	$(call vhalt,$(VM3_DIR))
	$(call vhalt,$(VM1_6_DIR))
	$(call vhalt,$(VM2_6_DIR))
	$(call vhalt,$(VM3_6_DIR))

.PHONY: destroy
destroy:
	cd $(VM1_DIR)   && vagrant destroy -f || true
	cd $(VM2_DIR)   && vagrant destroy -f || true
	cd $(VM3_DIR)   && vagrant destroy -f || true
	cd $(VM1_6_DIR) && vagrant destroy -f || true
	cd $(VM2_6_DIR) && vagrant destroy -f || true
	cd $(VM3_6_DIR) && vagrant destroy -f || true

.PHONY: net
net:
	# Nettoyage interfaces si script présent
	$(call vssh_sudo,$(VM1_DIR),  "[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")
	$(call vssh_sudo,$(VM2_DIR),  "[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")
	$(call vssh_sudo,$(VM3_DIR),  "[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")
	$(call vssh_sudo,$(VM1_6_DIR),"[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")
	$(call vssh_sudo,$(VM2_6_DIR),"[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")
	$(call vssh_sudo,$(VM3_6_DIR),"[ -x /vagrant/script/net/clean_eth.sh ] && /vagrant/script/net/clean_eth.sh || true")

	# addr/routes
	$(call vssh_sudo,$(VM1_DIR),  "/vagrant/script/net/vm1_addr.sh && /vagrant/script/net/vm1_routes.sh")
	$(call vssh_sudo,$(VM2_DIR),  "/vagrant/script/net/vm2_addr.sh && /vagrant/script/net/vm2_routes.sh")
	$(call vssh_sudo,$(VM3_DIR),  "/vagrant/script/net/vm3_addr.sh && /vagrant/script/net/vm3_routes.sh")

	$(call vssh_sudo,$(VM1_6_DIR),"/vagrant/script/net/vm1-6_addr.sh; /vagrant/script/net/vm1-6_routes_v4.sh 2>/dev/null || true; /vagrant/script/net/vm1-6_routes.sh 2>/dev/null || true")
	$(call vssh_sudo,$(VM2_6_DIR),"/vagrant/script/net/vm2-6_addr.sh")
	$(call vssh_sudo,$(VM3_6_DIR),"/vagrant/script/net/vm3-6_addr.sh; /vagrant/script/net/vm3-6_routes.sh 2>/dev/null || true")

.PHONY: vm2-down
vm2-down:
	$(call vhalt,$(VM2_DIR))

.PHONY: tunnel-start
tunnel-start:
	# Important: tunnel46d crée tun0 via /dev/net/tun -> ne pas pré-créer tun0.
	$(call vssh_sudo,$(VM3_6_DIR),\
		"pkill -f tunnel46d.py 2>/dev/null || true; ip link del tun0 2>/dev/null || true; modprobe tun 2>/dev/null || true; \
		 nohup python3 -u /vagrant/src/extremite/tunnel46d.py listen $(TUN_PORT) > /tmp/tunnel46d.log 2>&1 & echo $$! > /tmp/tunnel46d.pid; sleep 0.5; tail -n 5 /tmp/tunnel46d.log || true")
	$(call vssh_sudo,$(VM1_6_DIR),\
		"pkill -f tunnel46d.py 2>/dev/null || true; ip link del tun0 2>/dev/null || true; modprobe tun 2>/dev/null || true; \
		 nohup python3 -u /vagrant/src/extremite/tunnel46d.py connect $(IP_VM3_6_V6) $(TUN_PORT) > /tmp/tunnel46d.log 2>&1 & echo $$! > /tmp/tunnel46d.pid; sleep 0.5; tail -n 5 /tmp/tunnel46d.log || true")

.PHONY: tun-config
tun-config:
	# Attend tun0 puis configure IP + routes LAN3/LAN4 via tun0
	$(call vssh_sudo,$(VM1_6_DIR),\
		"for i in $$(seq 1 40); do ip link show tun0 >/dev/null 2>&1 && break; sleep 0.2; done; \
		 ip link show tun0 >/dev/null 2>&1 || (echo 'tun0 missing (VM1-6)' && tail -n 80 /tmp/tunnel46d.log && exit 1); \
		 ip addr flush dev tun0 || true; ip addr add $(TUN1_ADDR) dev tun0; ip link set tun0 up; \
		 ip route replace $(LAN4_NET) dev tun0")
	$(call vssh_sudo,$(VM3_6_DIR),\
		"for i in $$(seq 1 40); do ip link show tun0 >/dev/null 2>&1 && break; sleep 0.2; done; \
		 ip link show tun0 >/dev/null 2>&1 || (echo 'tun0 missing (VM3-6)' && tail -n 80 /tmp/tunnel46d.log && exit 1); \
		 ip addr flush dev tun0 || true; ip addr add $(TUN2_ADDR) dev tun0; ip link set tun0 up; \
		 ip route replace $(LAN3_NET) dev tun0")

.PHONY: tunnel-stop
tunnel-stop:
	$(call vssh_sudo,$(VM1_6_DIR),"pkill -f tunnel46d.py 2>/dev/null || true; ip link del tun0 2>/dev/null || true")
	$(call vssh_sudo,$(VM3_6_DIR),"pkill -f tunnel46d.py 2>/dev/null || true; ip link del tun0 2>/dev/null || true")

.PHONY: test-l3
test-l3:
	$(call vssh,$(VM1_DIR),"ping -c 2 $(IP_VM3) || true")

.PHONY: test-l4
test-l4:
	# Serveur sur VM3 (port 12345), client depuis VM1
	$(call vssh_sudo,$(VM3_DIR),\
		"pkill -f \"python3 -u -\" 2>/dev/null || true; rm -f /tmp/echo_recv.txt /tmp/echo_srv.log; \
		 nohup python3 -u - <<'PY' > /tmp/echo_srv.log 2>&1 & \
import socket\ns=socket.socket(socket.AF_INET,socket.SOCK_STREAM)\ns.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1)\ns.bind(('0.0.0.0',$(ECHO_PORT)))\ns.listen(1)\nc,a=s.accept()\ndata=c.recv(4096)\nopen('/tmp/echo_recv.txt','wb').write(data)\nprint('client:',a,flush=True)\nprint('RECU:',data.decode(errors='replace'),flush=True)\nPY \
		 sleep 0.5; ss -lntp | grep :$(ECHO_PORT) || true")
	$(call vssh,$(VM1_DIR),"printf \"$(ECHO_MSG)\n\" | nc -n $(IP_VM3) $(ECHO_PORT) || true")
	$(call vssh,$(VM3_DIR),"echo '--- received ---'; cat /tmp/echo_recv.txt || true; echo; tail -n 20 /tmp/echo_srv.log || true")

.PHONY: test-iperf
test-iperf:
	$(call vssh_sudo,$(VM3_DIR),"pkill -f \"iperf3 -s\" 2>/dev/null || true; nohup iperf3 -s > /tmp/iperf3_srv.log 2>&1 & sleep 0.5; ss -lntp | grep :5201 || true")
	$(call vssh,$(VM1_DIR),"iperf3 -c $(IP_VM3) -n 1 -l 10   || true")
	$(call vssh,$(VM1_DIR),"iperf3 -c $(IP_VM3) -n 1 -l 2K   || true")
	$(call vssh,$(VM1_DIR),"iperf3 -c $(IP_VM3) -n 1 -l 128K || true")
	$(call vssh,$(VM1_DIR),"iperf3 -c $(IP_VM3) -n 1 -l 1M   || true")

.PHONY: show-routes
show-routes:
	$(call vssh,$(VM1_DIR),"ip -br a; echo '---'; ip r")
	$(call vssh,$(VM3_DIR),"ip -br a; echo '---'; ip r")
	$(call vssh,$(VM1_6_DIR),"ip -br a; echo '---'; ip r")
	$(call vssh,$(VM3_6_DIR),"ip -br a; echo '---'; ip r")

.PHONY: tunnel-logs
tunnel-logs:
	$(call vssh,$(VM1_6_DIR),"echo '=== VM1-6 ==='; tail -n 80 /tmp/tunnel46d.log || true")
	$(call vssh,$(VM3_6_DIR),"echo '=== VM3-6 ==='; tail -n 80 /tmp/tunnel46d.log || true")

.PHONY: demo
demo:
	@if [ -x script/demo/demo.sh ]; then \
		bash script/demo/demo.sh; \
	else \
		echo "script/demo/demo.sh introuvable ou non exécutable."; \
		echo "Crée-le puis: chmod +x script/demo/demo.sh"; \
	fi
