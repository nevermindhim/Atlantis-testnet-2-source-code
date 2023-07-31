package types

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	sdkerrors "github.com/cosmos/cosmos-sdk/types/errors"
)

const TypeMsgSentToBlockx = "sent_to_blockx"

var _ sdk.Msg = &MsgSentToBlockx{}

func NewMsgSentToBlockx(creator string, recipient string, amount string) *MsgSentToBlockx {
	return &MsgSentToBlockx{
		Creator:   creator,
		Recipient: recipient,
		Amount:    amount,
	}
}

func (msg *MsgSentToBlockx) Route() string {
	return RouterKey
}

func (msg *MsgSentToBlockx) Type() string {
	return TypeMsgSentToBlockx
}

func (msg *MsgSentToBlockx) GetSigners() []sdk.AccAddress {
	creator, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		panic(err)
	}
	return []sdk.AccAddress{creator}
}

func (msg *MsgSentToBlockx) GetSignBytes() []byte {
	bz := ModuleCdc.MustMarshalJSON(msg)
	return sdk.MustSortJSON(bz)
}

func (msg *MsgSentToBlockx) ValidateBasic() error {
	_, err := sdk.AccAddressFromBech32(msg.Creator)
	if err != nil {
		return sdkerrors.Wrapf(sdkerrors.ErrInvalidAddress, "invalid creator address (%s)", err)
	}
	return nil
}
