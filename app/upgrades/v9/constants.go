package v9

const (
	// UpgradeName is the shared upgrade plan name for mainnet and testnet
	UpgradeName = "v9.0.0"
	// MainnetUpgradeHeight defines the Blockx mainnet block height on which the upgrade will take place
	TestnetUpgradeHeight = 6_885_000
	// UpgradeInfo defines the binaries that will be used for the upgrade
	UpgradeInfo = `'{"binaries":{"ubuntu-22.04":"https://github.com/defi-ventures/blockx-node-public-compiled/releases/download/v9.0.0/blockxd"}}'`
)
