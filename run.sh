#!/usr/bin/env bash
xinetd -f xinetd.conf -filelog /dev/stderr -dontfork
