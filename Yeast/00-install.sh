#!/bin/sh -e

##########################################################################
#   Description:
#       Install the rna-seq meta-{port|package}
##########################################################################

usage()
{
    printf "Usage: $0\n"
    exit 64     # sysexits(3) EX_USAGE
}


##########################################################################
#   Function description:
#       Pause until user presses return
##########################################################################

pause()
{
    local junk
    
    printf "Press return to continue..."
    read junk
}


##########################################################################
#   Function description:
#       Install dreckly and the rna-seq meta-package
##########################################################################

dreckly_install()
{
    if auto-dreckly-dir; then
        cd $(auto-dreckly-dir)/biology/rna-seq && bmake install
    else
        curl -O https://raw.githubusercontent.com/outpaddling/auto-admin/refs/heads/master/User-scripts/auto-dreckly-setup
        chmod 755 auto-dreckly-setup
        cat << EOM

Running auto-dreckly-setup.  After the dreckly setup completes, you will
be presented a menu for software installation.  Choose

    Install port/package from source

and then enter

    biology/rna-seq
    
EOM
        pause
        ./auto-dreckly-setup
    fi
    return 0
}


##########################################################################
#   Main
##########################################################################

if [ $# != 0 ]; then
    usage
fi

if [ $(uname) = FreeBSD ]; then
    if [ $(id -u) = 0 ]; then
	pkg install -y rna-seq
    else
	cat << EOM

You are running FreeBSD, but not running $0 as the
superuser (root).

If you run $0 as root, software installation will be much
faster and simpler, as it can use the official binary packages from
the FreeBSD ports system.

If you run $0 as an $(id -un), as you are now, we will attempt
to install all of the software in your own directory using the dreckly
package manager, which will take a long time.

EOM
	printf "Continue to install as $(id -un)? y/[n] "
	read continue
	if [ 0"$continue" = 0y ]; then
	    dreckly_install
	fi
    fi
else
    dreckly_install
fi
