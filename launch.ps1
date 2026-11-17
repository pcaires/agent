$ErrorActionPreference = "Stop"

function setup-pi {

    $Dockerfile = Resolve-Path $PSScriptRoot

    wslc build -t pi-agent $Dockerfile

    # Check if 'pi-data' already exists to avoid creation errors
    $volumes = wslc volume ls 2>$null
    if ($volumes -notmatch '\bpi-data\b') {
        wslc volume create pi-data
    }

}

function pi {
    # Run the container and forward any passed arguments (@args)
    wslc run --rm -v ${PWD}:/workspace -v pi-data:/root/.pi -w /workspace -it pi-agent pi @args
}
