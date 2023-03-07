#!/bin/sh
# generate 15 keypairs and fund them with kda and kdx
for i in $(seq 15); do
    #pact -g >testnet-keys/key$i
    pubk=$(cat testnet-keys/key$i | cut -c 9- | head -n 1)
    cmd="publicMeta:
  chainId: \"0\"
  sender: \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\"
  gasLimit: 1000000
  gasPrice: 0.00000001
  creationTime: $(date +%s --date='-1 minute')
  ttl: 36000
signers:
  - public: 368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca
    caps:
      - name: kaddex.kdx.TRANSFER
        args:
          [
            \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\",
            \"k:$pubk\",
            100.0,
          ]
      - name: coin.TRANSFER
        args:
          [
            \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\",
            \"k:$pubk\",
            1.0,
          ]
      - name: coin.GAS
        args: []
networkId: development
code: |-
  (kaddex.kdx.transfer-create \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\" \"k:$pubk\" (read-keyset 'new-acc) 100.0)
  (coin.transfer-create \"k:368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca\" \"k:$pubk\" (read-keyset 'new-acc) 1.0)

data:
  kdx-admin-keyset:
    keys:
      - 368820f80c324bbc7c2b0610688a7da43e39f91d118732671cd9c7500ff43cca
    pred: keys-all
  new-acc:
    keys: [$pubk]
    pred: \"keys-all\"
type: exec"

    echo -e "$cmd" >batch_txs/test$i.yaml
    pact -u batch_txs/test$i.yaml | pact add-sig swapper-keys.kda | curl -H "Content-Type: application/json" -d @- -X POST https://devnet.kaddex.com/chainweb/0.0/development/chain/0/pact/api/v1/send

done
