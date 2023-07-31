package keeper_test

import (
	"context"
	"testing"

	sdk "github.com/cosmos/cosmos-sdk/types"
	keepertest "github.com/defi-ventures/bcx-testnet-7/testutil/keeper"
	"github.com/defi-ventures/bcx-testnet-7/x/bridge/keeper"
	"github.com/defi-ventures/bcx-testnet-7/x/bridge/types"
)

func setupMsgServer(t testing.TB) (types.MsgServer, context.Context) {
	k, ctx := keepertest.BridgeKeeper(t)
	return keeper.NewMsgServerImpl(*k), sdk.WrapSDKContext(ctx)
}
