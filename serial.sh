#!/bin/sh
echo "1.Leave this running in the background,\n2.Run fs-uae with --serial-port=/tmp/vser at the end"
echo "3.On another terminal go type cat /tmp/hser"
echo "4.Use redirection from Amiga-side e.g. yourexe >ser: and all your stdout (printfs etc) will appear on linux"
OPTS=raw,echo=0,onlcr=0,echoctl=0,echoke=0,echoe=0,iexten=0
exec socat "$@" pty,$OPTS,link=/tmp/vser pty,$OPTS,link=/tmp/hser
