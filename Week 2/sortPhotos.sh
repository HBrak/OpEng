#!/bin/bash

#function get folder path for file
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

#function move file to desired path
move_file() {
        file=$1
        path=$2

        mkdir -p "$path"
        cp "$file" "$path"
        newFile="$path/$(basename "$file")"

        hash_orig=$(md5sum "$file" | awk '{print $1}')
        hash_new=$(md5sum "$newFile" | awk '{print $1}')

        if [ "$hash_orig" == "$hash_new" ]; then
                echo "copy validated, copied "$file" to "$path", removing original"
                rm "$file"
                
        else
                echo "failed to move file"
                return 1
        fi
}

#main of script
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
                if [ $? -eq 0 ]; then
                        echo $newPath
                        return 1
                echoRes=$(move_file "$file" "$newPath")
                if [ $? -eq 0 ]; then
                        echo $echoRes
                        return 1
        done
        echo "moved all images"
else
        echo "Directory $directory does not exist."
        exit 1
fi
