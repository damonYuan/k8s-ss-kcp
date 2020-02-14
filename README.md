k8s-ss-kcp
====

![license](https://img.shields.io/github/license/mashape/apistatus.svg)

[![GitHub stars](https://img.shields.io/github/stars/damonYuan/DySocksManager.svg?style=social&label=Stars)](https://github.com/damonYuan/DySocksManager/stargazers)
[![GitHub watchers](https://img.shields.io/github/watchers/damonYuan/DySocksManager.svg?style=social&label=Watch)](https://github.com/damonYuan/DySocksManager/watchers)
[![GitHub issues](https://img.shields.io/github/issues/damonYuan/DySocksManager.svg)](https://github.com/damonYuan/DySocksManager/issues)

A Kubernetes solution for [ShadowSocks](https://github.com/shadowsocks/shadowsocks-libev) + [kcptun](https://github.com/xtaci/kcptun).

## Introduction

### DaemonSet

The DaemonSet resource will guarantee on each node exactly one pod will running. This character is perfect for setting up shadowsocks in cluster because the bandwidth is limited on each node, having more than one working pod on a single node will gain no more benifit than having more worker threads in the ShadowSocks container within the single pod.

### LoadBalancer

LoadBalancer is backed by NodePort which improves the efficiency by reducing the hops. And the `externalTrafficPolicy` is set to local because we are sure there is one running pod on the node that accepts the traffic. Note that if no local pods exist, the connection will hang and won't be forwarded to a random global pod.

### Configuration

The configuration for ShadowSocks and kcptun is placed inside the `config` folder. Please rename `kcptun.json.example` to `kcptun.json` and `shadowsocks.json.example` to `shadowsocks.json` and update the attributes accordingly.

## Architecutre

`user <-> ss client <-> tcptun client <-> tcptun server <-> ss server <-> target website`

Solution for `ss client + tcptun client` can be ShadowsocksX-NG or using a docker-compose to orchestrate.

## Runbook

1. Create necessary secrets for ShadowSocks and kcptun configurations.

   ```
   cd config
   ./ss-kcp-sec.sh
   ```

2. Apply Kubernetes configuration.
   
   ```
   kubectl apply -f ss-kcp.yaml
   ```

3. Configure your client side to connect with the endpoints.

   Note that if ShadowsocksX-NG is used, in the Address field of the Server Preference, the tcptun's UDP port and the address should be filled. For more details please refer to [ShadowsocksX-NG](https://github.com/shadowsocks/ShadowsocksX-NG).

   You can change the `.env.example` to `.env`, update the attributes, and use the docker file in client folder directly,
   ```
   # use ss directly
   docker-compose -f ss-compose.yam up -d
   # OR use with kcptun
   docker-compose -f kcptun-compose.yam up -d
   ```

## Q&A

1. Why not using VPN?

   VPN's traffic characteristics is quite significant and easy to be detected. In some area it is not viable because the IP would be blocked if the traffic has been identified as VPN. 

2. Why not SSH tunnel?

   Mostly it is about the stability and performance. SSH Tunnel requires the connection to be maintained, which makes it almost unusable when using cellular network over a mobile phone and traveling in a vehicle. Another thing is about the performance, while I think it is just a minor issue for normal usage. To be honest I feel no difference when using SSH tunnel solution compared to the **plain ShadowSocks (no kcptun)** one.   

3. Why the tcptun disconnect abruptly?

   Mostly it's the ISP has blocked/interrupted the huge UDP traffic. 
   P.S., possible solutions are,
     1. add `-t` in kcptun ([under developement and buggy](https://github.com/xtaci/kcptun/issues/696#issuecomment-586311846))
     2. use [udp2raw](https://github.com/wangyu-/udp2raw-tunnel) ([tried but still failed](https://github.com/wangyu-/udp2raw-tunnel/issues/144#issuecomment-586420753))
