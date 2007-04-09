#!/bin/sh
#
# imerge - help merge one file to another interactively
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
#
# The latest version of this script can be downloaded from a read-only
# subversion repository available at the following URL:
#
#     http://svn.idaemons.org/repos/imerge/
#
# Typically you just want the trunk/ subdirectory out of the whole
# source tree including all the past release snapshots and so on.
#
# $Id$

MYNAME="$(basename "$0")"
VERSION="0.2.1"

# workaround for ksh not having "local"
__f__ () { local __x__; }; eval __f__ 2>/dev/null || local () { for __x__; do case "$__x__" in *=*) $__x__ ;; esac; done }; unset __f__ __x__

usage () {
    {
        echo "imerge version $VERSION - help merge one file to another interactively"
        echo "usage: $MYNAME [ -x diff_flags ] [ -X sdiff_flags ] source destination"
    } >&2
    exit 1
}

call_diff () {
    diff ${DIFF_FLAGS} "$@"
}

call_sdiff () {
    sdiff ${SDIFF_FLAGS} "$@"
}

do_imerge () {
    local src dest merged ans

    src="$1";  shift
    dest="$1"; shift

    if [ -L "$src" ]; then
        echo "$MYNAME: $src => $dest: Source file is a symlink."
        return
    fi

    if [ -L "$dest" ]; then
        echo "$MYNAME: $src => $dest: Destination file is a symlink."
        return
    fi

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

    while :; do
        call_diff "$dest" "$src" | "${PAGER:-more}"

        echo "$MYNAME: $src => $dest: Destination file differs from source file."

        echo -n "$MYNAME: Install source file, edit files, or merge them? (N/y/e/m): "
        read ans </dev/tty
        case "${ans:-N}" in
            [Yy]*)
                cp -p "$src" "$dest"
                return
                ;;
            [Ee]*)
                "$EDITOR" "$src" "$dest"
                ;;
            [Mm]*)
                break
                ;;
            *)
                return
                ;;
        esac
    done

    merged="$(mktemp "$dest.merged.XXXXXX")"

    finalize () {
        rm -f "$merged"
    }

    trap "finalize; exit 130" 1 2 3 15

    call_sdiff -o "$merged" "$src" "$dest"

    while :; do
        call_diff "$dest" "$merged" | "${PAGER:-more}"

        echo -n "$MYNAME: Install merged file, edit files, or redo the merge? (N/y/e/m): "
        read ans </dev/tty
        case "${ans:-N}" in
            [Yy]*)
                cat "$merged" > "$dest"
                ;;
            [Ee]*)
                "$EDITOR" "$src" "$dest" "$merged"
                continue
                ;;
            [Mm]*)
                call_sdiff -o "$merged" "$src" "$dest"
                continue
                ;;
        esac

        finalize
        return
    done
}

DIFF_FLAGS="-u"
SDIFF_FLAGS="-a -s"

while getopts x:X: o; do
    case "$o" in
        x)
            DIFF_FLAGS="$OPTARG"
            ;;
        X)
            SDIFF_FLAGS="$OPTARG"
            ;;
        \?)
            usage
            ;;
    esac
done

shift $(($OPTIND - 1))

if [ $# -ne 2 ]; then
   usage
fi

do_imerge "$@"
