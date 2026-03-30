# Simple script to create markdown files
$notesData = Get-Content "notes_summary.json" -Raw | ConvertFrom-Json
$postsDir = "posts"

# Create posts directory
if (-not (Test-Path $postsDir)) {
    New-Item -ItemType Directory -Path $postsDir -Force
}

Write-Host "Creating Markdown files..."

foreach ($note in $notesData.notes) {
    $noteId = $note.noteId
    $title = $note.title
    $text = $note.text
    $publishDate = $note.publishDate
    $href = $note.href
    
    # Create simple filename
    $filename = "$noteId.md"
    $filePath = Join-Path $postsDir $filename
    
    # Start building content
    $content = "# $title`n`n"
    $content += "## Basic Info`n"
    $content += "- **Note ID**: $noteId`n"
    $content += "- **Publish Date**: "
    if ($publishDate) {
        $content += "$publishDate`n"
    } else {
        $content += "Unknown`n"
    }
    $content += "- **Original Link**: [$href]($href)`n"
    $content += "- **Scraped Time**: 2026-03-30`n`n"
    
    $content += "## Content`n"
    $content += "$text`n`n"
    
    $content += "## Images`n"
    
    if ($note.images.Count -gt 0) {
        $imageIndex = 0
        foreach ($img in $note.images) {
            $imageUrl = $img.src
            
            # Determine local image filename
            $ext = ".jpg"
            if ($imageUrl -match '\.(webp|png|jpeg|jpg|gif)') {
                $ext = ".$($matches[1])"
            }
            
            if ($imageIndex -eq 0) {
                $localFilename = "$noteId$ext"
            } else {
                $localFilename = "${noteId}_$imageIndex$ext"
            }
            
            $localImagePath = "../images/$localFilename"
            
            $content += "### Image $($imageIndex + 1)`n"
            $content += "- **Local File**: $localFilename`n"
            $content += "- **Original URL**: $imageUrl`n"
            $content += "- **Dimensions**: $($img.width)×$($img.height) pixels`n"
            $content += "- **Alt Text**: "
            if ($img.alt) {
                $content += "$($img.alt)`n"
            } else {
                $content += "None`n"
            }
            $content += "![]($localImagePath)`n`n"
            
            $imageIndex++
        }
    } else {
        $content += "No images in this post`n`n"
    }
    
    $content += "---`n"
    $content += "*Automatically scraped from Xiaohongshu blogger [Slow Travel Swiss](https://www.xiaohongshu.com/user/profile/64891d960000000011001e8f)*`n"
    $content += "*User ID: 2209308345*`n"
    $content += "*Scraped: 2026-03-30*`n"
    
    # Write file
    $content | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "Created: $filename"
}

Write-Host "`nDone! Created $($notesData.notes.Count) markdown files."