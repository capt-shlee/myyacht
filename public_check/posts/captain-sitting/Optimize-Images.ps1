Add-Type -AssemblyName System.Drawing

$targetDir = "c:\Users\capts\Desktop\myyacht\content\posts\captain-sitting"
$files = @("captain-chair.png", "bearing-guide.png")
$maxWidth = 1200
$quality = 85

foreach ($file in $files) {
    $filepath = Join-Path $targetDir $file
    if (Test-Path $filepath) {
        Write-Host "Processing $file..."
        try {
            # Load original image
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
            
            # Dispose original image to release file lock, but we need to save to a temp file first
            $img.Dispose()
            
            # Save optimized image
            # For simplicity, saving as JPEG to reduce size drastically, but need to check if transparency matters.
            # PNG compression in .NET is tricky. Let's save as JPG for photos.
            # However, original is PNG. If transparency is not needed (photos), convert to JPG.
            # If transparency needed, keep PNG but resize.
            
            # Since these are photos ("captain-sitting"), JPG is better.
            # Change extension to .jpg for better compression? Or keep .png but optimized?
            # User has file references in md as .png. I should keep .png if possible, or update md.
            # Updating md is better for web performance (jpg is smaller for photos).
            # But let's try to save as PNG first to avoid changing md references if not necessary,
            # though PNG optimization in .NET isn't great.
            
            # Let's save as PNG for now to be safe with references.
            $bmp.Save($filepath, [System.Drawing.Imaging.ImageFormat]::Png)
            
            $bmp.Dispose()
            $graph.Dispose()
            
            Write-Host "Optimized $file"
        }
        catch {
            Write-Host "Error processing $file : $_"
        }
    } else {
        Write-Host "File not found: $filepath"
    }
}
