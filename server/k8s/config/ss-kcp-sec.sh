#!/usr/bin/env bash

kubectl create secret generic ss-config \
  --from-file=shadowsocks.json -n ss

kubectl create secret generic kcptun-config \
  --from-file=kcptun.json -n ss  