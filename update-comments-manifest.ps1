# 扫描图片目录并生成各目录下的 manifest.json，供 index.html 自动加载。
# 覆盖：comments（宝妈评价）、work-photo（工作照片）、show（美食展示）
# 执行：powershell -ExecutionPolicy Bypass -File .\update-comments-manifest.ps1

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$ext = @('.jpg', '.jpeg', '.png', '.webp', '.gif', '.bmp', '.heic', '.heif')

function Write-ImageManifest {
  param(
    [Parameter(Mandatory = $true)]
    [string] $FolderName
  )

  $dir = Join-Path $root $FolderName
  $outFile = Join-Path $dir 'manifest.json'

  if (-not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }

  $files = Get-ChildItem -LiteralPath $dir -File -ErrorAction SilentlyContinue |
    Where-Object { $ext -contains $_.Extension.ToLowerInvariant() -and $_.Name -ne 'manifest.json' } |
    Sort-Object Name

  $rel = [System.Collections.Generic.List[string]]::new()
  foreach ($f in $files) {
    $rel.Add(('{0}/{1}' -f $FolderName, $f.Name).Replace('\', '/'))
  }

  $obj = [ordered]@{ images = @($rel) }
  $json = ($obj | ConvertTo-Json -Compress -Depth 5)
  [System.IO.File]::WriteAllText($outFile, $json, [System.Text.UTF8Encoding]::new($false))
  Write-Host "[$FolderName] 已写入 $($rel.Count) 条: $outFile"
}

Write-ImageManifest -FolderName 'comments'
Write-ImageManifest -FolderName 'work-photo'
Write-ImageManifest -FolderName 'show'
