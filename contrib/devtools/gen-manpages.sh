#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DalcoinD=${DalcoinD:-$SRCDIR/Dalcoind}
DalcoinCLI=${DalcoinCLI:-$SRCDIR/Dalcoin-cli}
DalcoinTX=${DalcoinTX:-$SRCDIR/Dalcoin-tx}
DalcoinQT=${DalcoinQT:-$SRCDIR/qt/Dalcoin-qt}

[ ! -x $DalcoinD ] && echo "$DalcoinD not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
DALVER=($($DalcoinCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$DalcoinD --version | sed -n '1!p' >> footer.h2m

for cmd in $DalcoinD $DalcoinCLI $DalcoinTX $DalcoinQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${DALVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${DALVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
