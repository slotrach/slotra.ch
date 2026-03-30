$notesJson = Get-Content "notes_summary.json" -Raw | ConvertFrom-Json
$imagesDir = "images"
$total = $notesJson.notes.Count
$downloaded = 0
$failed = 0

# 创建图片目录
New-Item -ItemType Directory -Path $imagesDir -Force

$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Referer" = "https://www.xiaohongshu.com/"
    "Accept" = "image/webp,image/apng,image/*,*/*;q=0.8"
    "Accept-Language" = "zh-CN,zh;q=0.9,en;q=0.8"
}

foreach ($note in $notesJson.notes) {
    $noteId = $note.noteId
    Write-Host "Processing note $noteId ($($note.index+1)/$total)" -ForegroundColor Cyan
    
    if ($note.images.Count -gt 0) {
        $imageIndex = 0
        foreach ($img in $note.images) {
            $imageUrl = $img.src
            if (-not $imageUrl) {
                Write-Host "  No image URL" -ForegroundColor Yellow
                continue
            }
            
            # 确定文件扩展名
            $ext = ".jpg"
            if ($imageUrl -match '\.(webp|png|jpeg|jpg|gif)') {
                $ext = ".$($matches[1])"
            }
            
            # 生成文件名
            if ($imageIndex -eq 0) {
                $filename = "$noteId$ext"
            } else {
                $filename = "${noteId}_$imageIndex$ext"
            }
            
            $outputPath = Join-Path $imagesDir $filename
            
            # 检查是否已存在
            if (Test-Path $outputPath) {
                Write-Host "  Already exists: $filename" -ForegroundColor Green
                $downloaded++
                $imageIndex++
                continue
            }
            
            try {
                Write-Host "  Downloading: $filename" -ForegroundColor Gray
                Invoke-WebRequest -Uri $imageUrl -Headers $headers -OutFile $outputPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                Write-Host "  ✓ Downloaded: $filename" -ForegroundColor Green
                $downloaded++
                
                # 避免请求过快
                Start-Sleep -Milliseconds 500
                
            } catch {
                Write-Host "  ✗ Failed to download $filename : $($_.Exception.Message)" -ForegroundColor Red
                $failed++
            }
            
            $imageIndex++
        }
    } else {
        Write-Host "  No images for this note" -ForegroundColor Yellow
    }
}

Write-Host "`nDownload summary:" -ForegroundColor Cyan
Write-Host "  Total notes: $total" -ForegroundColor White
Write-Host "  Images downloaded: $downloaded" -ForegroundColor Green
Write-Host "  Images failed: $failed" -ForegroundColor Red