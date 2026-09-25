#!/bin/sh
# 验收三件套的唯一来源：Stop hook、pre-commit、Definition-of-Done 都调用这个脚本。
# kit 不规定语言和工具链。新项目由 project-init skill 在技术选型确定后填写本文件。
# 规则：任何一步失败即非 0 退出；删除下面的 UNCONFIGURED 两行即视为已配置。

echo "verify.sh 尚未配置（运行 project-init 或手动填写），暂时跳过验收。" >&2
exit 0  # UNCONFIGURED

set -e
# 在这里写本项目的 lint / 类型检查 / 测试命令，例如：
#   npm run lint -- --max-warnings 0 && npx tsc --noEmit && npm test
#   swiftlint --strict && xcodebuild test -scheme <Scheme> -destination '<dest>' -quiet
#   ruff check . && mypy . && pytest -q
#   cargo clippy -- -D warnings && cargo test
#   go vet ./... && go test ./...
