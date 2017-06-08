package cred

import (
	"koding/klientctl/commands/cli"

	"github.com/spf13/cobra"
)

// NewCommand creates a command that manages stack credentials.
func NewCommand(c *cli.CLI, aliasPath ...string) *cobra.Command {
	cmd := &cobra.Command{
		Use:     "credential",
		Aliases: []string{"c"},
		Short:   "Manage stack credentials",
		RunE:    cli.PrintHelp(c.Err()),
	}

	// Subcommands.
	cmd.AddCommand(
		NewCreateCommand(c, cli.ExtendAlias(cmd, aliasPath)...),
		NewDescribeCommand(c, cli.ExtendAlias(cmd, aliasPath)...),
		NewInitCommand(c, cli.ExtendAlias(cmd, aliasPath)...),
		NewListCommand(c, cli.ExtendAlias(cmd, aliasPath)...),
		NewUseCommand(c, cli.ExtendAlias(cmd, aliasPath)...),
	)

	// Middlewares.
	cli.MultiCobraCmdMiddleware(
		cli.NoArgs, // No custom arguments are accepted.
	)(c, cmd)

	return cmd
}
