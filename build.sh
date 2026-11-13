#!/bin/sh
# Roda DENTRO de um Alpine Linux (container Docker ou máquina virtual), como root.
# Entrada:  /kit  (esta pasta, com a subpasta jogo/)
# Saída:    /out/slotos-*.iso
set -eu

KIT="${KIT:-/kit}"
OUT="${OUT:-/out}"
mkdir -p "$OUT"

[ -f "$KIT/jogo/index.html" ] || { echo "ERRO: $KIT/jogo/index.html não existe"; exit 1; }

. /etc/os-release
ALPINE_V="v${VERSION_ID%.*}"
echo ">> Alpine $ALPINE_V"

apk update
apk add --no-cache alpine-sdk alpine-conf abuild apk-tools squashfs-tools xorriso \
    syslinux mtools dosfstools grub grub-efi grub-bios git sudo busybox-static

# usuário comum (o mkimage não roda como root)
id builder >/dev/null 2>&1 || adduser -D builder
addgroup builder abuild 2>/dev/null || true
echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

# chave de assinatura dos pacotes
su builder -c "abuild-keygen -a -n"
cp /home/builder/.abuild/*.pub /etc/apk/keys/

# scripts de build do Alpine (mesma versão do sistema)
rm -rf /home/builder/aports
clone_aports() {
  for br in "${ALPINE_V#v}-stable" master; do
    for url in https://gitlab.alpinelinux.org/alpine/aports.git https://github.com/alpinelinux/aports.git; do
      for try in 1 2 3; do
        echo ">> git clone $url (branch $br) tentativa $try"
        rm -rf /home/builder/aports
        if su builder -c "git clone --depth=1 -b $br $url /home/builder/aports"; then
          [ "$br" = master ] && echo ">> AVISO: usando a branch master (a stable nao foi encontrada)"
          return 0
        fi
        sleep 10
      done
    done
  done
  return 1
}
clone_aports || { echo "ERRO: nao consegui baixar os scripts do Alpine (aports). Veja as linhas acima."; exit 1; }

# perfil SlotOS + overlay
cp "$KIT/mkimg.slotos.sh"        /home/builder/aports/scripts/
cp "$KIT/genapkovl-slotos.sh"    /home/builder/aports/scripts/
chmod +x /home/builder/aports/scripts/genapkovl-slotos.sh
chown builder /home/builder/aports/scripts/*slotos*

# jogo + arquivos do sistema visíveis ao genapkovl
rm -rf /home/builder/slotos-src
mkdir -p /home/builder/slotos-src
cp -r "$KIT/jogo"  /home/builder/slotos-src/jogo
cp "$KIT/slotgame" /home/builder/slotos-src/slotgame
chown -R builder /home/builder/slotos-src

mkdir -p /home/builder/iso-out
chown builder /home/builder/iso-out

su builder -c "cd /home/builder/aports/scripts && \
  SLOTOS_SRC=/home/builder/slotos-src sh mkimage.sh \
    --tag slotos \
    --outdir /home/builder/iso-out \
    --arch x86_64 \
    --repository https://dl-cdn.alpinelinux.org/alpine/${ALPINE_V}/main \
    --repository https://dl-cdn.alpinelinux.org/alpine/${ALPINE_V}/community \
    --profile slotos"

cp /home/builder/iso-out/*.iso "$OUT/"
echo
echo ">> PRONTO:"
ls -lh "$OUT"/*.iso
