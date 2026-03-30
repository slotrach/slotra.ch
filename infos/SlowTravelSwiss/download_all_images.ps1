# Simple image download script
$notesData = Get-Content "notes_summary.json" -Raw | ConvertFrom-Json
$imagesDir = "images"

# Create images directory
if (-not (Test-Path $imagesDir)) {
    New-Item -ItemType Directory -Path $imagesDir -Force
}

# Headers for requests
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Referer" = "https://www.xiaohongshu.com/"
}

$total = 0
$success = 0
$failed = 0

Write-Host "Starting image download..."
Write-Host "Total notes: $($notesData.notes.Count)"

foreach ($note in $notesData.notes) {
    $noteId = $note.noteId
    Write-Host "Processing note: $noteId"
    
    if ($note.images.Count -gt 0) {
        $imageIndex = 0
        foreach ($img in $note.images) {
            $imageUrl = $img.src
            if (-not $imageUrl) {
                Write-Host "  No image URL"
                continue
            }
            
            $total++
            
            # Determine file extension
            $ext = ".jpg"
            if ($imageUrl -match '\.(webp|png|jpeg|jpg|gif)') {
                $ext = ".$($matches[1])"
            }
            
            # Generate filename
            if ($imageIndex -eq 0) {
                $filename = "$noteId$ext"
            } else {
                $filename = "${noteId}_$imageIndex$ext"
            }
            
            $outputPath = Join-Path $imagesDir $filename
            
            # Check if already exists
            if (Test-Path $outputPath) {
                Write-Host "  Already exists: $filename"
                $success++
                $imageIndex++
                continue
            }
            
            try {
                Write-Host "  Downloading: $filename"
                Invoke-WebRequest -Uri $imageUrl -Headers $headers -OutFile $outputPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                Write-Host "  Downloaded: $filename"
                $success++
                
                # Sleep to avoid rate limiting
                Start-Sleep -Milliseconds 500
                
            } catch {
                Write-Host "  Failed: $filename - $($_.Exception.Message)"
                $failed++
            }
            
            $imageIndex++
        }
    } else {
        Write-Host "  No images for this note"
    }
}

Write-Host "`nDownload summary:"
Write-Host "Total images: $total"
Write-Host "Success: $success"
Write-Host "Failed: $failed"