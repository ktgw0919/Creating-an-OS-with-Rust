#!/bin/bash -e

# ビルドしたファイルを'/EFI/BOOT/BOOTX64.EFI'に配置
PROJ_ROOT="$(dirname $(dirname ${BASH_SOURCE:-$0}))"
cd "${PROJ_ROOT}"
PATH_TO_EFI="$1"
rm -rf mnt
mkdir -p mnt/EFI/BOOT/
cp ${PATH_TO_EFI} mnt/EFI/BOOT/BOOTX64.EFI

# QEMUの起動
set +e # エラー時に即停止をオフにする
mkdir -p log
qemu-system-x86_64 \
  -m 4G \
  -bios third_party/ovmf/RELEASEX64_OVMF.fd \
  -drive format=raw,file=fat:rw:mnt \
  -chardev stdio,id=char_com1,mux=on,logfile=log/com1.txt \
  -serial chardev:char_com1 \
  -device isa-debug-exit,iobase=0xf4,iosize=0x01
RETCODE=$? # 終了コードを保持
set -e

# 結果の判定
if [ $RETCODE -eq 0 ]; then
  exit 0
elif [ $RETCODE -eq 3 ]; then
  printf "\nPASS\n"
  exit 0
else
  printf "\nFAIL: QEMU retuened $RETCODE\n"
  exit 1
fi
