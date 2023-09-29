
<div align="center">
  <h1> Atlantis Testnet Source Code</h1>
</div>


# Pre-requisites:
Go version 1.18
Ubuntu 22.04
Make
GCC

# Pre-requisite step
## Install Golang:
Install latest go version https://golang.org/doc/install

```
wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash -s -- --version 1.18
source ~/.profile
```

To verify that Golang installed
```
go version
```

It should return go version go1.18 linux/amd64


## Install Make to compile the code
sudo apt install make

## Install GCC in case GCC is not yet installed
sudo apt-get install gcc



# Compile the code
```
make install
```

This will create a blockxd file in the /root/go/bin directory

# Run a Node
To run a node, edit the init.sh file and change the Moniker name to whatever you want your node to be named.
```
chmod +x init.sh
./init.sh
```


# How to add blockxd path for it to be accessible system-wide
In the example below, blockxd is in /root/go/bin
```
export PATH=/root/go/bin:$PATH
source ~/.bashrc
```


# How to add a key 
```
blockxd keys add <your key name> --keyring-backend file --algo eth_secp256k1
# e.g.  blockxd keys add mykey --keyring-backend file --algo eth_secp256k1
```
It will prompt you to create a keyring passphrase, make sure you remember it as you're going to need this for every transactions. After entering the passphrase, it will give you your address together with a recovery phrase, make sure to have a copy of it. You can use this passphrase to import your key/wallet to another wallet like Metamask.


# How to become a validator using Ubuntu 22.04
Make sure to request for some BCX tokens first from the BCX Team. You will have a receiving address once you created a key from the previous instruction. Open the validator.sh file and change the values there depending on your preference
```
chmod +x validator.sh
./validator.sh
```


# Notes if starting own chain
1. Make sure that the voting power of 1 validator does not reach more than 30% to avoid potential too much dependency of the chain to a single node only.
2. Dont use the genesis.json file in this repository and let it create its own genesis.json file
3. persistent_peer is important in the config but it is safer to have some nodes in the seed cofiguration of the config file located in .blockxd/config/config.toml file


# Submitted Proposals
Proposals were submitted for this Atlantis Testnet in order to improve the chain.
For this testnet, we submitted the proposals below. The files slash.json and metadata.json is also located in this repo:

1) Change Slashing Window
The Slashing window dictates how many blocks can a validator miss before they get jailed which slashes their earnings. The previous setting was 100 blocks and with a block time of around 1 second, it only gives the validator around 2 minutes to upgrade their server or have a downtime. The submitted proposal increased the window to 40,000 blocks giving enough time for validators to perform maintenance in their servers. 
Below is the command used

```
./blockxd tx gov submit-proposal param-change slash.json --from node1 --chain-id blockx_50-1 --gas 1000000
```


2) Register Coin for metadata
This metadata proposal was submitted in order for Ping Explorer and may also include future dapps to be able to recognize the denominations of Atlantis Testnet which is abcx and bcx with BCX = 1e18 abcx.
Below is the command used

```
./blockxd tx gov submit-proposal register-coin metadata.json --from node1 --chain-id blockx_50-1 --gas 2000000 --title "BCX Metadata proposal" --description "For Ping UI to be able to detect the number of decimals BCX has"
```