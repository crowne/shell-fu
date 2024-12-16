#!/bin/bash

# see https://learn.microsoft.com/en-us/rest/api/storageservices/put-block?tabs=microsoft-entra-id

ARG_COUNT=$#

if [ ! $ARG_COUNT -eq 5 ]
then
    echo "usage: nice -18 ionice -c idle ./upload-blob.sh FILE_PATH BLOB_DIR(dev/backups) AZ_ACCOUNT_NAME(appdevstorageacc) AZ_BLOB_CONTAINER(app-blob) 'AZ_SAS_TOKEN'(...sig=...)"
    exit
fi

FILE_PATH=$1
BLOB_DIR=$2
AZ_ACCOUNT_NAME=$3
AZ_BLOB_CONTAINER=$4
AZ_SAS_TOKEN=$5

FILE_NAME=$(basename $FILE_PATH)

# MAXSIZE is 100 MB
MAXSIZE=100000000

FILESIZE=$(stat -c%s "$FILE_PATH")
echo "Size of $FILE_NAME = $FILESIZE bytes."

# echo "\nEnter your storage account name (appdevstorageacc):"
# read AZ_ACCOUNT_NAME
# echo "\nEnter your container name (app-blob):"
# read AZ_BLOB_CONTAINER
# echo "\nEnter your SAS token (just hit ENTER/RETURN if not applicable)"
# read AZ_SAS_TOKEN

DATE_NOW=$(date -Ru | sed 's/\+0000/GMT/')
AZ_VERSION="2023-01-03"
AZ_BLOB_URL="https://$AZ_ACCOUNT_NAME.blob.core.windows.net"
AZ_BLOB_TARGET="${AZ_BLOB_URL}/${AZ_BLOB_CONTAINER}/"

if (( $FILESIZE < $MAXSIZE )); then
    echo "No chunking, $FILE_NAME is less than 100MB"
    REST_URL="${AZ_BLOB_TARGET}$BLOB_DIR/$FILE_NAME?${AZ_SAS_TOKEN}"
    echo sending file $REST_URL
    curl -i -X PUT -H "Content-Type: application/octet-stream" -H "x-ms-date: ${DATE_NOW}" -H "x-ms-version: ${AZ_VERSION}" -H "x-ms-blob-type: BlockBlob" --upload-file $FILE_PATH "$REST_URL"
else
    echo "Chunking : $FILE_NAME is greater than 100MB"

    SPLIT_DIR="${FILE_PATH}-chunks"
    mkdir -p $SPLIT_DIR
    XML='<?xml version="1.0" encoding="utf-8"?><BlockList>'

    echo splitting $FILE_PATH into 100MB chunks into temporary directory $SPLIT_DIR/
    split -b 100000000 $FILE_PATH $SPLIT_DIR/*
    # put blocks
    # ---------------------------------------
    for i in $SPLIT_DIR/*
    do
        PART_NAME="$FILE_NAME-chunks/$(basename $i)"
        echo uploading part $PART_NAME
        ENCODED_I="$(openssl enc -base64 -A <<< $PART_NAME)"
        BLOCK_ID_STRING="&comp=block&blockid=${ENCODED_I}"
        REST_URL="${AZ_BLOB_TARGET}$BLOB_DIR/$FILE_NAME?${AZ_SAS_TOKEN}${BLOCK_ID_STRING}"
        echo sending chunk $REST_URL
        curl -i -X PUT -H "Content-Type: application/octet-stream" -H "x-ms-date: ${DATE_NOW}" -H "x-ms-version: ${AZ_VERSION}" -H "x-ms-blob-type: BlockBlob" --upload-file $i "$REST_URL"
        XML="${XML}<Uncommitted>${ENCODED_I}</Uncommitted>"
    done
    XML="${XML}</BlockList>"
    LENGTH=${#XML}
    echo "All blocks should be put. Now attempting PutBlockList..."

    # put block list. IMPORTANT: Content-Length must be the exact length of XML string, and XML must be passed to -d (--data) field
    # ---------------------------------------
    echo "Executing PUT for the following XML data..."
    echo ${XML}
    echo ""
    BLOCK_ID_STRING="&comp=blocklist"
    curl -i -X PUT -H "x-ms-date: ${DATE_NOW}" -H "x-ms-version: ${AZ_VERSION}" -H "Content-Length: ${LENGTH}" -d "${XML}" "${AZ_BLOB_TARGET}$BLOB_DIR/$FILE_NAME?${AZ_SAS_TOKEN}${BLOCK_ID_STRING}"
    echo ""
    echo "Block List should be PUT. Removing temporary directory..."
    rm -rf $SPLIT_DIR


    # get block list. Use for debugging
    # BLOCK_ID_STRING="&comp=blocklist&blocklisttype=uncommitted"
    # curl -v -X GET -H "Content-Type: application/octet-stream" -H "x-ms-date: ${DATE_NOW}" -H "x-ms-version: ${AZ_VERSION}" -H "x-ms-blob-type: BlockBlob" "${AZ_BLOB_TARGET}$1${AZ_SAS_TOKEN}${BLOCK_ID_STRING}"

fi
