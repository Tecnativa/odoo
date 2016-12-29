#!/bin/sh
set -ex

# Get the list of good folders
list=/opt/odoo/custom/addons.txt

# Know if a directory should be preserved
function preserve () {
    dir=$(basename $1)

    # To preserve it, it must be a directory
    if [ ! -d $dir ]; then
        exit 1
    # Check folder traversal level
    elif [ $(pwd) == /opt/odoo/custom ]; then
        if [ $dir == "private" -o $dir == "odoo" ]; then
            exit 1
        fi
    else
        # The found path should include the repo
        parent=$(basename $(pwd))
        # Special case for "repo-name/*": all level 2 folders are preserved
        if grep -E "^$parent/*" $file; then
            exit 0
        fi
        dir=$parent/$dir
    fi

    # If the path is found in list, it is preserved
    grep -E "^$dir(\/|$)" $file || exit 1
}

# Check if the build should be cleaned
if [ "$CLEAN" == yes ]; then
    if [ -f $list ]; then
        folders=$(cat $list)
    fi
    cd /opt/odoo/custom/src
    # Remove git stuff, which usually grows a lot
    find -name '.git*' -exec rm -Rf {} +
    # Enter each repo
    for repo in * .[^.]*; do
        # Delete the repo if it is not used
        if ! preserve $repo; then
            rm -Rf $repo
        else
            cd $repo
            # Check each repo addon
            for addon in * .[^.]*; do
                # Delete the addon if it is not used
                if ! preserve $addon; then
                    rm -Rf $addon
                fi
            done
            cd ..
        fi
    done
fi
