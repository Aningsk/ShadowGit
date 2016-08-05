#
#File name: cksum_dir.sh
#Author: Shengkun.ning
#Time: 2015-01-20
helpinfo="This linux script is used to get files' checksum in a directory.\n
You can use it as follows:\n
\t./chsum_dir.sh Option1 Option2\n
Options are directory path and command option without consideration of their order.\n
Now support command options are:\n
\t-R\tget all checksum in the path as recursion.\n
\t--help\tget help information.\n
And you can use one option or not use any option.\n
The option is regard as default valuse, while it is not point out by user.\n
Directory Path Default as ./\n
Command Option Default as no-recursion\n"

#Default values
file_path="."
recursion="no"

#ckdir(path)
#Get all files' checksum in the @path.
#And we support recursion of all sub-directories.
ckdir() {
    local path=$1
    if [ "$path" = "/" ]
    then 
        path=""
        #As we add "/" at follows.
    fi
    if [ "`ls $path | wc -w`" -eq 0 ]
    then 
        return
        #Directory is null, so return.
    else
        for fname in ${path}/*
        do 
            if [ -d "$fname" ]
            then 
                if [ "$recursion" = "yes" ]
                then 
                    file_path=$fname
                    ckdir $file_path
                else
                    echo "$fname is a directory." 1>&2
                    #We use 1>&2, in order the result can be print out
                    #as soon as possible.
                fi
            else
                cksum $fname 1>&2
            fi
        done
    fi
}

#check_options(opt)
#Check command options,
#and update mark (such as @recursion),
#or do something (such as print @helpinfo).
check_options() {
    if [ "$1" ]
    then 
        if [ "$1" = "-R" ]
        then 
            recursion="yes"
        elif [ "$1" = "--help" ]
        then
            echo -ne $helpinfo
            exit 0
        else
            echo "Option is invalid argument!"
            exit 1
        fi
    fi
    #If @opt is null, we will ignore it,
    #and default values in @recursion won't be changed.
}

#check_path(path)
#Check the path whether file or directory,
#and save it in @file_path.
check_path() {
    if [ "$1" ]
    then 
        if [ -f "$1" ]
        then 
            file_path=$1
        elif [ -d "$1" ]
        then
            file_path=$1
        else
            echo "Path is invalid argument!"
            exit 1
        fi
    fi
    #If @path is null, we will ignore it,
    #and default values in @file_path won't be changed.
}

#Start:

#Check options.
if [ "$1" ] 
then 
    string=$1
    #Support command options as "-?" or "--?"
    if [ "${string%-*}" = "" ] || [ "${string%--*}" = "" ]
    then
        check_options $1
        check_path $2
    else
        check_options $2
        check_path $1
    fi
    #Users don't care about the order of options.
fi
#If without option(s), we will take default values.

#Remove the "/" at the end of @file_path.
#If @file_path was not end as "/", we don't change it.
tmp_str=${file_path##*/}
if [ -z "$tmp_str" ]
then 
    file_path=${file_path%/*}
    #If the @file_path is /, we change it back.
    if [ -z "$file_path" ]
    then 
        file_path=/
    fi
fi

#Main:
if [ -f "$file_path" ]
then 
    cksum $file_path
    exit 0
elif [ -d "$file_path" ]
then 
    ckdir $file_path
    exit 0
else 
    echo "Panic! (In fact, system could never run here.)"
    exit 1
fi

