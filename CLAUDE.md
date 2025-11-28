# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action for executing remote SSH commands. Built using a composite action pattern, it downloads and runs the [drone-ssh](https://github.com/appleboy/drone-ssh) binary (written in Go) to execute SSH commands on remote hosts.

**Key characteristics:**

- No local compilation required - downloads pre-built binaries from drone-ssh releases
- Shell-based composite action using `entrypoint.sh`
- Supports password and SSH key authentication, proxies, multiple hosts, and environment variable passing
- All input parameters are passed via `INPUT_*` environment variables

## Architecture

### Execution Flow

1. **action.yml** - GitHub Actions composite action definition
   - Defines all input parameters and their descriptions
   - Sets up environment variables with `INPUT_*` prefix
   - Calls `entrypoint.sh`

2. **entrypoint.sh** - Main entry point
   - Detects platform (Linux/Darwin/Windows) and architecture (amd64/arm64)
   - Downloads appropriate `drone-ssh` binary from GitHub releases
   - Executes the binary with all environment variables
   - Handles `capture_stdout` for output capture

3. **drone-ssh binary** - The actual SSH client (separate Go project)
   - Performs SSH connection and command execution
   - Not part of this repository

### Key Files

- `action.yml` - Action metadata and input/output definitions
- `entrypoint.sh` - Platform detection, binary download, and execution
- `testdata/` - Test scripts and SSH keys for CI workflows
- `.github/workflows/main.yml` - Comprehensive test suite using Docker containers (tests `./` local action)
- `.github/workflows/stable.yml` - Tests against published `appleboy/ssh-action@v1` tag
- `.github/workflows/trivy-scan.yml` - Automated security scanning for vulnerabilities and misconfigurations

## Testing

### Running Tests

Tests run automatically via GitHub Actions workflows. The test suite uses Docker containers running OpenSSH servers:

```bash
# Tests run automatically on push via .github/workflows/main.yml
# Tests create Docker containers with openssh-server and test various scenarios
```

### Test Categories (from main.yml)

The test workflow covers:

- **default-user-name-password**: Basic password authentication
- **check-ssh-key**: RSA key authentication, key priority over password
- **support-key-passphrase**: Encrypted SSH keys
- **multiple-server**: Multiple hosts with different ports
- **support-ed25519-key**: ED25519 key format
- **testing-with-env**: Environment variable passing, `allenvs`, custom formats
- **testing06**: IPv6 connectivity
- **testing07**: Special characters in passwords
- **testing-capturing-output**: Output capture functionality
- **testing-script-stop**: Script error handling with `set -e`
- **testing-script-error**: Error propagation

### Testing Locally

Since this action downloads binaries, local testing should:

1. Create a test SSH server (Docker or VM)
2. Test `entrypoint.sh` directly with appropriate `INPUT_*` environment variables

Example:

```bash
export INPUT_HOST="192.168.1.100"
export INPUT_USERNAME="testuser"
export INPUT_PASSWORD="testpass"
export INPUT_PORT="22"
export INPUT_SCRIPT="whoami"
export GITHUB_ACTION_PATH="$(pwd)"
./entrypoint.sh
```

## Important Patterns

### Script Execution

Users can provide scripts in two ways:

- `script`: Inline commands (via `INPUT_SCRIPT`)
- `script_path`: Path to a file in the repository (maps to `INPUT_SCRIPT_FILE` env var - note the naming difference)

### Error Handling

To stop execution on first error (mimics removed `script_stop` option), users should add `set -e` to their scripts:

```yaml
script: |
  #!/usr/bin/env bash
  set -e
  command1
  command2
```

### Environment Variables

The action passes GitHub Action inputs as environment variables with `INPUT_*` prefix. The drone-ssh binary reads these to configure SSH behavior.

Special handling:

- `envs`: Comma-separated list of environment variables to pass to remote script
- `allenvs`: Pass all `GITHUB_*` and `INPUT_*` variables
- `envs_format`: Custom format for environment variable export (e.g., `export TEST_{NAME}={VALUE}`)

### Multiple Hosts

- Comma-separated hosts: `"host1,host2"` (executes in parallel by default)
- With custom ports: `"host1:2222,host2:5678"`
- Synchronous execution: Set `sync: true`

## Common Issues

### Command Not Found

Non-interactive shells may skip `.bashrc`/`.bash_profile`. See README section "Command not found" for details. Solutions:

- Use absolute paths in commands
- Comment out early return in `/etc/bash.bashrc`

### OpenSSH Compatibility

Ubuntu 20.04+ may require enabling `ssh-rsa` algorithm in sshd_config:

```txt
CASignatureAlgorithms +ssh-rsa
```

Or use ED25519 keys instead (preferred).

## Development Guidelines

### Adding New Parameters

1. Add input definition to `action.yml` with description
2. Add corresponding `INPUT_*` environment variable mapping in `action.yml` runs.steps
3. Update README.md parameter tables
4. The drone-ssh binary handles the actual parameter logic (separate repo)

### Documentation

- Keep parameter tables in README.md synchronized with `action.yml`
- Maintain Chinese translations (README.zh-cn.md, README.zh-tw.md)
- Use clear examples for each feature

### Version Management

The action pins to specific drone-ssh versions via:

- Default: `DRONE_SSH_VERSION="1.8.2"` in `entrypoint.sh`
- Override: Users can specify `version` input parameter

Update the default version when new drone-ssh releases are available.

## Release Process

This action uses semantic versioning with major version tags:

- Tags: `v1.0.0`, `v1.0.1`, etc.
- Major version tag: `v1` (points to latest v1.x.x)
- Users reference: `uses: appleboy/ssh-action@v1`

GoReleaser config (`.goreleaser.yaml`) is present but set to `skip: true` since this action doesn't build Go code - it downloads pre-built binaries.
