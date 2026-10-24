# Weekly GitHub Dev Summary (n8n + Claude + Discord)

Importable n8n workflow for a weekly, evidence-based engineering update. It collects recent commits, closed issues, and merged pull requests from one GitHub repository, asks Claude to summarize them, and posts the result to a Discord webhook.

## Setup (3 steps)

1. **Configure environment variables** for the n8n process:
   - `GITHUB_OWNER`: repository owner or organization
   - `GITHUB_REPO`: repository name
   - `GITHUB_TOKEN`: GitHub token with read access to repository metadata, issues, and pull requests
   - `ANTHROPIC_API_KEY`: Anthropic API key
   - `DISCORD_WEBHOOK_URL`: destination Discord webhook URL
   - `SUMMARY_LANGUAGE`: optional `EN` or `FR` (defaults to `EN`)
2. **Import** `weekly-dev-summary.json` in n8n (Workflows → Import from File). Confirm the workflow timezone is appropriate for your team and that the n8n deployment permits environment-variable access in expressions.
3. **Test, then activate** the workflow. Run a manual execution first and verify the GitHub GraphQL node, Claude response, and Discord delivery before enabling the Friday schedule.

## What it does

- Runs weekly on Friday at 5 PM in the workflow timezone (`America/Toronto` by default).
- Uses GitHub GraphQL to collect commits from the last seven days, closed issues, and merged PRs.
- Requests a concise summary with **Highlights**, **Shipped**, **Fixed**, **Open Questions**, and **Next Week** sections.
- Posts to Discord. Change the final HTTP Request node if you prefer a Slack webhook; Slack's incoming webhook payload uses a `text` field rather than Discord's `content` field.
- Keeps the workflow inactive after import so you can configure secrets and test delivery first.

## Limits and safety

- Each activity category is capped at 100 records per run. The generated summary is told to disclose this limit.
- The Discord message is truncated to stay below the platform's message length limit.
- Use a read-only GitHub token. The workflow does not write to GitHub.
- Never paste API keys or webhook URLs into the exported workflow; supply them through the n8n environment.
- The workflow summarizes only the data returned by GitHub and instructs Claude not to invent activity.

## Validation checklist

- [ ] Import JSON successfully in the target n8n version.
- [ ] Run a manual execution with valid environment variables.
- [ ] Confirm commit, issue, and PR data appear in the GitHub GraphQL response.
- [ ] Confirm Claude returns a summary in the selected language.
- [ ] Confirm the Discord webhook receives the message.
- [ ] Capture a screenshot of a successful execution for the bounty submission.

**Validation status:** This repository contribution includes the importable workflow and setup/verification steps. A screenshot from a live n8n instance is intentionally left unchecked because no live instance was available to run from this session.
