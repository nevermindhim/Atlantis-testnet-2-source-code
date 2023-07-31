package v9

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/cosmos/cosmos-sdk/types/module"
	upgradetypes "github.com/cosmos/cosmos-sdk/x/upgrade/types"
	inflationkeeper "github.com/defi-ventures/bcx-testnet-7/x/inflation/keeper"
	inflationtypes "github.com/defi-ventures/bcx-testnet-7/x/inflation/types"
)

// CreateUpgradeHandler creates an SDK upgrade handler for v9
func CreateUpgradeHandler(
	mm *module.Manager,
	configurator module.Configurator,
	ik inflationkeeper.Keeper,

) upgradetypes.UpgradeHandler {
	return func(ctx sdk.Context, _ upgradetypes.Plan, vm module.VersionMap) (module.VersionMap, error) {
		logger := ctx.Logger().With("upgrade", UpgradeName)
		params := ik.GetParams(ctx)
		epochsPerPeriod := ik.GetEpochsPerPeriod(ctx)
		supply := ik.GetCirculatingSupply(ctx)
		newProvision := inflationtypes.CalculateEpochMintProvision(
			params,
			epochsPerPeriod,
			supply,
		)

		supply = ik.GetCirculatingSupply(ctx)
		newProvision = inflationtypes.CalculateEpochMintProvision(
			params,
			epochsPerPeriod,
			supply,
		)
		ik.SetEpochMintProvision(ctx, newProvision)
		epochMintProvision := inflationtypes.CalculateEpochMintProvision(params, epochsPerPeriod, supply)
		ik.SetEpochMintProvision(ctx, epochMintProvision)

		// Refs:
		// - https://docs.cosmos.network/master/building-modules/upgrade.html#registering-migrations
		// - https://docs.cosmos.network/master/migrations/chain-upgrade-guide-044.html#chain-upgrade

		// Leave modules are as-is to avoid running InitGenesis.
		logger.Debug("running module migrations ...")
		return mm.RunMigrations(ctx, configurator, vm)
	}
}
