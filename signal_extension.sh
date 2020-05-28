#!/bin/bash
# vi: set sw=4 ts=4:

VERSION="0.1.0"

CMD=$1;

CLIENT_FILES="client/src/signals.js client/src/views/record/panels/autoupdate-relationship.js"
CLIENT_FILES="$CLIENT_FILES  client/src/views/record/autoupdate-detail.js"
FORMULA_FILES="application/Espo/Core/Formula/Functions/SignalType.php"
POLL_FILES="api/v1/PollingSignals/DeregisterSignal.php  api/v1/PollingSignals/FlaggedSignals.php  api/v1/PollingSignals/RegisterSignal.php"

FILES="$CLIENT_FILES $FORMULA_FILES $POLL_FILES"

if [ "$CMD" == "install" ]; then
	tar cf - $FILES | (cd ~/crm; tar xvf -)
elif [ "$CMD" == "fromcrm" ]; then
	(cd ~/crm;tar cf - $FILES) | tar xvf -
elif [ "$CMD" == "buildext" ] ; then
	DIR=/tmp/signals_extension
	rm -rf $DIR
	mkdir $DIR

	MANIFEST=$DIR/manifest.json
	DT=`date +%Y-%m-%d`
	
	echo "{" 											>$MANIFEST
	echo "  \"name\": \"Signals Extension\", " 			>>$MANIFEST
	echo "  \"version\": \"$VERSION\", " 				>>$MANIFEST
	echo "  \"acceptableVersions\": [ \">=5.8.5\" ], "	>>$MANIFEST
	echo "  \"php\": [ \">=7.0.0\" ], " 				>>$MANIFEST
	echo "  \"releaseDate\": \"$DT\", " 				>>$MANIFEST
	echo "  \"author\": \"Hans Dijkema\", "				>>$MANIFEST
	echo "  \"description\": \"Allows to signal the front-end from a formula, as to trigger a refetch of data\"" >>$MANIFEST
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

	EXTENSION="espocrm-signals-extension-$VERSION.zip"
	CDIR=`pwd`
	BUILD_DIR="$CDIR/build"
	EXT_FILE="$BUILD_DIR/$EXTENSION"

    echo "creating extension in $EXT_FILE"
	(cd $DIR;zip -r $EXT_FILE .)

	echo "$EXTENSION created in directory $BUILD_DIR"
else 
	echo "usage: $0 <install|buildext|fromcrm>"
fi

