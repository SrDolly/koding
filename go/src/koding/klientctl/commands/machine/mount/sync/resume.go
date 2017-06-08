package sync

import (
	"koding/klientctl/commands/cli"

	"github.com/spf13/cobra"
)

type resumeOptions struct{}

// NewResumeCommand creates a command can resume file synchronization of
// previously paused mount.
func NewResumeCommand(c *cli.CLI, aliasPath ...string) *cobra.Command {
	opts := &resumeOptions{}

	cmd := &cobra.Command{
		Use:   "resume",
		Short: "Resume file synchronization",
		RunE:  resumeCommand(c, opts),
	}

	// Middlewares.
	cli.MultiCobraCmdMiddleware(
		cli.WithMetrics(aliasPath...), // Gather statistics for this command.
		cli.NoArgs, // No custom arguments are accepted.
	)(c, cmd)

	return cmd
}

func resumeCommand(c *cli.CLI, opts *resumeOptions) cli.CobraFuncE {
	return func(cmd *cobra.Command, args []string) error {
		return nil
	}
}
