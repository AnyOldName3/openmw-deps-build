#!/bin/bash -e

shopt -s globstar nullglob dotglob

while getopts "a:" opt; do
    case $opt in
        a ) archives+=("$OPTARG");;
    esac
done

temp_dir=""

cleanup () {
    if [[ -n $temp_dir && -d $temp_dir ]]; then
        rm -rf "$temp_dir"
        temp_dir=""
    fi
}

trap cleanup EXIT

fresh_temp () {
    cleanup
    temp_dir=$(mktemp -d)
}

process_files () {
    for sharedobject do
        echo Processing $sharedobject
        buildid=$(readelf -n "$sharedobject" | grep -oP "Build ID:\s*\K\w+")
        dest="SymStore/buildid/$buildid"
        mkdir -p "$dest"
        echo Generating $dest/debuginfo
        objcopy --only-keep-debug --compress-debug-sections "$sharedobject" "$dest/debuginfo"
        objcopy --strip-debug "$sharedobject"
    done
}

process_directory () {
    process_files $1/**/*.so
}

for i in "${archives[@]}"; do
    if [[ -f $i ]]; then
        echo File $i
        fresh_temp
        tar -xf "$i" -C "$temp_dir"
        process_directory "$temp_dir"
        rm -f "$i"
        tar -cf "$i" -C "$temp_dir" .
    elif [[ -d $i ]]; then
        echo Dir $i
        process_directory "$i"
    else
        echo $i does not exist
    fi
done
