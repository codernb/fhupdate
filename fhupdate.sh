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

exdiff=""
exrsync=""
for ex in ${EXCLUDE[@]}
do
    exdiff+=" -x $ex"
    exrsync+=" --exclude=$ex"
done
echo $exdiff
echo $exrsync

copy() {
    fpat="Only in "${MNTDIR}
    if [ -d ${2} ]
    then
        diffs=$(diff -qr ${exdiff} ${1} ${2} | grep "${fpat}")
    fi
    if [ "$diffs" != "" ] 
    then
        echo "${diffs//$fpat/Copying: }"
    fi
    rsync -ru ${exrsync} ${1}/* ${2}
}

echo "Mounting ${MNTDIR}..."
mount ${MNTDIR}
echo "Mounted ${MNTDIR}"

if [ ! -d ${DESTDIR} ]
then
    echo "Creating ${DESTDIR}"
    mkdir ${DESTDIR}
fi

echo "Looking for stuff to copy..."
for basedir in ${!BDND[@]}
do
    for dir in ${BDND[$basedir]}
    do
        copy ${MNTDIR}${basedir}${dir} ${DESTDIR}${dir}
    done
done

for dir in ${DIRS[@]}
do
    from=${MNTDIR}${dir}
    di=$(basename ${from})
    copy ${from} ${DESTDIR}${di}
done

echo "Umounting ${MNTDIR}..."
umount ${MNTDIR}
echo "Umounted ${MNTDIR}"
echo "Thank you! Copy again."
