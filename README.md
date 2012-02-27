IMERGE(1)
=========

## NAME

imerge -- help merge one file to another interactively

## SYNOPSIS

```
imerge [-x diff_flags] [-X sdiff_flags] source destination
```

## DESCRIPTION

The imerge command is a utility to help merge one file to another
interactively.

If given files both exist and are identical, it silently exits without
doing anything.

If given files both exist and they differ, differences are shown using
the `diff(1)` command and user is asked if the source file should be
installed to the destination, they should be edited first, or the
source file should be merged into the destination file interactively
using the `sdiff(1)` command.

If the source file is missing, user is asked if the destination file
should be deleted.

If the destination file is missing, user is asked if the source file
should be installed to the destination.

Currently symbolic links are not supported.  If either of given files
is a symbolic link, no operation is performed.

## OPTIONS

The following command line arguments are supported:

*   `-x diff_flags`

    Set command line flags for `diff(1)` to `diff_flags`.  The default
    value is `-u`.

*   `-X sdiff_flags`

    Set extra command line flags for `sdiff(1)` to `sdiff_flags`.  The
    default value is `-a -s`.

## ENVIRONMENT

*   `EDITOR`

    Name of the editor program to run when user chooses to edit files.

*   `PAGER`

    Name of the pager program to run when showing differences.

## SEE ALSO

[`diff(1)`](http://www.freebsd.org/cgi/man.cgi?query=diff&sektion=1),
[`sdiff(1)`](http://www.freebsd.org/cgi/man.cgi?query=sdiff&sektion=1)

## HISTORY

The imerge utility was first released on 15 January, 2007.

This utility was (obviously) inspired by the
[`mergemaster`](http://www.freebsd.org/cgi/man.cgi?query=mergemaster&sektion=8)
utility of FreeBSD in hope of using part of its functionality
stand-alone.

## AUTHORS

Licensed under the 2-clause BSD license.  See `LICENSE.txt` for
details.

Visit [the GitHub repository](https://github.com/knu/imerge) for the
latest information and feedback.
