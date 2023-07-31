package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
)

// CalculateEpochProvisions returns mint provision per epoch
func CalculateEpochMintProvision(
	params Params,
	epochsPerPeriod int64,
	supply sdk.Dec,
) sdk.Dec {
	c := params.ExponentialCalculation.C
	periodProvision := supply.Quo(c)
	epochProvision := periodProvision.Quo(sdk.NewDec(epochsPerPeriod))
	return epochProvision
}
