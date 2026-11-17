param(
    [switch]$Uninstall,
    [switch]$Reinstall
)

$ErrorActionPreference = 'Stop'

$launchFnc = "
function pi {
    # Run the container and forward any passed arguments (@args)
    wslc run --rm -v ${PWD}:/workspace -v pi-data:/root/.pi -w /workspace -it pi-agent pi @args
}
"

function setup-pi {

    try{
        Get-Command wslc > $null
    } catch {
        throw "WSLC not installed, run: wsl --install --no-distribution; wsl --update"
    }

    $Dockerfile = Resolve-Path $PSScriptRoot

    $volumes = wslc volume ls 2>$null

    if ($Reinstall){
        wslc build --no-cache -t pi-agent $Dockerfile
    } else {
        if ($volumes -match '\bpi-agent\b') {throw "A pi-agent image already exists, remove the old image first: wslc image remove pi-agent"}
        wslc build -t pi-agent $Dockerfile
    }

    # Check if 'pi-data' already exists to avoid creation errors
    $volumes = wslc volume ls 2>$null
    if ($volumes -notmatch '\bpi-data\b') {
        wslc volume create pi-data
    }

    if (Test-Path $PROFILE){
        Add-Content -Path $PROFILE -Value $launchFnc
    } else {
        New-Item -Path $PROFILE -ItemType "File" -Force
        Set-Content -Path $PROFILE -Value $launchFnc
    }

    . $PROFILE

    Write-Host "Pi container set up with persistent profile" -ForegroundColor Green
}

function remove-pi {
    $volumes = wslc volume ls 2>$null
    if ($volumes -match '\bpi-data\b') {
        wslc volume remove pi-data
    }

    $images = wslc image ls 2>$null
    if ($volumes -match '\bpi-agent\b') {
        wslc image remove pi-agent
    }

    $profileContent = Get-Content -Path $PROFILE -Raw

    # Escape special regex characters
    $escapedFnc = [regex]::Escape($launchFnc)

    # Check and remove (plus any trailing newline)
    if ($profileContent -match "(?s)$escapedFnc") {
        $updatedContent = $profileContent -replace "(?s)$escapedFnc(\r?\n)?", ""
        Set-Content -Path $PROFILE -Value $updatedContent -NoNewline
    }

    . $PROFILE

    Write-Host "Pi container and storage removed" -ForegroundColor Green
}

function pi {
    # Run the container and forward any passed arguments (@args)
    wslc run --rm -v C:\Users\josep\Documents\GitHub\pi-setup:/workspace -v pi-data:/root/.pi -w /workspace -it pi-agent pi @args
}


if ($Uninstall) {remove-pi}
elseif ($Reinstall) {
    remove-pi
    setup-pi
}
else {setup-pi}
