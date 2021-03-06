#!/bin/bash
# vi: set sw=4 ts=4:

VERSION="0.1.1"
EXT="massmail-htmlizer-extension"
NAME="MassEmail.php Htmlizer Extension"
DESCRIPTION="Mass eMmail using Htmlizer, just as the Pdf functionality"

CMD=$1;

CLIENT_FILES=""
FORMULA_FILES=""
POLL_FILES=""
CORE_FILES="application/Espo/Modules/Crm/Services/MassEmail.php"

FILES="$CLIENT_FILES $FORMULA_FILES $POLL_FILES $CORE_FILES"

if [ "$CMD" == "install" ]; then
	tar cf - $FILES | (cd ~/crm; tar xvf -)
elif [ "$CMD" == "fromcrm" ]; then
	(cd ~/crm;tar cf - $FILES) | tar xvf -
elif [ "$CMD" == "buildext" ] ; then
	DIR=/tmp/$EXT
	rm -rf $DIR
	mkdir $DIR

	MANIFEST=$DIR/manifest.json
	DT=`date +%Y-%m-%d`
	
	echo "{" 											>$MANIFEST
	echo "  \"name\": \"$NAME\", " 						>>$MANIFEST
	echo "  \"version\": \"$VERSION\", " 				>>$MANIFEST
	echo "  \"acceptableVersions\": [ \">=5.8.5\" ], "	>>$MANIFEST
	echo "  \"php\": [ \">=7.0.0\" ], " 				>>$MANIFEST
	echo "  \"releaseDate\": \"$DT\", " 				>>$MANIFEST
	echo "  \"author\": \"Hans Dijkema\", "				>>$MANIFEST
	echo "  \"description\": \"$DESCRIPTION\""			>>$MANIFEST
	echo "}"											>>$MANIFEST

	mkdir $DIR/files
	tar cf - $FILES | (cd $DIR/files; tar xf - )

	mkdir $DIR/scripts

	F=$DIR/scripts/BeforeInstall.php
	echo "<?php"									>$F
    echo "class BeforeInstall"						>>$F
	echo "{"										>>$F
	echo "  public function run($container) {}" 	>>$F
	echo "}"										>>$F
	echo "?>"										>>$F

	F=$DIR/scripts/AfterInstall.php
	echo "<?php"									>$F
    echo "class AfterInstall"						>>$F
	echo "{"										>>$F
	echo "  public function run($container) {}" 	>>$F
	echo "}"										>>$F
	echo "?>"										>>$F

	F=$DIR/scripts/BeforeUninstall.php
	echo "<?php"									>$F
    echo "class BeforeUninstall"					>>$F
	echo "{"										>>$F
	echo "  public function run($container) {}" 	>>$F
	echo "}"										>>$F
	echo "?>"										>>$F

	F=$DIR/scripts/AfterUninstall.php
	echo "<?php"									>$F
    echo "class AfterUninstall"						>>$F
	echo "{"										>>$F
	echo "  public function run($container) {}" 	>>$F
	echo "}"										>>$F
	echo "?>"										>>$F

	EXTENSION="espocrm-$EXT-$VERSION.zip"
	CDIR=`pwd`
	BUILD_DIR="$CDIR/build"
	EXT_FILE="$BUILD_DIR/$EXTENSION"

    echo "creating extension in $EXT_FILE"
	(cd $DIR;zip -r $EXT_FILE .)

	echo "$EXTENSION created in directory $BUILD_DIR"
else 
	echo "usage: $0 <install|buildext|fromcrm>"
fi

