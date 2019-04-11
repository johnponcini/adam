#!/usr/bin/env bash

while read d; 
    do data+=($d);
done < '/usr/local/lib/python3.5/dist-packages/adam/mpbc/default.info'
declare -p data

FILENAME="${data[0]}_${data[2]}_${data[3]}_${data[4]}"
STUDY="${data[0]}"
FILEPATH="${data[0]}/${data[2]}/${data[3]}"

rm ~/.rnd
cd /tmp/
openssl rand 128 > ${FILENAME}.key
openssl rsautl -encrypt -inkey /etc/keys/public.pem -pubin -in ${FILENAME}.key -out ${FILENAME}.key.enc
tar -czv ${FILENAME} | openssl aes-256-cbc -out ${FILENAME}.tar.gz.enc -pass file:${FILENAME}.key
rm ${FILENAME}.key

if [ $STUDY == "MP18" ] || [ $STUDY == "MAPP3" ]; then
    aws s3 cp ${FILENAME}.tar.gz.enc s3://maps-eu-videos/$FILEPATH/
    aws s3 cp ${FILENAME}.key.enc s3://maps-eu-videos/$FILEPATH/
else
    aws s3 cp ${FILENAME}.tar.gz.enc s3://maps-study-videos/$FILEPATH/
    aws s3 cp ${FILENAME}.key.enc s3://maps-study-videos/$FILEPATH/
fi;
