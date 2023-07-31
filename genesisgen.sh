KEY1="seedkey1"
KEY2="seedkey2"
CHAINID="blockx_50-1" # for testnet
MONIKER1="seednode1"
MONIKER2="seednode2"

KEYRING="file" # remember to change to other types of keyring like 'file' in-case exposing to outside world, otherwise your balance will be wiped quickly. The keyring test does not require private key to steal tokens from you
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
TRACE="--trace"
# TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# used to exit on first error (any non-zero exit code)
set -e

# Clear everything of previous installation
rm -rf ~/.blockxd*

# Reinstall daemon
# make install

# Set client config
blockxd config keyring-backend $KEYRING
blockxd config chain-id $CHAINID

# add $KEY
blockxd keys add $KEY1 --keyring-backend $KEYRING
blockxd keys add $KEY2 --keyring-backend $KEYRING

# Set moniker and chain-id for blockx (Moniker can be anything, chain-id must be an integer)
blockxd init $MONIKER1 --chain-id $CHAINID

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
node_address=$(blockxd keys list | grep  "address: " | cut -c12-)
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
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.blockxd/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.blockxd/config/config.toml
fi

# Allocate genesis accounts (cosmos formatted addresses)
blockxd add-genesis-account $KEY1 697000000000000000000000000abcx --keyring-backend $KEYRING
blockxd add-genesis-account $KEY2   1000000000000000000000000abcx --keyring-backend $KEYRING


# Sign genesis transaction
blockxd gentx $KEY1 1000000000000000000000000abcx --keyring-backend $KEYRING --chain-id $CHAINID
## In case you want to create multiple validators at genesis
## 1. Back to `blockxd keys add` step, init more keys
## 2. Back to `blockxd add-genesis-account` step, add balance for those
## 3. Clone this ~/.blockxd home directory into some others, let's say `~/.clonedBlockxd`
## 4. Run `gentx` in each of those folders
## 5. Copy the `gentx-*` folders under `~/.clonedBlockxd/config/gentx/` folders into the original `~/.blockxd/config/gentx`

# Collect genesis tx
blockxd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
blockxd validate-genesis
