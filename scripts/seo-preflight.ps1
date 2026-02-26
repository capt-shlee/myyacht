<#
.SYNOPSIS
  SEO preflight checks for MyYacht before deployment.
.DESCRIPTION
  Runs local SEO guard checks and optional live status checks.
.PARAMETER BaseUrl
  Live site base URL for status checks.
.PARAMETER SkipLive
  Skip live URL status checks.
#>

param(
    [string]$BaseUrl = "https://myyacht.kr",
    [switch]$SkipLive
)

$ErrorActionPreference = "Stop"
$failures = New-Object System.Collections.Generic.List[string]

function Write-Pass([string]$msg) { Write-Host "[PASS] $msg" -ForegroundColor Green }
function Write-Fail([string]$msg) {
    Write-Host "[FAIL] $msg" -ForegroundColor Red
    $failures.Add($msg) | Out-Null
}

function Test-RgPattern {
    param(
        [string]$Pattern,
        [string[]]$Paths,
        [string]$FailMessage,
        [string]$PassMessage,
        [string[]]$ExtraArgs = @()
    )

    $args = @("-n") + $ExtraArgs + @($Pattern) + $Paths
    $out = & rg @args 2>$null
    if ($LASTEXITCODE -eq 0 -and $out) {
        Write-Fail $FailMessage
        Write-Host $out
    }
    else {
        Write-Pass $PassMessage
    }
}

Write-Host "=== SEO Preflight Started ===" -ForegroundColor Cyan

# 1) Forbidden tags frontmatter check
Test-RgPattern `
    -Pattern '^[ \t]*tags[ \t]*:' `
    -Paths @('content/posts') `
    -FailMessage 'posts frontmatter에 tags: 필드가 남아 있습니다.' `
    -PassMessage 'posts frontmatter의 tags: 필드가 없습니다.' `
    -ExtraArgs @('--hidden', '--glob', '!**/.git/**')

# 2) Localhost leakage in source
Test-RgPattern `
    -Pattern 'https?://(localhost|127\.0\.0\.1)|\blocalhost:[0-9]+\b|127\.0\.0\.1:[0-9]+' `
    -Paths @('content', 'layouts', 'static', 'hugo.toml') `
    -FailMessage '소스에 localhost/127.0.0.1 흔적이 있습니다.' `
    -PassMessage '소스에 localhost 흔적이 없습니다.' `
    -ExtraArgs @('--hidden', '--glob', '!**/.git/**')

# 3) Hugo validation build
try {
    hugo --renderToMemory --panicOnWarning | Out-Null
    Write-Pass 'hugo --renderToMemory --panicOnWarning 통과'
}
catch {
    Write-Fail 'hugo 검증 빌드 실패'
}

# 4) Build public output for static checks
try {
    hugo | Out-Null
    Write-Pass 'hugo 정식 빌드 완료'
}
catch {
    Write-Fail 'hugo 정식 빌드 실패'
}

# 5) Localhost leakage in generated output
if (Test-Path 'public') {
    Test-RgPattern `
        -Pattern 'https?://(localhost|127\.0\.0\.1)|\blocalhost:[0-9]+\b|127\.0\.0\.1:[0-9]+' `
        -Paths @('public') `
        -FailMessage '생성물(public)에 localhost 흔적이 있습니다.' `
        -PassMessage '생성물(public)에 localhost 흔적이 없습니다.'
}
else {
    Write-Fail 'public 폴더가 없습니다. hugo 빌드를 확인하세요.'
}

# 6) Tags route generation check
if (Test-Path 'public/tags') {
    Write-Fail 'public/tags 경로가 생성되었습니다. tags taxonomy 정책 위반입니다.'
}
else {
    Write-Pass 'public/tags 경로가 생성되지 않았습니다.'
}

if (Test-Path 'public/sitemap.xml') {
    $sitemap = [System.IO.File]::ReadAllText((Resolve-Path 'public/sitemap.xml'), [System.Text.Encoding]::UTF8)
    if ($sitemap -match '/tags/') {
        Write-Fail 'sitemap.xml에 /tags/ URL이 포함되어 있습니다.'
    }
    else {
        Write-Pass 'sitemap.xml에 /tags/ URL이 없습니다.'
    }
}
else {
    Write-Fail 'public/sitemap.xml 파일이 없습니다.'
}

# 7) Live deprecated URL checks (optional)
if (-not $SkipLive) {
    $deprecated = @(
        '/tags/',
        '/tags/captains-log/',
        '/home/',
        '/tour/',
        '/club/',
        '/contact/',
        '/my-yacht-tour/',
        '/my-yacht-club/'
    )

    foreach ($path in $deprecated) {
        $url = "$($BaseUrl.TrimEnd('/'))$path"
        $code = curl.exe -s -o NUL -w "%{http_code}" $url
        if ($code -eq '404') {
            Write-Pass "$url => 404"
        }
        else {
            Write-Fail "$url => expected 404, got $code"
        }
    }
}

Write-Host "=== SEO Preflight Result ===" -ForegroundColor Cyan
if ($failures.Count -gt 0) {
    Write-Host ("Failed checks: {0}" -f $failures.Count) -ForegroundColor Red
    exit 1
}

Write-Host 'All checks passed.' -ForegroundColor Green
exit 0
