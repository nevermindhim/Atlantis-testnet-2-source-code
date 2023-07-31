KEY="node1"
CHAINID="blockx_50-1"
MONIKER="BCX2-Node1"
KEYRING="file" # remember to change to other types of keyring like 'file' in-case exposing to outside world, otherwise your balance will be wiped quickly. The keyring test does not require private key to steal tokens from you
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# used to exit on first error (any non-zero exit code)
set -e

# Clear everything of previous installation
#rm -rf ~/.blockxd*

# Reinstall daemon
#make install

# Set client config
./blockxd config keyring-backend $KEYRING
./blockxd config chain-id $CHAINID

# if $KEY exists it should be deleted
./blockxd keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for blockx (Moniker can be anything, chain-id must be an integer)
./blockxd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to abcx
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["staking"]["params"]["unbonding_time"]="604800s"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Set gas limit in genesis
cat $HOME/.blockxd/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="10000000"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Set claims start time
node_address=$(./blockxd keys list | grep  "address: " | cut -c12-)
current_date=$(date -u +"%Y-%m-%dT%TZ")
cat $HOME/.blockxd/config/genesis.json | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["airdrop_start_time"]=$current_date' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Set claims records for validator account
amount_to_claim=10000
# cat $HOME/.blockxd/config/genesis.json | jq -r --arg node_address "$node_address" --arg amount_to_claim "$amount_to_claim" '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":$amount_to_claim, "actions_completed":[false, false, false, false],"address":$node_address}]' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Set claims decay
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["claims"]["params"]["duration_of_decay"]="1000000s"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["claims"]["params"]["duration_until_decay"]="100000s"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Claim module account:
# 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || blockx15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
# cat $HOME/.blockxd/config/genesis.json | jq -r --arg amount_to_claim "$amount_to_claim" '.app_state["bank"]["balances"] += [{"address":"blockx15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz","coins":[{"denom":"abcx", "amount":$amount_to_claim}]}]' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# disable produce empty block
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.blockxd/config/config.toml
#   else
#     sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.blockxd/config/config.toml
# fi

# if [[ $1 == "pending" ]]; then
#   if [[ "$OSTYPE" == "darwin"* ]]; then
#       sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.blockxd/config/config.toml
#       sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.blockxd/config/config.toml
#   else
#       sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "30s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.blockxd/config/config.toml
#       sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.blockxd/config/config.toml
#   fi
# fi

# Allocate genesis accounts (cosmos formatted addresses)
./blockxd add-genesis-account $KEY 698000000000000000000000000abcx --keyring-backend $KEYRING

# Update total supply with claim values
validators_supply=$(cat $HOME/.blockxd/config/genesis.json | jq -r '.app_state["bank"]["supply"][0]["amount"]')
# Bc is required to add this big numbers
# total_supply=$(bc <<< "$amount_to_claim+$validators_supply")
total_supply=698000000000000000000000000
cat $HOME/.blockxd/config/genesis.json | jq -r --arg total_supply "$total_supply" '.app_state["bank"]["supply"][0]["amount"]=$total_supply' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Sign genesis transaction
./blockxd gentx $KEY 150000000000000000000000000abcx --keyring-backend $KEYRING --chain-id $CHAINID
## In case you want to create multiple validators at genesis
## 1. Back to `blockxd keys add` step, init more keys
## 2. Back to `blockxd add-genesis-account` step, add balance for those
## 3. Clone this ~/.blockxd home directory into some others, let's say `~/.clonedblockxd`
## 4. Run `gentx` in each of those folders
## 5. Copy the `gentx-*` folders under `~/.clonedblockxd/config/gentx/` folders into the original `~/.blockxd/config/gentx`

# Collect genesis tx
./blockxd collect-gentxs
cd ~/.blockxd/config
jq '.app_state.slashing.params.signed_blocks_window = "40000"' genesis.json > temp.json && mv temp.json genesis.json
jq '.app_state.slashing.params.min_signed_per_window = "0.500000000000000000"' genesis.json > temp.json && mv temp.json genesis.json
jq '.app_state.slashing.params.slash_fraction_double_sign = "0.080000000000000000"' genesis.json > temp.json && mv temp.json genesis.json
jq '.app_state.gov.voting_params.voting_period = "604800s"' genesis.json > temp.json && mv temp.json genesis.json
#

cd $HOME/go/bin

# Run this to ensure everything worked and that the genesis file is setup correctly
./blockxd validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
./blockxd start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001abcx --json-rpc.api eth,txpool,personal,net,debug,web3
