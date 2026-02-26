<#
.SYNOPSIS
  Build an Open Graph image in 1200x630 without hard-cropping the subject.
.DESCRIPTION
  Creates a 1200x630 canvas, paints a soft backdrop from the source image,
  then places the full source image in "contain" mode to avoid destructive crop.
.PARAMETER InputPath
  Source image path.
.PARAMETER OutputPath
  Output image path.
.PARAMETER Width
  Canvas width. Default: 1200.
.PARAMETER Height
  Canvas height. Default: 630.
.PARAMETER BackgroundHex
  Fallback background color. Default: #0A192F.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [int]$Width = 1200,
    [int]$Height = 630,
    [string]$BackgroundHex = "#0A192F"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function Convert-HexToColor {
    param([string]$Hex)

    $value = $Hex.Trim().TrimStart('#')
    if ($value.Length -ne 6) {
        throw "BackgroundHex must be #RRGGBB format."
    }

    $r = [Convert]::ToInt32($value.Substring(0, 2), 16)
    $g = [Convert]::ToInt32($value.Substring(2, 2), 16)
    $b = [Convert]::ToInt32($value.Substring(4, 2), 16)
    return [System.Drawing.Color]::FromArgb(255, $r, $g, $b)
}

function Get-JpegCodec {
    [System.Drawing.Imaging.ImageCodecInfo]::GetImageDecoders() |
        Where-Object { $_.MimeType -eq "image/jpeg" } |
        Select-Object -First 1
}

$inFull = (Resolve-Path $InputPath).Path
$outFull = [System.IO.Path]::GetFullPath($OutputPath)
$outDir = [System.IO.Path]::GetDirectoryName($outFull)
if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

$bgColor = Convert-HexToColor -Hex $BackgroundHex

$src = $null
$canvas = $null
$g = $null
$imgAttrs = $null
$overlayBrush = $null
$pen = $null

try {
    $src = [System.Drawing.Image]::FromFile($inFull)
    $canvas = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear($bgColor)

    # 1) Backdrop fill (cover) with low alpha
    $coverScale = [Math]::Max(([double]$Width / [double]$src.Width), ([double]$Height / [double]$src.Height))
    $coverW = [int][Math]::Ceiling([double]$src.Width * $coverScale)
    $coverH = [int][Math]::Ceiling([double]$src.Height * $coverScale)
    $coverX = [int][Math]::Floor(([double]$Width - [double]$coverW) / 2.0)
    $coverY = [int][Math]::Floor(([double]$Height - [double]$coverH) / 2.0)

    $imgAttrs = New-Object System.Drawing.Imaging.ImageAttributes
    $matrix = New-Object System.Drawing.Imaging.ColorMatrix
    $matrix.Matrix33 = 0.32
    $imgAttrs.SetColorMatrix($matrix, [System.Drawing.Imaging.ColorMatrixFlag]::Default, [System.Drawing.Imaging.ColorAdjustType]::Bitmap)

    $destRect = New-Object System.Drawing.Rectangle($coverX, $coverY, $coverW, $coverH)
    $g.DrawImage($src, $destRect, 0, 0, $src.Width, $src.Height, [System.Drawing.GraphicsUnit]::Pixel, $imgAttrs)

    $overlayBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(92, $bgColor))
    $g.FillRectangle($overlayBrush, 0, 0, $Width, $Height)

    # 2) Foreground contain (no hard crop)
    $maxW = [int][Math]::Floor([double]$Width * 0.88)
    $maxH = [int][Math]::Floor([double]$Height * 0.88)
    $fitScale = [Math]::Min(([double]$maxW / [double]$src.Width), ([double]$maxH / [double]$src.Height))
    $drawW = [int][Math]::Round([double]$src.Width * $fitScale)
    $drawH = [int][Math]::Round([double]$src.Height * $fitScale)
    $drawX = [int][Math]::Floor(([double]$Width - [double]$drawW) / 2.0)
    $drawY = [int][Math]::Floor(([double]$Height - [double]$drawH) / 2.0)

    $g.DrawImage($src, $drawX, $drawY, $drawW, $drawH)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(140, 255, 255, 255), 1)
    $g.DrawRectangle($pen, $drawX, $drawY, $drawW - 1, $drawH - 1)

    $ext = [System.IO.Path]::GetExtension($outFull).ToLowerInvariant()
    if ($ext -eq ".jpg" -or $ext -eq ".jpeg") {
        $codec = Get-JpegCodec
        $enc = [System.Drawing.Imaging.Encoder]::Quality
        $encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($enc, [int64]92)
        $canvas.Save($outFull, $codec, $encParams)
        $encParams.Dispose()
    }
    elseif ($ext -eq ".png") {
        $canvas.Save($outFull, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    elseif ($ext -eq ".webp") {
        throw "WEBP output is not supported by System.Drawing. Use .jpg or .png."
    }
    else {
        throw "Unsupported output extension: $ext"
    }
}
finally {
    if ($pen) { $pen.Dispose() }
    if ($overlayBrush) { $overlayBrush.Dispose() }
    if ($imgAttrs) { $imgAttrs.Dispose() }
    if ($g) { $g.Dispose() }
    if ($canvas) { $canvas.Dispose() }
    if ($src) { $src.Dispose() }
}

$final = [System.Drawing.Image]::FromFile($outFull)
try {
    Write-Host ("Generated OG image: {0} ({1}x{2})" -f $outFull, $final.Width, $final.Height) -ForegroundColor Green
}
finally {
    $final.Dispose()
}
