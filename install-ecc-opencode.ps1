# install-ecc-opencode.ps1
# Installs Everything Claude Code (ECC) into OpenCode on Windows.
# Requirements: Git, Node.js (LTS), OpenCode. Close OpenCode before running.
# Run with:  powershell -ExecutionPolicy Bypass -File .\install-ecc-opencode.ps1

$ErrorActionPreference = 'Stop'
$ecc = "$HOME\ecc"
$cfg = "$HOME\.config\opencode"

function Fail($msg) { Write-Host "ERROR: $msg" -ForegroundColor Red; exit 1 }
function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# 1. Check requirements
Step "Checking requirements"
foreach ($tool in 'git', 'node', 'npm') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { Fail "$tool is not installed or not on PATH." }
}
if (Get-Process opencode -ErrorAction SilentlyContinue) { Fail "OpenCode is running. Close it and run this script again." }

# 2. Back up existing OpenCode config
if (Test-Path $cfg) {
    $backup = "opencode.bak-" + (Get-Date -Format yyyyMMddHHmmss)
    Step "Backing up existing config to $HOME\.config\$backup"
    Rename-Item $cfg $backup
}

# 3. Get ECC (clone or update)
if (Test-Path "$ecc\.git") {
    Step "Updating existing ECC repo in $ecc"
    git -C $ecc pull
} else {
    Step "Cloning ECC into $ecc"
    git clone https://github.com/affaan-m/everything-claude-code.git $ecc
}
if ($LASTEXITCODE -ne 0) { Fail "Git failed." }
Set-Location $ecc

# 4. Install dependencies and build the OpenCode payload
Step "Installing dependencies"
npm install --ignore-scripts --no-audit --no-fund --loglevel=error
if ($LASTEXITCODE -ne 0) { Fail "npm install failed." }

Step "Building OpenCode plugin payload"
npm run build:opencode
if ($LASTEXITCODE -ne 0) { Fail "Build failed." }

# 5. Install into ~/.config/opencode
Step "Installing ECC for OpenCode"
powershell -ExecutionPolicy Bypass -File .\install.ps1 --target opencode --modules commands-core,platform-configs,workflow-quality,hooks-runtime --enable-hooks
if ($LASTEXITCODE -ne 0) { Fail "ECC installer failed." }

# 6. Disable hook plugins (not compatible with the current OpenCode plugin format yet)
Step "Disabling hook plugins"
if (Test-Path "$cfg\plugins") { Move-Item "$cfg\plugins" "$cfg\plugins.disabled" -Force }
if (Test-Path "$cfg\opencode.json") {
    node -e "const fs=require('fs');const f=process.argv[1];const j=JSON.parse(fs.readFileSync(f,'utf8'));delete j.plugin;fs.writeFileSync(f,JSON.stringify(j,null,2));" "$cfg\opencode.json"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Could not edit opencode.json automatically. Open it and delete the `"plugin`" block by hand:" -ForegroundColor Yellow
        Write-Host "  notepad $cfg\opencode.json" -ForegroundColor Yellow
    }
}

Step "Done"
Write-Host "Start OpenCode in a project folder and type / to see the commands." -ForegroundColor Green
