package keeper

import (
	"context"

	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/defi-ventures/bcx-testnet-7/cmd/config"
	"github.com/defi-ventures/bcx-testnet-7/x/bridge/types"
	"github.com/tendermint/tendermint/crypto"
)

func (k msgServer) SentToBlockx(goCtx context.Context, msg *types.MsgSentToBlockx) (*types.MsgSentToBlockxResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	// Only bridge can do this.
	if msg.Creator != config.BridgeAddress {
		panic("Should be called by Bridge")
	}

	recipient, err := sdk.AccAddressFromBech32(msg.Recipient)
	if err != nil {
		panic(err)
	}

	amount, err := sdk.ParseCoinsNormalized(msg.Amount)
	if err != nil {
		panic(err)
	}

	moduleAcct := sdk.AccAddress(crypto.AddressHash([]byte(types.ModuleName)))

	sdkError := k.bankKeeper.SendCoins(ctx, moduleAcct, recipient, amount)
	if sdkError != nil {
		return nil, sdkError
	}

	return &types.MsgSentToBlockxResponse{}, nil
}
