#!/usr/bin/env zsh
#set -x

# Using zsh for the simple string-splitting syntax

NAME="Toady One"
EMAIL="toadyone@bay12games.com"
ZIPINFO_MATCH='([0-9]{4})([0-9]{2})([0-9]{2})\.([0-9]{2})([0-9]{2})([0-9]{2})'
TIME_ZONE='TZ="America\/Los Angeles"'
DATE_REPLACE="${TIME_ZONE} \\1-\\2-\\3 \\4:\\5:\\6"
ZIPINFO_DATE_TO_FUZZY_DATE="s/${ZIPINFO_MATCH}/${DATE_REPLACE}/"
DF_RAWS=df_raws

if [[ ! -a "${DF_RAWS}" ]]; then
    mkdir -p "${DF_RAWS}"
    cd "${DF_RAWS}"
    git init
    git config --local user.name "${NAME}"
    git config --local user.email "${EMAIL}"
    cd ..
fi

for i in df_zips/*;
do
    FILENAME=$(basename ${i%.*}).temp
    TIME=$(zipinfo -T $i | sed -Ene 's/^.*([0-9]{8}\.[0-9]{6}).*$/\1/p' | \
        LC_ALL=C sort --parallel=8 -gk 1 | tail -1);
    echo "${i}" "${TIME}" > "${FILENAME}";
done

LC_ALL=C sort --parallel=8 -gk 1 *.temp > sorted.temp
< sorted.temp | while read line;
do
    # ${line} contains the zip file path and zipinfo date separated by a space
    RECORD=("${(@s/ /)line}");
    TAG_NAME=$(basename "${RECORD[1]%.*}" | sed -Ee 's/_legacy|_win//' \
        -e 's/_s//' -e 's/df/0/' -e 's/_/./g');
    #echo "${TAG_NAME}" "${RECORD[2]}";
    unzip -o "${RECORD[1]}" "raw/*" -d "${DF_RAWS}";
    cd ${DF_RAWS};
    git add *;
    FUZZY_DATE=$(echo "${RECORD[2]}" | sed -Ee "${ZIPINFO_DATE_TO_FUZZY_DATE}")
    DATE=$(date --date="${FUZZY_DATE}" --rfc-2822)
    GIT_COMMITTER_DATE="${DATE}" git commit -m "${TAG_NAME}" --date "${DATE}";
    GIT_COMMITTER_DATE="${DATE}" git tag -a -m "${TAG_NAME}" "${TAG_NAME}";
    cd ..;
done

rm *.temp
