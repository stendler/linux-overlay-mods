#!/bin/sh

# Params
# $1 - Path containing /mods to mount and possibly configurations
# $2 - (game) directory to overlay on top
# maybe later also /profiles or loadouts with symlinks into /mods named for proper ordering (with $2 specifying the loadout/profile name)
#

function debug() {
    case "$DEBUG" in
        1|[tT]rue|[yY]|[yY]es) echo "$1" >&2; ;;
    esac
}

export DEBUG=1

OPTS=$(getopt --options w --longoptions writable -- "$@")
eval set -- "$OPTS"
while true; do
    case "$1" in
        -w|--writable)
            OVERLAY_MODS_WRITABLE=1
            shift ;;
        --) shift; break ;;
    esac
done


if [ -z "$1" ]; then
 echo "Game modding folder needs to be provided." >&2
 exit 1
fi


if [ -z "$2" ]; then
 echo "Folder to overlay needs to be provided." >&2
 exit 1
fi

modding_dir=$(realpath --quiet --no-symlinks "$1")
debug "Using directory: $modding_dir"

overlay_dir=$(realpath --quiet --no-symlinks "$2")
debug "Overlaying directory: $overlay_dir"

case "$OVERLAY_MODS_WRITABLE" in
        1|[tT]rue|[yY]|[yY]es)
        basepath=$(dirname "$modding_dir")
        basename=$(basename "$modding_dir")
        upperdirname="$basepath/.$basename.upper"
        workingdirname="$basepath/.workingdir_$basename"
        mkdir -p "$upperdirname" "$workingdirname"
        opts_writable=",userxattr,upperdir=$upperdirname,workdir=$workingdirname"
        ;;
esac

# get all lower dirs to mount - colon-separated
layers=$(find "$modding_dir" -maxdepth 1 -mindepth 1 -type d -exec echo -n {}: \; | sed "s/:$//")

debug "Layers: $layers"

# don't mount again if already mounted
if ! mountpoint --quiet "$overlay_dir" ; then

    set -x
    sudo mount --type overlay overlay --options "defaults,auto,noatime,exec,lowerdir=$layers:$overlay_dir$opts_writable" "$overlay_dir"

    result=$?
    set +x
    if [ ! $result -eq 0 ]; then
        debug "mount error code: $result"
        exit $result
    fi
    # overlayfs does not work on filesystems with casefolding active, which might be an issue with wine/proton directories and windows apps...
    # check if the filesystem has it active: `sudo tune2fs -l /dev/my-device`
    # To see which directories have the flag set: `sudo lsattr -R -a /path/to/device/mountpoint 2>/dev/null | grep "\-*F\-* "`
    # it might not be possible to remove without removing data.. use a different filesystem/partition instead!
    # to remove the flag from all of these directories: `sudo chattr -Rf -F /path/to/device/mountpoint`
    # (that did not really work, so:)
    # `sudo lsattr -R -a /path/to/device/mountpoint 2>/dev/null | grep "\-*F\-* " | sed '/\.$/d' | awk '{print $2}' | xargs -n 1 sudo chattr -f -F`
    # to remove the functionality from the filesystem
    #

else
    debug "Overlay already mounted."
fi

ls -l "$overlay_dir"


#sudo umount "$overlay_dir"
