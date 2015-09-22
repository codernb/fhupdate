#/bin/bash

declare -A BDND

# All the excluding patterns one can think of come in here.
EXCLUDE=(

    "*.svn"
    ".DS_Store"
    
)

# Where the FH drive will be mountet.
MNTDIR=/mnt/fhnwstud/

# The target directory wherein all the dirs will be copied to.
# Will be created if not exists.
DESTDIR=~/ADS/

# The base dirs and dirs.
# To add multiple folders in the same basefolder add a new line with:
# ["relative/from/${MNTDIR}/to/basedir"]="dir1_in_basedir dir2_in_basedir dir3_in_basedir"
BDND=(

    ["E1862_Unterrichte_I/E1862_5Iv/"]="eaf apsi"
    
)

# To add a folder directly without the obscure basedir-syntax-thingy.
# But still relative to the ${MNTDIR}.
DIRS=(

    "E1862_Unterrichte_I/E1862_5iCa/esol"
    "E1862_Unterrichte_I/E1862_5Id/dnead"
    
)

# -------------- Nothing to config from here onwards --------------
#                (Except you know what you're doing)

blue=$(tput setaf 4)
green=$(tput setaf 2)
bold=$(tput bold)
normal=$(tput sgr0)
space=17

# Check if ${MNTDIR} exists
if [ ! -d ${MNTDIR} ]
then
    printf "${blue}${bold}%-${space}s${normal}%s${green}${bold}%s${normal}%s\n" "Sorry..." "Unable to mount " ${MNTDIR} " since it doesn't exist."
    exit
fi

# The mounting
printf "${blue}${bold}%-${space}s${normal}%s\n" "Mounting..." ${MNTDIR}
mount ${MNTDIR}
if [ ! "$(ls -A ${MNTDIR})" ]
then
    printf "${blue}${bold}%-${space}s${normal}%s${green}${bold}%s${normal}%s\n" "Sorry..." "Couldn't mount " ${MNTDIR} "."
    exit
fi
printf "${blue}${bold}%-${space}s${normal}%s\n" "Mounted" ${MNTDIR}

# Excluding builder
exdiff=""
exrsync=""
for ex in ${EXCLUDE[@]}
do
    exdiff+=" -x $ex"
    exrsync+=" --exclude=$ex"
    # Huehuehue, sex XD
done

# Make ${DESTDIR} if not exists
if [ ! -d ${DESTDIR} ]
then
    printf "${blue}${bold}%-${space}s${normal}%s\n" "Creating" ${DESTDIR}
    mkdir ${DESTDIR}
fi

# The copy function
copy() {
    fpat="Only in "${MNTDIR}
    if [ -d ${2} ]
    then
        diffs=$(diff -qr ${exdiff} ${1} ${2} | grep "${fpat}")
    fi
    if [ "$diffs" != "" ] 
    then
        echo "${diffs//$fpat/$(printf "${blue}${bold}%-${space}s${normal}" "Copying:")}"
        rsync -ru ${exrsync} ${1}/* ${2}
    fi
}

# Loop through ${BDND}s
printf "\n${blue}${bold}%s${normal}\n" "Looking for stuff to copy..."
for basedir in ${!BDND[@]}
do
    for dir in ${BDND[$basedir]}
    do
        copy ${MNTDIR}${basedir}${dir} ${DESTDIR}${dir}
    done
done

# Loop through ${DIRS}
for dir in ${DIRS[@]}
do
    from=${MNTDIR}${dir}
    di=$(basename ${from})
    copy ${from} ${DESTDIR}${di}
done

# The umount
printf "\n${blue}${bold}%-${space}s${normal}%s\n" "Umounting..." ${MNTDIR}
umount ${MNTDIR}
printf "${blue}${bold}%-${space}s${normal}%s\n" "Umounted" ${MNTDIR}

# Say thank you :)
printf "${blue}${bold}%-${space}s${normal}%s\n" "Thank you!" "Copy again."
