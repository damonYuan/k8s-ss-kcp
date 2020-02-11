k8s-ss-kcp
====

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

Solution for "ss client + tcptun client" can be ShadowsocksX-NG or using a docker-compose to orchestrate.

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
