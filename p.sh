#!/bin/bash
set -e

# ============================================================
# p.sh — 打包 IPA + 上传蒲公英 (PGYER)
# 用法: ./p.sh
# ============================================================

PGYER_API_KEY="8baa9f795fef0b47c1736cb89bdaa191"
PGYER_PASSWORD="yushi"

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

PROJECT="IDTest4.xcodeproj"
SCHEME="IDTest4"
CONFIG="Release"
ARCHIVE_PATH="./build/IDTest4.xcarchive"
EXPORT_DIR="./build"
EXPORT_PLIST="./ExportOptions.plist"
UPLOAD_SCRIPT="./pgyer_upload.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ---- 1. 打包 IPA ----
log_info "开始 Archive..."

xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -archivePath "$ARCHIVE_PATH" \
    -destination 'generic/platform=iOS' \
    -allowProvisioningUpdates \
    -quiet 2>&1 | tail -5

log_info "Archive 完成 ✅"

log_info "导出 IPA..."

xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -allowProvisioningUpdates \
    -quiet 2>&1 | tail -5

IPA_FILE="$EXPORT_DIR/$SCHEME.ipa"

if [[ ! -f "$IPA_FILE" ]]; then
    log_error "IPA 未生成: $IPA_FILE"
    exit 1
fi

log_info "IPA 已生成: $IPA_FILE ($(du -h "$IPA_FILE" | cut -f1))"

# ---- 2. 上传蒲公英 ----
if [[ ! -f "$UPLOAD_SCRIPT" ]]; then
    log_error "上传脚本不存在: $UPLOAD_SCRIPT"
    log_error "请先将 pgyer_upload.sh 放到项目根目录"
    exit 1
fi

log_info "开始上传蒲公英..."
bash "$UPLOAD_SCRIPT" -k "$PGYER_API_KEY" -t 2 -p "$PGYER_PASSWORD" "$IPA_FILE"

log_info "全部完成 🎉"
