#!/bin/bash

REPO_PATH=$1
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -z "$REPO_PATH" ]; then
  printf "${NC}Usage: lookml_folderization <path-to-repo>\n"
  exit 1
fi

if [ ! -d "$REPO_PATH" ]; then
  printf "${RED} Directory does not exist at %s\n" $REPO_PATH
  exit 1
fi

printf "${GREEN} Processing the repo at %s\n" $REPO_PATH

# negative lookahead to ignore project import files (anything that begins with //)
function modify_includes {
    perl -pi -e 's/(include.*:.*")(?!\/\/)(.*)(\.explore.*")/\1\/explores\/\2\3/g' $1
    perl -pi -e 's/(include.*:.*")(?!\/\/)(.*)(\.view.*")/\1\/views\/\2\3/g' $1
    perl -pi -e 's/(include.*:.*")(?!\/\/)(.*)(\.model.*")/\1\/models\/\2\3/g' $1
    perl -pi -e 's/(include.*:.*")(?!\/\/)(.*)(\.dashboard.*")/\1\/dashboards\/\2\3/g' $1
    perl -pi -e 's/(file.*:.*")(?!\/\/)(.*)(\.*json.*")/\1\/json\/\2\3/g' $1
    perl -pi -e 's/(include.*:.*?")(?!.*\.model|.*\.explore|.*\.view|.*\.dashboard)(.*")/\1\/other\/\2/g' $1 # used for other lkml files - excludes explore, view, model, and dashboard)
}


# non-lookml files (md strings *json)
ext_all=$(find $REPO_PATH -maxdepth 1 -type f | sed -E -e 's/.*\.//' -e 's/lkml|lookml//' | sort -u)

if [[ $ext_all = *json* ]]
then
    printf "${GREEN} Moving json files ${NC} \n"
    mkdir $REPO_PATH/json && mv -v $REPO_PATH/*json $REPO_PATH/json/ 2>/dev/null; true # move all json types and fail silently
fi

if [[ $ext_all = *strings* ]]
then
    printf "${GREEN} Moving strings files ${NC} \n"
    mkdir $REPO_PATH/strings && mv -v $REPO_PATH/*.strings $REPO_PATH/strings/
fi

if [[ $ext_all = *md* ]]
then
    printf "${GREEN} Moving documentation files ${NC} \n"
    mkdir $REPO_PATH/documents && mv -v $REPO_PATH/*.md $REPO_PATH/documents/
fi


# all lookml files (explore.lkml, view.lkml, model.lkml)
ext_lkml=$(find $REPO_PATH -maxdepth 1 -type f | sed -E -n 's/.*\.(.*\.lkml)/\1/p' | sort -u)

if [[ $ext_lkml = *explore.lkml* ]]
then
    printf "${GREEN} Moving explore files ${NC} \n"
    mkdir $REPO_PATH/explores && mv -v $REPO_PATH/*.explore.lkml $REPO_PATH/explores/

    printf "${GREEN} Modifying include parameters in explore files... ${NC}"
    for f in $REPO_PATH/explores/*
    do
    	modify_includes ${f}
    done
    printf "${GREEN} Complete ${NC} \n"
fi

if [[ $ext_lkml = *view.lkml* ]]
then
    printf "${GREEN} Moving view files ${NC} \n"
    mkdir $REPO_PATH/views && mv -v $REPO_PATH/*.view.lkml $REPO_PATH/views/

    printf "${GREEN} Modifying include parameters in view files... ${NC}"
    for f in $REPO_PATH/views/*
    do
        modify_includes ${f}
    done
    printf "${GREEN} Complete ${NC} \n"
fi

if [[ $ext_lkml = *model.lkml* ]]
then
    printf "${GREEN} Moving model files ${NC} \n"
    mkdir $REPO_PATH/models && mv -v $REPO_PATH/*.model.lkml $REPO_PATH/models/

    printf "${GREEN} Modifying include parameters in model files... ${NC}"
    for f in $REPO_PATH/models/*
    do
        modify_includes ${f}
    done
    printf "${GREEN} Complete ${NC} \n"
fi


# lookml dashboards
ext_dashboard=$(find $REPO_PATH -maxdepth 1 -type f | sed -E -n 's/.*\.(dashboard\.lookml)/\1/p' | sort -u)

if [[ $ext_dashboard = dashboard.lookml ]]
then
    printf "${GREEN} Moving dashboard files ${NC} \n"
    mkdir $REPO_PATH/dashboards && mv -v $REPO_PATH/*.dashboard.lookml $REPO_PATH/dashboards/
fi


# other lkml files will be dumped here
other_lkml=$(find $REPO_PATH -maxdepth 1 -type f -not -path '*/\.*' | sed -E -e 's/.*\///' -e 's/manifest\.lkml//') # ignore manifest

if [[ $other_lkml = *.lkml* ]]
then
    printf "${GREEN} Moving other lookml files to other ${NC} \n"
    mkdir $REPO_PATH/other && mv -v $REPO_PATH/*.lkml $REPO_PATH/other/

    # manifest - keep at root
    if test -f $REPO_PATH/other/manifest.lkml
    then
        mv -v $REPO_PATH/other/manifest.lkml $REPO_PATH/
        printf "${GREEN} Manifest file kept at root ${NC} \n"
    fi

    printf "${GREEN} Modifying include parameters in other lookml files... ${NC}"
    for f in $REPO_PATH/other/*
    do
        modify_includes ${f}
    done
    printf "${GREEN} Complete ${NC} \n"
fi


printf "${GREEN} All files have been moved and file references updated ${NC} \n"
