#!/bin/sh
# 把 workflow kit 装进一个项目仓库。已存在的文件不会被覆盖。
# 用法：sh path/to/claude-workflow-kit/install.sh <target-repo>
set -e
KIT=$(cd "$(dirname "$0")" && pwd)
TARGET=${1:?用法: install.sh <target-repo>}
mkdir -p "$TARGET"
cd "$TARGET"
[ -d .git ] || git init -q

copy() { # 不覆盖已有文件，并列出被跳过的文件
  src="$KIT/$1"
  find "$src" -type f ! -name .DS_Store | while read -r f; do
    rel=${f#"$KIT/"}
    if [ -e "$rel" ]; then echo "跳过（已存在，请手动合并）: $rel"
    else mkdir -p "$(dirname "$rel")" && cp "$f" "$rel" && echo "已添加: $rel"; fi
  done
}
copy CLAUDE.md
copy .claude
copy docs
chmod +x .claude/verify.sh .claude/hooks/*.sh 2>/dev/null || true

if [ ! -e .git/hooks/pre-commit ]; then
  printf '#!/bin/sh\nexec .claude/verify.sh\n' > .git/hooks/pre-commit
  chmod +x .git/hooks/pre-commit
  echo "已添加: .git/hooks/pre-commit"
fi
echo
echo "完成。在该目录运行 claude，第一句话：'运行 project-init'（或直接描述你要做的项目）。"
