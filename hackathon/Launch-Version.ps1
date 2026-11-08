param(
    [Parameter(Mandatory = $true)][ValidateSet('A', 'B', 'C', 'D')][string]$Version,
    [switch]$Fresh
)
$ErrorActionPreference = 'Stop'
$mutex = New-Object Threading.Mutex($false, 'Local\Celeste64DemoLauncher')
$locked = $false
$restorePending = $false
$previousTarget = $null
$previousDirectory = $false
try {
    $locked = $mutex.WaitOne(0)
    if (!$locked) { throw 'Another Celeste64 launcher is active.' }
    if (Get-Process Celeste64 -ErrorAction SilentlyContinue) { throw 'Close Celeste64 before switching saves.' }
    $id = $Version.ToUpperInvariant()
    $folder = "build-$($Version.ToLowerInvariant())"
    $exe = "C:\Users\Administrator\celeste64-builds\$folder\bin\Release\net10.0\win-x64\Celeste64.exe"
    $chrome = 'C:\devin\chrome\chrome-win64'
    if (!(Test-Path $exe) -or !(Test-Path (Join-Path (Split-Path $exe) 'vulkan-1.dll'))) { throw 'Run Build-All.ps1 first.' }
    if (!(Test-Path "$chrome\vk_swiftshader_icd.json")) { throw 'Missing Chrome SwiftShader ICD.' }
    $saves = 'C:\Users\Administrator\Celeste64-saves'
    $target = Join-Path $saves $folder
    $link = Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Celeste64'
    $allowed = @('a', 'b', 'c', 'd') | ForEach-Object { Join-Path $saves "build-$_" }
    New-Item -ItemType Directory -Force $saves | Out-Null
    $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
    if ($item) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            if ($item.LinkType -ne 'Junction' -or @($item.Target).Count -ne 1 -or $item.Target[0] -notin $allowed) {
                throw "Refusing to replace unfamiliar link: $link"
            }
            $previousTarget = $item.Target[0]
            & cmd.exe /d /c "rmdir `"$link`""
            if ($LASTEXITCODE) { throw 'Could not remove save junction.' }
            $restorePending = $true
        } else {
            $backup = Join-Path $saves 'original-backup'
            if (Test-Path $backup) { throw "Backup already exists; preserve and resolve $link manually." }
            Move-Item -LiteralPath $link -Destination $backup
            $previousDirectory = $true
            $restorePending = $true
        }
    } else {
        $restorePending = $true
    }
    if ($Fresh -and (Test-Path $target)) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss-ffff'
        Move-Item -LiteralPath $target -Destination "$saves\$folder-before-fresh-$stamp"
    }
    New-Item -ItemType Directory -Force $target | Out-Null
    New-Item -ItemType Junction -Path $link -Target $target | Out-Null
    $env:SDL_GPU_DRIVER = 'vulkan'
    $env:VK_DRIVER_FILES = "$chrome\vk_swiftshader_icd.json"
    $env:VK_ICD_FILENAMES = $env:VK_DRIVER_FILES
    $process = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) -RedirectStandardOutput "$target\stdout.log" -RedirectStandardError "$target\stderr.log" -PassThru
    Write-Host "Launched $id PID $($process.Id); saves: $target"
    $process.WaitForExit()
    Write-Host "$id exited with code $($process.ExitCode)"
} finally {
    try {
        if ($restorePending) {
            $current = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
            if ($current) {
                if ($current.LinkType -ne 'Junction' -or @($current.Target).Count -ne 1 -or $current.Target[0] -ne $target) {
                    throw "Refusing to replace changed save path during restoration: $link"
                }
                & cmd.exe /d /c "rmdir `"$link`""
                if ($LASTEXITCODE) { throw 'Could not remove save junction.' }
            }
            if ($previousTarget) {
                New-Item -ItemType Junction -Path $link -Target $previousTarget | Out-Null
                Write-Host "Restored save junction: $previousTarget"
            } elseif ($previousDirectory) {
                Move-Item -LiteralPath $backup -Destination $link
                Write-Host "Restored original save directory: $link"
            } else {
                Write-Host 'Restored absent save junction.'
            }
        }
    } finally {
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}
