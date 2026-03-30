# 图片下载脚本 - 修复版本
param()

# 读取笔记数据
$notesJson = Get-Content "notes_summary.json" -Raw | ConvertFrom-Json
$imagesDir = "images"
$totalNotes = $notesJson.notes.Count
$totalImages = 0
$downloadedImages = 0
$failedImages = 0

# 创建图片目录
if (-not (Test-Path $imagesDir)) {
    New-Item -ItemType Directory -Path $imagesDir -Force
}

# 请求头
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    "Referer" = "https://www.xiaohongshu.com/"
    "Accept" = "image/webp,image/apng,image/*,*/*;q=0.8"
    "Accept-Language" = "zh-CN,zh;q=0.9,en;q=0.8"
}

Write-Host "开始下载图片..." -ForegroundColor Cyan
Write-Host "总帖子数: $totalNotes" -ForegroundColor White

foreach ($note in $notesJson.notes) {
    $noteId = $note.noteId
    $noteTitle = $note.title.Substring(0, [Math]::Min(30, $note.title.Length))
    
    Write-Host "`n处理帖子: $noteId" -ForegroundColor Cyan
    Write-Host "标题: $noteTitle..." -ForegroundColor Gray
    
    if ($note.images.Count -gt 0) {
        Write-Host "图片数: $($note.images.Count)" -ForegroundColor Gray
        
        $imageIndex = 0
        foreach ($img in $note.images) {
            $imageUrl = $img.src
            if (-not $imageUrl -or $imageUrl -eq "") {
                Write-Host "  无有效图片URL" -ForegroundColor Yellow
                continue
            }
            
            $totalImages++
            
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
                Write-Host "  已存在: $filename" -ForegroundColor Green
                $downloadedImages++
                $imageIndex++
                continue
            }
            
            try {
                Write-Host "  下载中: $filename" -ForegroundColor Gray
                
                # 下载图片
                $response = Invoke-WebRequest -Uri $imageUrl -Headers $headers -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                
                # 保存文件
                [System.IO.File]::WriteAllBytes($outputPath, $response.Content)
                
                Write-Host "  ✓ 下载完成: $filename" -ForegroundColor Green
                $downloadedImages++
                
                # 避免请求过快
                Start-Sleep -Milliseconds 300
                
            } catch {
                Write-Host "  ✗ 下载失败: $filename" -ForegroundColor Red
                Write-Host "    错误: $($_.Exception.Message)" -ForegroundColor DarkRed
                $failedImages++
            }
            
            $imageIndex++
        }
    } else {
        Write-Host "  此帖子无图片" -ForegroundColor Yellow
    }
}

Write-Host "`n下载总结:" -ForegroundColor Cyan
Write-Host "总帖子数: $totalNotes" -ForegroundColor White
Write-Host "总图片数: $totalImages" -ForegroundColor White
Write-Host "成功下载: $downloadedImages" -ForegroundColor Green
Write-Host "下载失败: $failedImages" -ForegroundColor Red

if ($failedImages -gt 0) {
    Write-Host "`n注意: 部分图片下载失败，可能原因包括：" -ForegroundColor Yellow
    Write-Host "1. 网络连接问题" -ForegroundColor Yellow
    Write-Host "2. 图片链接失效" -ForegroundColor Yellow
    Write-Host "3. 服务器限制" -ForegroundColor Yellow
}

Write-Host "`n所有文件保存在: $imagesDir" -ForegroundColor Cyan