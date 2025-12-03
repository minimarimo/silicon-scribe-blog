#!/bin/bash

# ==============================================================================
# Script Name: deploy_agent.sh
# Description: DOC 폴더의 내용을 Git 저장소로 푸시하여 블로그를 업데이트함.
# ==============================================================================

# 프로젝트 루트 경로 설정 (이 스크립트는 SCRIPT 폴더 안에 있다고 가정)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOC_DIR="$PROJECT_ROOT/DOC"

# 현재 날짜 및 시간
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[Deploy] 🚀 Starting deployment process..."
echo "[Deploy] Target: $DOC_DIR"

# 1. Git 상태 확인
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "[Deploy] [ERR] Not a git repository. Initialize git first."
    exit 1
fi

# 2. 변경 사항 스테이징 (DOC 폴더와 RTL 폴더만)
cd "$PROJECT_ROOT"
git add DOC/*.md
git add RTL/*.v
git add TB/*.v

# 3. 변경 사항이 있는지 확인
if git diff-index --quiet HEAD --; then
    echo "[Deploy] [INFO] No changes to deploy."
    exit 0
fi

# 4. 커밋 및 푸시
echo "[Deploy] 📦 Committing changes..."
git commit -m "Auto-generated content update: $TIMESTAMP"

echo "[Deploy] ☁️ Pushing to remote..."
# 현재 브랜치 이름 가져오기
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

# 에러 처리를 위한 푸시 시도
if git push origin "$CURRENT_BRANCH"; then
    echo "[Deploy] [SUCCESS] Deployment complete! Your blog is updated."
else
    echo "[Deploy] [FAIL] Push failed. Check your internet connection or remote settings."
    exit 1
fi
