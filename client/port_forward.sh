#!/bin/bash

# Fix below to your own variables
PORT_START=47700
REMOTE_USER="sukim96"
REMOTE_SERVER="mir.tiramisu.yonsei.ac.kr"

ssh     -Nf \
        -L  8011:localhost:$((PORT_START +  0)) \
        -L  8012:localhost:$((PORT_START +  1)) \
        -L  8211:localhost:$((PORT_START +  2)) \
        -L  8891:localhost:$((PORT_START +  3)) \
        -L  8899:localhost:$((PORT_START +  4)) \
        -L 47995:localhost:$((PORT_START +  5)) \
        -L 47996:localhost:$((PORT_START +  6)) \
        -L 47997:localhost:$((PORT_START +  7)) \
        -L 47998:localhost:$((PORT_START +  8)) \
        -L 47999:localhost:$((PORT_START +  9)) \
        -L 48000:localhost:$((PORT_START + 10)) \
        -L 48001:localhost:$((PORT_START + 11)) \
        -L 48002:localhost:$((PORT_START + 12)) \
        -L 48003:localhost:$((PORT_START + 13)) \
        -L 48004:localhost:$((PORT_START + 14)) \
        -L 48005:localhost:$((PORT_START + 15)) \
        -L 48006:localhost:$((PORT_START + 16)) \
        -L 48007:localhost:$((PORT_START + 17)) \
        -L 48008:localhost:$((PORT_START + 18)) \
        -L 48009:localhost:$((PORT_START + 19)) \
        -L 48010:localhost:$((PORT_START + 20)) \
        -L 48011:localhost:$((PORT_START + 21)) \
        -L 48012:localhost:$((PORT_START + 22)) \
        -L 49000:localhost:$((PORT_START + 23)) \
        -L 49001:localhost:$((PORT_START + 24)) \
        -L 49002:localhost:$((PORT_START + 25)) \
        -L 49003:localhost:$((PORT_START + 26)) \
        -L 49004:localhost:$((PORT_START + 27)) \
        -L 49005:localhost:$((PORT_START + 28)) \
        -L 49006:localhost:$((PORT_START + 29)) \
        -L 49007:localhost:$((PORT_START + 30)) \
        -L 49100:localhost:$((PORT_START + 31)) \
    -p 22222 ${REMOTE_USER}@mir.tiramisu.yonsei.ac.kr
