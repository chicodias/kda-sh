#!/bin/sh

for i in $(seq 15); do
    pubk=$(cat testnet-keys/key$i | cut -c 9- | head -n 1)
    amount=$(($RANDOM % 100 + 1)).0
    cmd="publicMeta:
  chainId: \"0\"
  sender: \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\"
  gasLimit: 1000000
  gasPrice: 0.00000001
  creationTime: $(date +%s --date='-1 minute')
  ttl: 36000
signers:
  - public: $pubk
    caps:
      - name: kaddex.kdx.WRAP
        args:
          [
            \"kaddex.skdx\",
            \"k:$pubk\",
            \"k:$pubk\",
            0.1
          ]
      - name: kaddex.staking.STAKE
        args:
          [
            \"k:$pubk\",
            0.1
          ]
  - public: 368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca
    caps:
      - name: coin.GAS
        args: []
networkId: development
code: |-
  (kaddex.staking.stake \"k:$pubk\" 0.1)
data:
  new-acc:
    keys: [$pubk]
    pred: \"keys-all\"
type: exec"

    echo -e "$cmd" >batch_txs/stake$i.yaml
    pact -u batch_txs/stake$i.yaml | pact add-sig testnet-keys/key$i swapper-keys.kda | curl -H "Content-Type: application/json" -d @- -X POST https://devnet.kaddex.com/chainweb/0.0/development/chain/0/pact/api/v1/send

done
