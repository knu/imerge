#!/bin/sh
#
# imerge - merge one file to another interactively
#
# Copyright (c) 2007 Akinori MUSHA
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# $Id$

MYNAME="$(basename "$0")"

usage () {
      echo "usage: $MYNAME source destination" >&2
      exit 1
}

do_imerge () {
    local src dest ans

    src="$1";  shift
    dest="$1"; shift

    if [ ! -f "$src" ]; then
        echo "$MYNAME: $src => $dest: Source file is not found."

        echo -n "$MYNAME: Delete destination file? (N/y): "
        read ans </dev/tty
        case "${ans:-N}" in
            [Yy]*)
                rm -f "$dest"
                ;;
        esac

        return
    fi

    if [ ! -f "$dest" ]; then
        echo "$MYNAME: $src => $dest: Destination file is not found."

        echo -n "$MYNAME: Install source file? (N/y): "
        read ans </dev/tty
        case "${ans:-N}" in
            [Yy]*)
                cp -p "$src" "$dest"
                ;;
        esac

        return
    fi

    if cmp -s "$src" "$dest"; then
        return
    fi

    diff -u "$dest" "$src" | "${PAGER:-more}"

    echo "$MYNAME: $src => $dest: Destination file differs from source file."

    echo -n "$MYNAME: Install source file, or merge source and destination files? (N/y/m): "
    read ans </dev/tty
    case "${ans:-N}" in
        [Yy]*)
            cp -p "$src" "$dest"
            return
            ;;
        [Mm]*)
            ;;
        *)
            return
            ;;
    esac

    while :; do
        sdiff -a -s -o "$dest.merged" "$src" "$dest" 2>/dev/null
        diff -u "$dest.merged" "$dest" | "${PAGER:-more}"

        echo -n "$MYNAME: Install merged file, or redo the merge? (N/y/m): "
        read ans </dev/tty
        case "${ans:-N}" in
            [Yy]*)
                cat "$dest.merged" > "$dest"
                ;;
            [Mm]*)
                continue
                ;;
        esac

        rm -f "$dest.merged"
        return
    done
}

if [ $# -ne 2 ]; then
   usage
fi

do_imerge "$@"
