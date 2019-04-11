#!/usr/bin/env bash
while read d; 
    do data+=($d);
done < '/usr/local/lib/python3.5/dist-packages/adam/mpbc/default.info'
declare -p data

FILENAME="${data[0]}_${data[2]}_${data[3]}_${data[4]}"
WEBCAMS=${data[5]}
MICROPHONES=${data[6]}

mkdir "/tmp/${FILENAME}"

if [ $WEBCAMS == 1  ]; then    
    {
    if [ $MICROPHONES == 0  ]; then
        {
        ffmpeg \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video0 \
            -f alsa -ac 2 -ar 32000 -i hw:1 \
            -map 0 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video.mp4" \
            -map 1 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio.m4a"
        };
    elif [ $MICROPHONES == 1 ]; then
        {
        ffmpeg \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video0 \
            -f alsa -ac 2 -ar 32000 -i hw:1 \
            -f alsa -ac 2 -ar 32000 -i hw:2 \
            -map 0 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video.mp4" \
            -map 1 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_1.m4a" \
            -map 2 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_2.m4a"
        };
    fi;
    };
elif [ $WEBCAMS == 2 ]; then
    {
    if [ $MICROPHONES == 0  ]; then
        {
        ffmpeg \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video0 \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video2 \
            -f alsa -ac 2 -ar 32000 -i hw:1 \
            -f alsa -ac 2 -ar 32000 -i hw:2 \
            -map 0 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video_1.mp4" \
            -map 1 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video_2.mp4" \
            -map 2 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_1.m4a" \
            -map 3 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_2.m4a"
        };
    elif [ $MICROPHONES == 1 ]; then
        {
        ffmpeg \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video0 \
            -f v4l2 -input_format h264 -vcodec h264 -s 1280x720 -r 15 -i /dev/video2 \
            -f alsa -ac 2 -ar 32000 -i hw:1 \
            -f alsa -ac 2 -ar 32000 -i hw:2 \
            -f alsa -ac 2 -ar 32000 -i hw:3 \
            -map 0 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video_1.mp4" \
            -map 1 -c:v copy -f mp4 "/tmp/${FILENAME}/${FILENAME}_video_2.mp4" \
            -map 2 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_1.m4a" \
            -map 3 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_2.m4a" \
            -map 4 -c:a aac "/tmp/${FILENAME}/${FILENAME}_audio_3.m4a"
        };
    fi;
    };
fi;

cd /tmp
openssl rand 128 > ${FILENAME}.key
openssl rsautl -encrypt -inkey /etc/keys/public.pem -pubin -in ${FILENAME}.key -out ${FILENAME}.key.enc
tar -czv ${FILENAME} | openssl aes-256-cbc -out ${FILENAME}.tar.gz.enc -pass file:${FILENAME}.key
rm ${FILENAME}.key
