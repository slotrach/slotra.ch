# Create Markdown files for each note
$notesData = Get-Content "notes_summary.json" -Raw | ConvertFrom-Json
$postsDir = "posts"

# Create posts directory
if (-not (Test-Path $postsDir)) {
    New-Item -ItemType Directory -Path $postsDir -Force
}

Write-Host "Creating Markdown files for $($notesData.notes.Count) notes..."

foreach ($note in $notesData.notes) {
    $noteId = $note.noteId
    $title = $note.title
    $text = $note.text
    $publishDate = $note.publishDate
    $href = $note.href
    
    # Create filename from note ID and title
    $safeTitle = $title -replace '[<>:"/\\|?*]', '' -replace '\s+', '_'
    $filename = "${noteId}_${safeTitle}.md"
    if ($filename.Length -gt 100) {
        $filename = "${noteId}.md"
    }
    
    $filePath = Join-Path $postsDir $filename
    
    # Prepare Markdown content
    $mdContent = @"
# $title

## 基本信息
- **笔记ID**: $noteId
- **发布时间**: $(if ($publishDate) { $publishDate } else { "未知" })
- **原文链接**: [$href]($href)
- **抓取时间**: 2026-03-30

## 内容
$text

## 图片
"@
    
    # Add image information
    if ($note.images.Count -gt 0) {
        $imageIndex = 0
        foreach ($img in $note.images) {
            $imageUrl = $img.src
            $imageAlt = $img.alt
            $width = $img.width
            $height = $img.height
            
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
            
            $mdContent += @"

### 图片 $($imageIndex + 1)
- **本地文件**: $localFilename
- **原始URL**: $imageUrl
- **尺寸**: ${width}×${height}像素
- **描述**: $(if ($imageAlt) { $imageAlt } else { "无描述" })

![$imageAlt]($localImagePath)

"@
            $imageIndex++
        }
    } else {
        $mdContent += @"

此帖子无图片

"@
    }
    
    # Add footer
    $mdContent += @"

---

*此文件为自动化抓取生成，内容来自小红书博主 [Slow Travel Swiss](https://www.xiaohongshu.com/user/profile/64891d960000000011001e8f)*
*用户ID: 2209308345*
*抓取时间: 2026-03-30*
"@
    
    # Write Markdown file
    $mdContent | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "Created: $filename"
}

Write-Host "`nCreated $($notesData.notes.Count) Markdown files in '$postsDir' directory"