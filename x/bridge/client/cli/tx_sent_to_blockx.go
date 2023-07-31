package cli

import (
	"strconv"

	"github.com/cosmos/cosmos-sdk/client"
	"github.com/cosmos/cosmos-sdk/client/flags"
	"github.com/cosmos/cosmos-sdk/client/tx"
	"github.com/defi-ventures/bcx-testnet-7/x/bridge/types"
	"github.com/spf13/cobra"
)

var _ = strconv.Itoa(0)

func CmdSentToBlockx() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "sent-to-blockx [recipient] [amount]",
		Short: "Broadcast message sent-to-blockx",
		Args:  cobra.ExactArgs(2),
		RunE: func(cmd *cobra.Command, args []string) (err error) {
			argRecipient := args[0]
			argAmount := args[1]

			clientCtx, err := client.GetClientTxContext(cmd)
			if err != nil {
				return err
			}

			msg := types.NewMsgSentToBlockx(
				clientCtx.GetFromAddress().String(),
				argRecipient,
				argAmount,
			)
			if err := msg.ValidateBasic(); err != nil {
				return err
			}
			return tx.GenerateOrBroadcastTxCLI(clientCtx, cmd.Flags(), msg)
		},
	}

	flags.AddTxFlagsToCmd(cmd)

	return cmd
}
