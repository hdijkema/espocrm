#!/bin/bash
# vi: set sw=4 ts=4:

VERSION="0.1.0"
EXT="hookedformula-extension"
NAME="Formula using Hooks extension"
DESCRIPTION="Makes it possible to put hook-sections in an entity formula."

CMD=$1;

CLIENT_FILES=""
FORMULA_FILES=""
POLL_FILES=""
CORE_FILES="application/Espo/Core/Formula/Functions/WhileType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/RecalculateType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/FindManyType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/FetchManyType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/FetchRelatedManyType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/FetchManyHashType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/RecordGroup/FetchRelatedManyHashType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/LogType.php"
CORE_FILES="$CORE_FILES application/Espo/Hooks/Common/Formula.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ExecType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/StrAddType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/LogAddType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ConfigGetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ConfigExistsType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ConfigIncType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ConfigSetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ExtGroup/PdfGroup/FillinType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ExtGroup/HtmlizeType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ExtGroup/BeginType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ExtGroup/CommitType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/AttrType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/EntityGroup/GetRelatedType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/EntityGroup/GetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/EntityGroup/ThisType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/EntityGroup/GetManyType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/EntityGroup/SaveType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/SetAttrType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/GlobalGroup/Globals.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/GlobalGroup/SetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/GlobalGroup/GetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/GlobalGroup/IssetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/GlobalGroup/UnsetType.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/ArrayGroup/SetType.php"

HASH="GetType.php  IssetType.php  NewType.php  SetType.php  UnsetType.php"
for file in $HASH
do
	CORE_FILES="$CORE_FILES application/Espo/Core/Formula/Functions/HashGroup/$file"
done

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
	echo "  public function run($container) {"		>>$F
	echo "  }" 										>>$F
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

