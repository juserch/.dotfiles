# 本机（jserver）的用户级约定

本文件由 dotfiles 管理（`~/.dotfiles/vm-arm64/.claude/CLAUDE.md`，软链到 `~/.claude/CLAUDE.md`），对本机所有 Claude Code 会话生效。

## 公共基建

本机有一套公共基建（MySQL · PostgreSQL · S3 对象存储 · StarRocks · k3s · 指标 / 日志 / 链路平台），本机与宿主上的项目共用，由 owner 维护。
**用法、地址、申请方式看 `~/infra/README.md`**；非机密连接参数在 `~/infra/endpoints.env`（只读，owner 推送，勿改）。

- ⛔ 不把 `~/infra/` 里的地址、端口写死进任何仓库：用环境变量；仓库默认配置不依赖本机基建（开源项目的外部贡献者没有它）。
- ⛔ 不改基建组件；要库 / 账号 / 桶 / 命名空间 / 端口，写申请给 owner。
- 只放合成或公开数据；口令与钥匙只放项目本地、未入库的 `.env`。
- `~/infra/` 不存在或与实际不符时告诉 owner，⛔ 不要自己猜地址。
