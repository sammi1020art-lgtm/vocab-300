# 一鍵發布到 GitHub（需先完成 gh 登入）
$ErrorActionPreference = "Stop"
$git = "$env:USERPROFILE\.local\tools\MinGit\cmd\git.exe"
$gh  = "$env:USERPROFILE\.local\tools\gh\bin\gh.exe"

if (-not (Test-Path $git)) { Write-Error "找不到 Git，請先執行 Cursor 內的發布流程或安裝 Git for Windows" }
if (-not (Test-Path $gh))  { Write-Error "找不到 GitHub CLI" }

Set-Location $PSScriptRoot

# 檢查 GitHub 登入
& $gh auth status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "請在瀏覽器完成 GitHub 登入..." -ForegroundColor Yellow
    & $gh auth login -h github.com -p https -w
}

$repoName = "vocab-300"
Write-Host "建立公開 repo: $repoName 並推送..." -ForegroundColor Cyan
& $gh repo create $repoName --public --source=. --remote=origin --push --description "英文300單字學習遊戲 - 字卡/連連看/拼字/聽力/口說"

if ($LASTEXITCODE -eq 0) {
  Write-Host "`n啟用 GitHub Pages..." -ForegroundColor Cyan
  & $gh api -X POST "repos/{owner}/$repoName/pages" -f build_type=legacy -f source[branch]=main -f source[path]=/ 2>$null
  if ($LASTEXITCODE -ne 0) {
    Write-Host "請至 GitHub → Settings → Pages → Branch 選 main / (root)" -ForegroundColor Yellow
  }
  $url = & $gh repo view --json url -q .url
  Write-Host "`n✅ 發布完成！" -ForegroundColor Green
  Write-Host "Repo: $url"
  Write-Host "Pages（啟用後約 1-2 分鐘）: $($url -replace 'github.com','github.io') "
}
