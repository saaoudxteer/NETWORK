#!/bin/bash
set -e

# Supprime tun0 si elle existe (sinon ignore)
ip link del tun0 2>/dev/null || true

# Nettoie routes/voisins si besoin (optionnel)
ip neigh flush all 2>/dev/null || true
