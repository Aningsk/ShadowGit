#
# File name: link_dir.sh
# Author: Francis Schnee
# Time: 2016-08-20
helpinfo="This linux script is used to make link files from a directory."

# Default values
from_path="."
to_path="."
file_path="."

# lndir(from_path, to_path)
# Make all files link 
lndir() {
    local from=$1 
    local to=$2 
    if [ "$from" = "/" ] 
    then 
        from="" 
        # As we add "/" at follows.
    fi 
    if [ "$to" = "/" ] 
    then 
        to="" 
        # As we add "/" at follows. 
    fi 
    if [ "`ls $from | wc -w`" -eq 0 ] 
    then 
        return 
        # Directory is null, so return.
    else 
        for fname in ${from}/*
        do 
            if [ -d "$fname" ] 
            then 
                mkdir ${to}/${fname##*/}
                from_path=$fname
                to_path=${to}/${fname##*/}
                lndir $from_path $to_path
            else 
                ln $fname ${to}/${fname##*/}
            fi 
        done 
    fi 
}

# check_option
# Check command options,
# and do something (such as print @helpinfo).
check_option() {
    if [ "$1" ]
    then 
        if [ "$1" = "--help" ]
        then 
            echo -ne $helpinfo
            exit 0
        else 
            echo "Option is invalid argument!"
            exit 1
        fi 
    fi 
}

# check_path()
# Check the path whether file or directory,
# and save it in @file_path.
check_path() {
    if [ "$1" ]
    then 
        if [ -f "$1" ]
        then 
            from_path=$1
        elif [ -d "$1" ]
        then
            from_path=$1
        else 
            echo "Path is invalid argument!"
            exit 1
        fi
    else 
        echo "File path shouldn't be null!"
        exit 1
        # If path is null, exit.
    fi

    if [ "$2" ] 
    then 
        if [ -f "$2" ] 
        then 
            to_path=$2
        elif [ -d "$2" ]
        then 
            to_path=$2
        else 
            echo "Path is invalid argument!"
            exit 1
        fi 
    else 
        echo "File path shouldn't be null!"
        exit 1
        # If path is null, exit.
    fi
}

# Start:

# Check option.
if [ "$1" ]
then 
    string=$1
    # Support command options as "--?"
    if [ "${string%--*}" = "" ]
    then 
        check_options $1
    else 
        check_path $1 $2
    fi 
    # Now the option is a dir or cmd's option.
else 
    echo "Need one option or two directories."
    exit 1
    # If without any option, exit.
fi

# Remove the "/" at the end of @path.
# If @path was not end as "/", we don't change it.

# Maybe I must judge the relationship between @from_path with @to_path

tmp_str=${from_path##*/}
if [ -z "$tmp_str" ]
then 
    from_path=${from_path%/*}
    # If the @path is /, we change it back.
    if [ -z "$from_path" ] 
    then 
        from_path=/
    fi
fi

tmp_str=${to_path##*/}
if [ -z "$tmp_str" ] 
then 
    to_path=${to_path%/*} 
    # If the @path is /, we change it back.
    if [ -z "$to_path" ] 
    then 
        to_path=/
    fi 
fi 

# Main:
if [ -f "$from_path" ] && [ -f "$to_path" ] 
then 
    ln $from_path $to_path 
    exit 0
elif [ -d "$from_path" ] && [ -d "$to_path" ] 
then 
    lndir $from_path $to_path 
    exit 0
else 
    echo "Need two file or two directories."
    exit 1
fi 

