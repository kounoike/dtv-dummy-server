#!/bin/bash

function gen_dummy() {
  duration=$1
  fps=$2
  filter=$3
  filename=$4
  frames=$(expr ${duration} \* ${fps})
  gen="mptestsrc=duration=${duration}:max_frames=${frames}:rate=${fps}:test=mv"
  agen="anullsrc=duration=${duration}"
  resize="crop=w=256:h=240:x=0:y=0,scale=w=1440:h=1080"

  # onid/tsid/sidは後で書き換えるので適当な値でOK
  ffmpeg -hide_banner \
    -f lavfi -i "${gen}" \
    -f lavfi -i "${agen}" \
    -vf "${resize},${filter}" \
    -pix_fmt yuv420p \
    -c:v mpeg2video \
    -c:a aac \
    -f mpegts \
    -mpegts_original_network_id 0x1122 \
    -mpegts_transport_stream_id 0x3344 \
    -mpegts_service_id 0x5566 \
    -metadata service_provider="MyProvider" \
    -metadata service_name="MyChannel" \
    -mpegts_flags +nit \
    -mpegts_m2ts_mode 0 \
    -nit_period 1 \
    "${filename}" \
    -y
}

duration=300

gen_dummy ${duration} 30 "null"  30p.ts
gen_dummy ${duration} 60 "interlace"  60i.ts
gen_dummy ${duration} 24 "telecine=first_field=top:pattern=23" 24t.ts
