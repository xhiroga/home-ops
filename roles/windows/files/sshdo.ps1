# sshdo.ps1 - SSH command dispatcher for Windows (inspired by raforg/sshdo)
#
# Deployed to C:\ProgramData\ssh\sshdo.ps1 via Ansible (homelab/home-ops).
# Command implementations live in C:\ProgramData\ssh\sshdo.d\ and are
# deployed per-application as <label>.json + <label>\*.ps1.
#
# authorized_keys entry format:
#   restrict,command="powershell -NoProfile -File C:\ProgramData\ssh\sshdo.ps1 <label>" ssh-ed25519 AAAA...
#
# The label identifies which sshdo.d\<label>.json to load.
# $SSH_ORIGINAL_COMMAND holds the subcommand the client requested.
# "help" (or empty) returns the JSON command list.

param([string]$Label)

$ErrorActionPreference = 'Stop'

if (-not $Label) {
    Write-Error "sshdo: label required (set via command= in authorized_keys)"
    exit 1
}

$SshdoDir = "C:\ProgramData\ssh\sshdo.d"
$commandsFile = Join-Path $SshdoDir "$Label.json"

if (-not (Test-Path $commandsFile)) {
    Write-Error "sshdo: no config for label '$Label' ($commandsFile not found)"
    exit 1
}

$commands = Get-Content $commandsFile -Raw | ConvertFrom-Json

$cmd = $env:SSH_ORIGINAL_COMMAND
if (-not $cmd) { $cmd = 'help' }
$cmd = $cmd.Trim()

if ($cmd -eq 'help') {
    $commands | ForEach-Object { Write-Output $_ }
    exit 0
}

if ($commands -notcontains $cmd) {
    Write-Error "sshdo: not permitted: '$cmd'"
    exit 2
}

Invoke-Expression $cmd
exit $LASTEXITCODE
