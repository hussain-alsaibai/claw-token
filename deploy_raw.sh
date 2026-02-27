#!/bin/bash
# Raw JSON-RPC deployment attempt

WALLET="0x72389856bffde3c25b99be2f053145b0761bfdec"
RPC="https://sepolia.base.org"
PRIVATE_KEY="0c4ad5af11eee32f5389fd35a64e64c2bad466191fc6543ba8e0efd5941ab5a4"

echo "Checking wallet balance..."
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["'$WALLET'","latest"],"id":1}' \
  $RPC | head -100
