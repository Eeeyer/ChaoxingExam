# EEEYER Installer for Windows
# =============================
# Pipe install (PowerShell):
#   irm https://raw.githubusercontent.com/Eeeyer/ChaoxingExam/main/install.ps1 | iex
#
# Or download and run:
#   .\install.ps1

param(
    [switch]$NoBanner,
    [switch]$DevMode,
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$REPO_ARCHIVE = "https://github.com/Eeeyer/ChaoxingExam/archive/refs/heads/$Branch.zip"
$INSTALL_DIR = "$env:USERPROFILE\.eeeeyr"
$VENV_DIR = "$INSTALL_DIR\venv"
$EEEYER_BIN = "$INSTALL_DIR\er.bat"

# ── Banner ────────────────────────────────────────────────────────────────────

function Show-Banner {
    $Y = [ConsoleColor]::Yellow
    $D = [ConsoleColor]::DarkYellow

    Write-Host ""
    Write-Host "    ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $D
    Write-Host "    ║                                                              ║" -ForegroundColor $D
    Write-Host "    ║     ███████╗ ███████╗ ███████╗ ██╗   ██╗ ███████╗ ██████╗   ║" -ForegroundColor $Y
    Write-Host "    ║     ██╔════╝ ██╔════╝ ██╔════╝ ╚██╗ ██╔╝ ██╔════╝ ██╔══██╗  ║" -ForegroundColor $Y
    Write-Host "    ║     █████╗   █████╗   █████╗    ╚████╔╝  █████╗   ██████╔╝  ║" -ForegroundColor $Y
    Write-Host "    ║     ██╔══╝   ██╔══╝   ██╔══╝     ╚██╔╝   ██╔══╝   ██╔══██╗  ║" -ForegroundColor $Y
    Write-Host "    ║     ███████╗ ███████╗ ███████╗    ██║    ███████╗ ██╔══██╗  ║" -ForegroundColor $Y
    Write-Host "    ║     ╚══════╝ ╚══════╝ ╚══════╝    ╚═╝    ╚══════╝ ╚═╝  ╚═╝  ║" -ForegroundColor $Y
    Write-Host "    ║                                                              ║" -ForegroundColor $D
    Write-Host "    ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $D
    Write-Host ""
}

# ── Utility functions ──────────────────────────────────────────────────────────

function Write-Step {
    param([string]$Message)
    Write-Host "  [✔] " -NoNewline -ForegroundColor Green
    Write-Host $Message -ForegroundColor White
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [i] " -NoNewline -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [!] " -NoNewline -ForegroundColor Yellow
    Write-Host $Message -ForegroundColor Yellow
}

# ── Check prerequisites ────────────────────────────────────────────────────────

Write-Host ""
Write-Host "  EEEYER Installer" -ForegroundColor Yellow
Write-Host "  ================" -ForegroundColor DarkYellow
Write-Host "  超星考试辅助工具 · Exam Helper" -ForegroundColor Gray
Write-Host ""

$pythonCmd = $null
try {
    $pyVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $pythonCmd = "python"
    }
} catch {
    try {
        $pyVersion = python3 --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = "python3"
        }
    } catch {}
}

if (-not $pythonCmd) {
    Write-Host "  [X] 未检测到 Python，请先安装 Python 3.8+" -ForegroundColor Red
    Write-Host ""
    Write-Host "  下载地址: https://www.python.org/downloads/" -ForegroundColor Gray
    Write-Host "  安装时请勾选 'Add Python to PATH'" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

$pyVersionStr = & $pythonCmd --version 2>&1
Write-Step "检测到 $pyVersionStr"

try {
    $null = & $pythonCmd -m pip --version 2>&1
    Write-Step "pip 可用"
} catch {
    Write-Warn "pip 未安装，正在尝试安装..."
    & $pythonCmd -m ensurepip --upgrade 2>&1
}

# ── Install EEEYER ──────────────────────────────────────────────────────────

Write-Info "安装目录: $INSTALL_DIR"

if (-not (Test-Path $INSTALL_DIR)) {
    New-Item -ItemType Directory -Path $INSTALL_DIR -Force | Out-Null
}

if ($DevMode) {
    $srcPath = $PSScriptRoot
    if (-not $srcPath) { $srcPath = (Get-Location).Path }
    Write-Info "开发模式: 从本地复制 $srcPath ..."
} else {
    $zipFile = "$env:TEMP\eeeeyr.zip"
    $extractDir = "$env:TEMP\eeeeyr-extract"

    Write-Info "正在下载 EEEYER..."

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        (New-Object System.Net.WebClient).DownloadFile($REPO_ARCHIVE, $zipFile)
    } catch {
        Write-Host "  [X] 下载失败，请检查网络连接后重试。" -ForegroundColor Red
        exit 1
    }
    Write-Step "下载完成"

    if (Test-Path $extractDir) {
        Remove-Item -Recurse -Force $extractDir
    }
    Expand-Archive -Path $zipFile -DestinationPath $extractDir -Force
    Write-Step "解压完成"

    $srcDir = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
    $srcPath = $srcDir.FullName
}

Write-Info "正在安装到 $INSTALL_DIR ..."
robocopy "$srcPath" "$INSTALL_DIR" /E /NFL /NDL /NJH /NJS /nc /ns /np 2>&1 | Out-Null
Write-Step "文件复制完成"

Write-Info "正在创建虚拟环境..."
& $pythonCmd -m venv "$VENV_DIR" 2>&1 | Out-Null
Write-Step "虚拟环境已创建"

Write-Info "正在安装依赖..."
$pipExe = "$VENV_DIR\Scripts\pip.exe"
if (Test-Path "$INSTALL_DIR\requirements.txt") {
    cmd /c "`"$pipExe`" install -r `"$INSTALL_DIR\requirements.txt`" --quiet >nul 2>&1"
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "pip 失败，正在重试..."
        & $pythonCmd -m pip install -r "$INSTALL_DIR\requirements.txt" --quiet 2>&1 | Out-Null
    }
} else {
    cmd /c "`"$pipExe`" install requests rich --quiet >nul 2>&1"
}
Write-Step "依赖安装完成"

Write-Info "正在安装 EEEYER..."
$oldEAP = $ErrorActionPreference
$ErrorActionPreference = "Continue"
& $VENV_DIR\Scripts\pip.exe install -e "$INSTALL_DIR" --quiet 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Warn "pip install -e 失败，换用 PYTHONPATH 方式"
}
$ErrorActionPreference = $oldEAP
Write-Step "EEEYER 安装完成"

# ── Create wrapper ──────────────────────────────────────────────────────────

$wrapperContent = @"
@echo off
chcp 65001 >nul 2>&1
set PYTHONPATH=$INSTALL_DIR;%PYTHONPATH%
call "$VENV_DIR\Scripts\python.exe" -m eeeeyr %*
"@

Set-Content -Path $EEEYER_BIN -Value $wrapperContent -Encoding ASCII
Write-Step "启动脚本已创建: $EEEYER_BIN"

# ── Add to PATH ──────────────────────────────────────────────────────────────

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$INSTALL_DIR*") {
    Write-Info "正在添加到用户 PATH..."
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$userPath;$INSTALL_DIR",
        "User"
    )
    $env:Path = "$env:Path;$INSTALL_DIR"
    Write-Step "已添加到 PATH"
} else {
    Write-Info "PATH 中已存在 EEEYER"
}

# ── Cleanup ──────────────────────────────────────────────────────────────────

if (-not $DevMode) {
    Remove-Item -Force $zipFile -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force $extractDir -ErrorAction SilentlyContinue
}

# ── Show banner & finish ─────────────────────────────────────────────────────

if (-not $NoBanner) {
    Show-Banner
}

Write-Host "  EEEYER 安装完成!" -ForegroundColor Green
Write-Host ""
Write-Host "  使用方法:" -ForegroundColor White
Write-Host "    er              " -NoNewline -ForegroundColor Yellow
Write-Host "显示完整界面" -ForegroundColor Gray
Write-Host "    er login        " -NoNewline -ForegroundColor Yellow
Write-Host "登录超星账号" -ForegroundColor Gray
Write-Host "    er exam list    " -NoNewline -ForegroundColor Yellow
Write-Host "查看可用考试" -ForegroundColor Gray
Write-Host "    er search <关键词>" -NoNewline -ForegroundColor Yellow
Write-Host "搜索题库" -ForegroundColor Gray
Write-Host ""
Write-Host "  提示: 重新打开终端窗口即可直接使用 'er' 命令" -ForegroundColor DarkGray
Write-Host ""
