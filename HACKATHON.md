# H Company x 42AI: Celeste 64 demo

Private, noncommercial demo fork of https://github.com/EXOK/Celeste64 at
`6edfe1ebd2a21a6134d7675a28e357891025407e`.
The original game is by Maddy Makes Games and the creators credited in ReadMe.md.
We claim no authorship of their game, content, or third-party libraries.

## Licensing and privacy

Keep this demo repository private; this is a distribution requirement, not a
restriction imposed by the MIT source license. Source/License.txt licenses source
under MIT, copyright 2024 Maddy Makes Games, Inc., except where otherwise noted.
Preserve all notices. The Celeste IP and Content belong to Maddy Makes Games,
Inc. and are not covered by that MIT permission. Upstream permits noncommercial
mods, levels and fan games with clear non-endorsement. This demo is not made by or
endorsed by the Celeste team. Source/Audio/FMOD has separate Firelight Technologies
notices and FMOD terms. All upstream notices remain unchanged.

## Builds

The four build IDs are A, B, C and D. Their branches are build-a through build-d,
with annotated snapshots demo-a through demo-d. Each uses its own worktree under
`C:\Users\Administrator\celeste64-builds\build-<id>` and independent bin/obj.

Use .NET SDK 10.0.403 at `%USERPROFILE%\.dotnet\dotnet.exe`. The project targets
net10.0; restore uses https://api.nuget.org/v3/index.json explicitly.
Run `powershell -NoProfile -ExecutionPolicy Bypass -File hackathon\Build-All.ps1`.
Optional `-Versions A,B` selects IDs when calling the script from PowerShell.
The script replaces generated bin/obj, builds Release, maps debug source paths,
omits revision hashes from product metadata, and creates four matching shortcuts.

## Launch and saves

Use desktop shortcuts **Celeste 64 - A**, **B**, **C**, **D**, or the matching
`hackathon\Launch-Celeste64-<ID>.ps1` / `.cmd` wrapper. Optional `-Fresh` archives
that build's save directory before starting a new session. Omit it to preserve
progress. Only one game or launcher may run at a time.

Each launcher waits for the game and restores the exact prior save junction,
original directory, or absent state on exit, including launch failures. Keep its
console open until the game exits. Forcibly terminating the launcher prevents
cleanup. Do not manually alter the junction during play.

Windows preferences use SDL_GetPrefPath, not an APPDATA environment override.
The launcher temporarily connects the roaming Celeste64 directory to
`C:\Users\Administrator\Celeste64-saves\build-<id>`.
Save files are save.json / save.json.backup, bindings controls.json; runtime logs
are stdout.log / stderr.log. Existing original directories are preserved.

This VM uses Vulkan with Chrome SwiftShader from
`C:\devin\chrome\chrome-win64`. The build script copies vulkan-1.dll beside each
executable; no renderer binaries are committed. This is software rendering, not
hardware-accelerated performance. VM paths can be overridden with build parameters.

## Controls

Arrows move; WASD orbits the camera; C/Space jumps; X dashes; Z/V/Shift/Ctrl climbs.
C confirms menus. Escape/Enter pauses; Retry restarts at the current checkpoint.
Clicking enables mouse-camera mode and WASD movement; Escape exits that mode.
F1 toggles statistics. Alt+F4 closes the game; Save & Quit persists progress.
