#!/bin/bash

#get folder path for file
get_new_folder_path() {
        file=$1
        when=$2
        fileDir=$(dirname "$file")
        case $when in
                "maand"|"month")
                        echo "$fileDir""/""$(date -r "$file" +%Y-%m)"
                        ;;
                "week")
                        echo "fileDir""/""$(date -r "$file" +%Y-week-%V)"
                        ;;
                *)
                echo "invalid parameter: $2 (use 'maand', 'month', 'week')"
                exit 1
                ;;
        esac
}

#move file to desired path
move_file() {
        file=$1
        path=$2

        mkdir -p "$path"
        cp "$file" "$path"
        newFile="$path/$(basename "$file")"

        echo "copied "$file" to "$path""

        hash_orig=$(md5sum "$file" | awk '{print $1}')
        hash_new=$(md5sum "$newFile" | awk '{print $1}')

        if [ "$hash_orig" == "$hash_new" ]; then
                rm "$file"
                echo "copy validated, removing original"
        else
                echo "failed to move file"
                exit 1
        fi
}

directory=$1
when=$2
if [ -d "$directory" ]; then
        for file in "$directory"/*; do
                #i prefer mime type, but this is more simple. because bash..
                fileExt="${file##*.}"
                if [[ ! "$fileExt" =~ ^(jpg|jpeg|png)$ ]]; then
                        echo "skipping "$file", is not a known image format"
                        continue
                fi
                newPath=$(get_new_folder_path "$file" "$when")
                move_file "$file" "$newPath"
        done
        echo "moved all images"
else
        echo "Directory $directory does not exist."
        exit 1
fi
