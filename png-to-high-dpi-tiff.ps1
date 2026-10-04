param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$InputFiles
)

# PNG -> high-DPI TIFF converter for Windows.
# Double-click the companion .cmd file, or drag PNG files onto it.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Wait-ForExit {
    if ($env:COMMAND_TOOL_NO_PAUSE -ne '1') {
        [void](Read-Host 'Press Enter to close')
    }
}

function Get-AvailableOutputPath {
    param([Parameter(Mandatory = $true)][string]$InputPath)

    $directory = [System.IO.Path]::GetDirectoryName($InputPath)
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
    $candidate = Join-Path $directory ($stem + '.tiff')
    $suffix = 2

    while (Test-Path -LiteralPath $candidate) {
        $candidate = Join-Path $directory ("{0}_{1}.tiff" -f $stem, $suffix)
        $suffix++
    }

    return $candidate
}

Write-Host ''
Write-Host '========================================'
Write-Host '       PNG -> High-DPI TIFF'
Write-Host '========================================'
Write-Host ''

if (-not $InputFiles -or $InputFiles.Count -eq 0) {
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = 'Choose one or more PNG images'
    $dialog.Filter = 'PNG images (*.png)|*.png'
    $dialog.Multiselect = $true

    if ($dialog.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host 'No PNG files selected.'
        Wait-ForExit
        exit 0
    }

    $InputFiles = $dialog.FileNames
}

$dpiText = $env:TIFF_DPI
if ([string]::IsNullOrWhiteSpace($dpiText)) {
    $dpiText = Read-Host 'Target DPI [default: 600]'
}
if ([string]::IsNullOrWhiteSpace($dpiText)) {
    $dpiText = '600'
}

$targetDpi = 0
if (-not [int]::TryParse($dpiText, [ref]$targetDpi) -or $targetDpi -lt 72 -or $targetDpi -gt 9600) {
    Write-Host 'Invalid DPI. Enter an integer from 72 to 9600.' -ForegroundColor Red
    Wait-ForExit
    exit 1
}

$successCount = 0
$failureCount = 0

foreach ($inputFile in $InputFiles) {
    try {
        $resolved = (Resolve-Path -LiteralPath $inputFile -ErrorAction Stop).Path
        if ([System.IO.Path]::GetExtension($resolved) -ine '.png') {
            throw 'The file is not a PNG image.'
        }

        $outputPath = Get-AvailableOutputPath -InputPath $resolved
        $source = $null
        $bitmap = $null
        $graphics = $null

        try {
            $source = [System.Drawing.Image]::FromFile($resolved)
            $bitmap = New-Object System.Drawing.Bitmap(
                $source.Width,
                $source.Height,
                [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
            )
            $bitmap.SetResolution([single]$targetDpi, [single]$targetDpi)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
            $bitmap.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Tiff)
        }
        finally {
            if ($null -ne $graphics) { $graphics.Dispose() }
            if ($null -ne $bitmap) { $bitmap.Dispose() }
            if ($null -ne $source) { $source.Dispose() }
        }

        Write-Host ("[OK] {0}" -f $outputPath) -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host ("[FAILED] {0}: {1}" -f $inputFile, $_.Exception.Message) -ForegroundColor Red
        $failureCount++
    }
}

Write-Host ''
Write-Host ("Finished: {0} succeeded, {1} failed." -f $successCount, $failureCount)
Write-Host 'TIFF files were saved beside the source PNG files.'
Wait-ForExit

if ($failureCount -gt 0) { exit 1 }
