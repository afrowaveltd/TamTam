$ErrorActionPreference = 'Stop'


# build.ps1 lives in playground/_shared/scripts
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$playgroundRoot = Resolve-Path (Join-Path $scriptDir "..\..")
$asmDir = Join-Path $playgroundRoot "01_bytes-and-dumps\asm"
Set-Location $asmDir


$stage1 = "stage1.bin"
$stage2 = "stage2.bin"
$out = "tamtam.img"


# Assemble stage2 (include from .\lib)
nasm -f bin .\stage2_main.asm -o $stage2 -I .\lib -I .\


$len = (Get-Item $stage2).Length
$sectors = [int][Math]::Ceiling($len / 512.0)
if ($sectors -lt 1) { $sectors = 1 }


# Assemble stage1 with correct stage2 sector count
nasm -f bin .\stage1_boot.asm -o $stage1 -I .\lib -I .\ -D STAGE2_SECTORS=$sectors


# Pad stage2 to full sectors
$pad = $sectors*512 - $len
if ($pad -gt 0) {
$path = Join-Path (Get-Location) $stage2
$fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite)
$fs.Seek(0, [System.IO.SeekOrigin]::End) | Out-Null
$fs.Write((New-Object byte[] $pad), 0, $pad)
$fs.Close()
}


# Build image: stage1 + stage2
[System.IO.File]::WriteAllBytes((Join-Path (Get-Location) $out), [System.IO.File]::ReadAllBytes((Join-Path (Get-Location) $stage1)))
$img = [System.IO.File]::Open((Join-Path (Get-Location) $out), [System.IO.FileMode]::Append)
$img.Write([System.IO.File]::ReadAllBytes((Join-Path (Get-Location) $stage2)), 0, (Get-Item $stage2).Length)
$img.Close()


Write-Host "Stage2 size: $len bytes"
Write-Host "Stage2 sectors: $sectors"
Write-Host "Image: $out (" (Get-Item $out).Length "bytes )"
Write-Host "Run: qemu-system-i386 -drive format=raw,file=.\\tamtam.img"