#!/bin/sh

# Exit immediately on error or if var is undef
set -eu

ROOT=/tmp/fakeroot
BASE=("manifest.common" "manifest.shibd-config")
COMMON=("manifest.httpd" "manifest.shibd")
MANIFESTS=("manifest.base" "${BASE[@]}" "${COMMON[@]}")

# Takes a file manifest and appends C libraries needed to execute
# any of the listed files.
add_c_libraries () {
    # Add missing libraries to manifest
    cat $1 | xargs ldd | grep -o '/.\+\.so[^ :]*' >> $1 || echo Ignoring ldd errors >&2

    TMPF=`mktemp`
    # Add links and everything they point to to the manifest
    cat $1 | xargs dereflinks > $TMPF
    mv -f $TMPF $1

    sort -u $1 -o $1
}

# Takes two manifests and figures out the common files shared by
# both this allows us to create a shared Docker layer
make_common_layer_manifest() {
    OUTPUT=$1
    FILE1=$2
    FILE2=$3
    shift 3

    # Inputs must be sorted!
    FILES=($FILE1 $FILE2)
    for i in "${FILES[@]}"; do
        sort -u $i -o $i
    done

    # Common files are stored in $OUTPUT
    comm -12 $FILE1 $FILE2 >> $OUTPUT
    sort -u $OUTPUT -o $OUTPUT

    # Remove shared files from the user given manifests
    ALL=($FILE1 $FILE2 $@)
    TMPF=`mktemp`
    for i in "${ALL[@]}"; do
        comm -23 $i $OUTPUT > $TMPF
        mv -f $TMPF $i
    done
}

# Creates a directory /tmp/fakeroot/XYZ, from a given manifest.XYZ,
# containing all the files specified in the given manifest
make_layer() {
    MANIFEST=$1
    DIR="$ROOT/`echo $MANIFEST | grep -o '[^.]*$'`"
    TAR=`mktemp --suffix=.tar`

    tar cf $TAR -T $MANIFEST
    mkdir -p $DIR
    tar xf $TAR -C $DIR

    rm -f $TAR
}

for i in "${MANIFESTS[@]}"; do
    add_c_libraries $i
done

make_common_layer_manifest manifest.common ${COMMON[0]} ${COMMON[1]}
make_common_layer_manifest manifest.base ${BASE[0]} ${BASE[1]} ${COMMON[@]}

for i in "${MANIFESTS[@]}"; do
    make_layer $i
done

# This is used to make sure there are not race conditions in the
# downstream Docker images
find $ROOT/base/ -type f -exec sha256sum {} \; > /tmp/sha256sum.txt
mv /tmp/sha256sum.txt $ROOT/base/

# TODO do we really need these?
# Add some empty directories
mkdir -m 1777   $ROOT/httpd/tmp
mkdir -m 1777   $ROOT/shibd/tmp
mkdir -m 1777   $ROOT/shibd-config/tmp
mkdir -p -m 755 $ROOT/httpd/var/www/html 
mkdir -p $ROOT/httpd/var/run
mkdir -p $ROOT/httpd/run
ln -s /tmp $ROOT/httpd/etc/httpd/run
ln -s /tmp $ROOT/httpd/etc/httpd/logs
ln -s /tmp $ROOT/httpd/var/run/httpd
ln -s /tmp $ROOT/httpd/run/httpd
