#!/bin/bash
# vi: set sw=4 ts=4:

VERSION="0.1.0"
EXT="person-name-initials-extension"
NAME="Field PersonName with initials extension - IpersonName"
DESCRIPTION="Creates a new IpersonName Field type that can be used instead of PersonName, which also has initials"

CMD=$1;

CLIENT_FILES="client/src/views/fields/iperson-name.js"
META_DATA="application/Espo/Resources/metadata/fields/ipersonName.json"

FORMULA_FILES=""
POLL_FILES=""

CORE_FILES="application/Espo/Core/Utils/Database/Orm/Fields/IpersonName.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Loaders/EntityManagerHelper.php"
CORE_FILES="$CORE_FILES application/Espo/Core/ORM/Helper.php"
CORE_FILES="$CORE_FILES application/Espo/Core/Entities/Person.php"

ORM_FILES="application/Espo/Core/Utils/Database/Orm/Base.php"
ORM_FILES="$ORM_FILES application/Espo/Core/ORM/Helper.php"

TEMPLATE_FILES="client/res/templates/fields/iperson-name/detail.tpl"
TEMPLATE_FILES="$TEMPLATE_FILES client/res/templates/fields/iperson-name/edit-first-middle-last.tpl"
TEMPLATE_FILES="$TEMPLATE_FILES client/res/templates/fields/iperson-name/edit-last-first-middle.tpl"  
TEMPLATE_FILES="$TEMPLATE_FILES client/res/templates/fields/iperson-name/edit-last-first.tpl"
TEMPLATE_FILES="$TEMPLATE_FILES client/res/templates/fields/iperson-name/edit.tpl"


FILES="$CLIENT_FILES $FORMULA_FILES $POLL_FILES $CORE_FILES $ORM_FILES $META_DATA $TEMPLATE_FILES"

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

