Add-Type -AssemblyName System.Drawing

$targetDir = "c:\Users\capts\Desktop\myyacht\content\posts\volvo-penta-d2-55-evc-hacking"
$maxWidth = 1200
$quality = 85

# Get all JPG files
$files = Get-ChildItem -Path $targetDir -Filter *.JPG

foreach ($file in $files) {
    $filepath = $file.FullName
    Write-Host "Processing $filepath..."
    
    try {
        # Load original image
        $img = [System.Drawing.Image]::FromFile($filepath)
        
        # Calculate new size
        if ($img.Width -gt $maxWidth) {
            $newWidth = $maxWidth
            $newHeight = [math]::Round($img.Height * ($maxWidth / $img.Width))
            
            # Create new bitmap
            $bmp = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
            $graph = [System.Drawing.Graphics]::FromImage($bmp)
            $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)
            
            # Dispose original image to release file lock
            $img.Dispose()
            
            # Encoder parameters for quality
            $encoder = [System.Drawing.Imaging.Encoder]::Quality
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, $quality)
            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }

            # Save optimized image (overwrite)
            $bmp.Save($filepath, $jpegCodec, $encoderParams)
            
            $bmp.Dispose()
            $graph.Dispose()
            
            Write-Host "Optimized $file.Name to ${newWidth}px width."
        } else {
            Write-Host "Skipping $file.Name (Width: $($img.Width)px is smaller than $maxWidth)"
            $img.Dispose()
        }
    }
    catch {
        Write-Host "Error processing $file : $_"
    }
}
