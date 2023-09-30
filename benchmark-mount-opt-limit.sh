#!/bin/bash

# script to find out the maximum length for mount options with overlayfs
# usually 4096 but may be significantly smaller within containers


# run in subshell so change directory is not applied to executing shell
echo $(
# create a temporary dir in /tmp for further creations of dirs to mount
tmp_root=$(mktemp --directory --tmpdir=/tmp mount-opt-limit-bench.XXXXXXXXXXX)
echo "temp root: $tmp_root" >&2
mkdir -p "$tmp_root/target" # mount target
: ${mount_step:=63}
count=$((9 + $mount_step)) # lowerdir=dir:dir

function get_name() {
    # return a string of length $1
    curr=""
    for i in $(seq 1 "$1"); do
        curr=X$curr
    done
    echo $curr
}

function get_template() {
    # return a mktemp template of length $1
    echo "XXX$(get_name $(($1 - 3)))" # minimum for mktemp
}

function overlay_mount() {
    sudo mount --type overlay overlay --options "lowerdir=$1" "target" 2>/dev/null
    return $?
}

cd "$tmp_root"
lower_dirs="$(basename $(mktemp --directory --tmpdir="$tmp_root" $(get_template $mount_step)))"
current_dir="$(basename $(mktemp --directory --tmpdir="$tmp_root" $(get_template $mount_step)))"
mktemp --tmpdir="$tmp_root/$current_dir" >/dev/null

echo "$lower_dirs:$current_dir" >&2

while overlay_mount "$lower_dirs:$current_dir" ; do
    lower_dirs="$lower_dirs:$current_dir"
    current_dir="$(basename $(mktemp --directory --tmpdir="$tmp_root" $(get_template $mount_step)))"
    mktemp --tmpdir="$tmp_root/$current_dir" >/dev/null
    count=$(($count + 1 + $mount_step)) # $lower_dirs:dir
    sudo umount "$tmp_root/target"
done

echo "Limit overreached at $(($count + 1 + $mount_step))" >&2

until overlay_mount "$lower_dirs:$current_dir"; do
    mount_step=$(($mount_step - 1))
    echo "count=$count mount_step=$mount_step" >&2
    current_dir="$(get_name $mount_step)"
    if [ -z "$current_dir" ]; then
        echo "Aborted... at lowerdir=$lower_dirs" >&2
        break
    fi

    mkdir -p "$tmp_root/$current_dir"
    mktemp --tmpdir="$tmp_root/$current_dir" >/dev/null
done

echo "Mount options limit reached at:" >&2
echo "$((1 + $count + $mount_step + 1))"

sudo umount "$tmp_root/target"

# cleanup
rm -rf "$tmp_root"
)
