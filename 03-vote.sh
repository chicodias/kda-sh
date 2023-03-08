#!/bin/sh

for i in $(seq 15); do
    pubk=$(cat testnet-keys/key$i | cut -c 9- | head -n 1)
    amount=$(($RANDOM % 100 + 1)).0
    cmd="publicMeta:
  chainId: \"0\"
  sender: \"k:$pubk\"
  gasLimit: 10000
  gasPrice: 0.00000001
  creationTime: $(date +%s --date='-1 minute')
  ttl: 36000
signers:
  - public: $pubk
    caps: []
  - public: 368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca
    caps:
      - name: coin.GAS
        args: []
networkId: development
code: |-
  (kaddex.dao2.approved-vote \"78tFObfQJAwxHdvMCj1xx5T6k7WQAWd_fPVIBU6M5Y0\" \"k:$pubk\")
type: exec
data: []"

    echo -e "$cmd" >batch_txs/vote$i.yaml
    pact -u batch_txs/vote$i.yaml | pact add-sig testnet-keys/key$i swapper-keys.kda | curl -H "Content-Type: application/json" -d @- -X POST https://devnet.kaddex.com/chainweb/0.0/development/chain/0/pact/api/v1/send

done
