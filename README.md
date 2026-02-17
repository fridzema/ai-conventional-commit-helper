# cmt

AI-powered git commit messages. Fast.

Generates [conventional commit](https://www.conventionalcommits.org/) messages from your staged diff using Claude.

## Install

```sh
# Run directly
npx @cmt/cli        # npm
yarn dlx @cmt/cli   # yarn
bunx @cmt/cli       # bun

# Install globally
npm i -g @cmt/cli
yarn global add @cmt/cli
bun add -g @cmt/cli
```

## Prerequisites

- [git](https://git-scm.com/)
- [Claude CLI](https://docs.anthropic.com/en/docs/claude-cli) (`claude`)

## Usage

```sh
# Generate a commit message from your changes
cmt

# Commit with a specific message
cmt "feat: add user auth"

# Use a different model (default: haiku)
cmt --model sonnet

# Skip automatic git add
cmt --no-add
```

## Options

```
-m, --model <model>   Claude model to use (default: haiku)
--no-add              Skip automatic 'git add -A'
-v, --version         Show version
-h, --help            Show help
```

## How it works

1. Stages all changes (`git add -A`, unless `--no-add`)
2. Sends the diff to Claude
3. Gets back a conventional commit message
4. Commits with that message

## License

MIT
