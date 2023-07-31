package keeper

import (
	"github.com/defi-ventures/bcx-testnet-7/x/bridge/types"
)

var _ types.QueryServer = Keeper{}
