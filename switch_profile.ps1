param (
    [string]$ProfileName = "identity.toml",
    [switch]$Build = $false
)

$ProfilePath = Join-Path $PSScriptRoot "profiles\$ProfileName"

if (-Not (Test-Path $ProfilePath)) {
    Write-Host "Error: Profile $ProfilePath not found!" -ForegroundColor Red
    exit 1
}

$env:PROFILE_PATH = $ProfilePath
Write-Host "Set PROFILE_PATH to $env:PROFILE_PATH" -ForegroundColor Green

# Simple TOML parser to extract process_name
$processName = "rustdesk.exe"
$content = Get-Content $ProfilePath
foreach ($line in $content) {
    if ($line -match '^\s*process_name\s*=\s*"([^"]+)"') {
        $processName = $matches[1]
        break
    }
}

# Ensure it has .exe extension
if (-not $processName.EndsWith(".exe", [System.StringComparison]::OrdinalIgnoreCase)) {
    $processName += ".exe"
}

Write-Host "Target Process Name: $processName" -ForegroundColor Cyan

if ($Build) {
    Write-Host "Building RustDesk with dynamic identity..." -ForegroundColor Yellow
    
    # Automatically set LIBCLANG_PATH for bindgen if it's not set
    if (-not $env:LIBCLANG_PATH) {
        $clangPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\Llvm\x64\bin"
        if (Test-Path "$clangPath\libclang.dll") {
            $env:LIBCLANG_PATH = $clangPath
            Write-Host "Set LIBCLANG_PATH to $clangPath" -ForegroundColor Cyan
        }
    }

    # Clean the build script out directory to force hbb_common build script to rerun
    # This ensures identity_constants.rs is regenerated with the new profile
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" clean -p hbb_common
    
    & "$env:USERPROFILE\.cargo\bin\cargo.exe" build --release --features inline
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }

    $sourcePath = Join-Path $PSScriptRoot "target\release\rustdesk.exe"
    $destPath = Join-Path $PSScriptRoot "target\release\$processName"

    if (Test-Path $sourcePath) {
        if (Test-Path $destPath) {
            Remove-Item -Force $destPath
        }
        Rename-Item -Path $sourcePath -NewName $processName
        Write-Host "Successfully built and renamed binary to: target\release\$processName" -ForegroundColor Green
    } else {
        Write-Host "Warning: Build succeeded but $sourcePath was not found." -ForegroundColor Yellow
    }
} else {
    Write-Host "Run with -Build to compile the project."
}
