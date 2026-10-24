# Claude PR reviewer

Requirements: Python 3.10+, GitHub CLI (`gh`) authenticated for the target repository, and an Anthropic API key.

```bash
export ANTHROPIC_API_KEY="..."
python3 solutions/bounty-4/claude_review.py --pr https://github.com/owner/repo/pull/123
python3 solutions/bounty-4/claude_review.py --pr https://github.com/owner/repo/pull/123 --output review.md
```

The CLI obtains the diff with `gh pr diff`, sends it to Claude Sonnet 4, and prints a structured Markdown review. It does not post comments or modify the PR, so a human can inspect the output before sharing it. Large diffs are truncated to bound the request size. Treat model output as suggestions, not as proof that a defect exists.
