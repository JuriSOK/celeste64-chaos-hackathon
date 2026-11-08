param(
    [string]$Dotnet = "$env:USERPROFILE\.dotnet\dotnet.exe",
    [string]$Chrome = 'C:\devin\chrome\chrome-win64',
    [ValidateSet('A', 'B', 'C', 'D')][string[]]$Versions = @('A', 'B', 'C', 'D')
)
$ErrorActionPreference = 'Stop'
if (Get-Process Celeste64 -ErrorAction SilentlyContinue) { throw 'Close Celeste64 before building.' }
if (!(Test-Path $Dotnet)) { throw "Install .NET SDK 10.0.403 or pass -Dotnet: $Dotnet" }
if (!(Test-Path "$Chrome\vulkan-1.dll")) { throw "Missing Vulkan loader in $Chrome" }
$repo = Split-Path $PSScriptRoot -Parent
$builds = 'C:\Users\Administrator\celeste64-builds'
New-Item -ItemType Directory -Force $builds | Out-Null
foreach ($version in $Versions) {
    $id = $version.ToUpperInvariant()
    $branch = "build-$($version.ToLowerInvariant())"
    $tree = Join-Path $builds $branch
    if (!(Test-Path $tree)) {
        & git -C $repo worktree add $tree $branch
        if ($LASTEXITCODE) { throw "Could not create $branch worktree." }
    }
    $actual = & git -C $tree branch --show-current
    if ($LASTEXITCODE -or $actual -ne $branch) { throw "Expected branch $branch in $tree" }
    foreach ($name in @('bin', 'obj')) {
        $path = Join-Path $tree $name
        if (Test-Path $path) { Remove-Item -LiteralPath $path -Recurse -Force }
    }
    & $Dotnet restore "$tree\Celeste64.csproj" --source https://api.nuget.org/v3/index.json
    if ($LASTEXITCODE) { throw "Restore failed: $id" }
    & $Dotnet build "$tree\Celeste64.csproj" -c Release --no-restore '-p:IncludeSourceRevisionInInformationalVersion=false' "-p:PathMap=$tree=/_/Celeste64"
    if ($LASTEXITCODE) { throw "Build failed: $id" }
    $output = "$tree\bin\Release\net10.0\win-x64"
    Copy-Item "$Chrome\vulkan-1.dll" "$output\vulkan-1.dll" -Force
    if (!(Test-Path "$tree\Content\Levels.json")) { throw "Missing Content: $tree" }
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path ([Environment]::GetFolderPath('Desktop')) "Celeste 64 - $id.lnk"))
    $shortcut.TargetPath = "$tree\hackathon\Launch-Celeste64-$id.cmd"
    $shortcut.WorkingDirectory = "$tree\hackathon"
    $shortcut.Description = 'Celeste 64 demo'
    $shortcut.IconLocation = "$output\Celeste64.exe,0"
    $shortcut.Save()
    Write-Host "Built $id ($branch): $output\Celeste64.exe"
}
Write-Host 'Selected builds and desktop shortcuts are ready.'
