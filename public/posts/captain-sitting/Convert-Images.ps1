Add-Type -AssemblyName System.Drawing

$targetDir = "c:\Users\capts\Desktop\myyacht\content\posts\captain-sitting"
$files = @("captain-chair.png", "bearing-guide.png")
$maxWidth = 1200
$quality = 85

function Get-JpegCodec {
    $codecs = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()
    foreach ($codec in $codecs) {
        if ($codec.MimeType -eq "image/jpeg") {
            return $codec
        }
    }
    return $null
}

$jpegCodec = Get-JpegCodec
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $quality)

foreach ($file in $files) {
    $filepath = Join-Path $targetDir $file
    if (Test-Path $filepath) {
        Write-Host "Converting $file..."
        try {
            $img = [System.Drawing.Image]::FromFile($filepath)
            
            # Calculate new size
            $newWidth = $img.Width
            $newHeight = $img.Height
            if ($img.Width -gt $maxWidth) {
                $newWidth = $maxWidth
                $newHeight = [math]::Round($img.Height * ($maxWidth / $img.Width))
            }

            # Create new bitmap
            $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graph = [System.Drawing.Graphics]::FromImage($bmp)
            $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
            $img.Dispose()

            # Save as JPG
            $newFilepath = $filepath -replace "\.png$", ".jpg"
            $bmp.Save($newFilepath, $jpegCodec, $encoderParams)
            
            $bmp.Dispose()
            $graph.Dispose()
            
            Write-Host "Created $newFilepath"
            
            # Delete original PNG
            Remove-Item $filepath
            Write-Host "Deleted original $file"
        }
        catch {
            Write-Host "Error processing $file : $_"
        }
    } else {
        Write-Host "File not found: $filepath"
    }
}
