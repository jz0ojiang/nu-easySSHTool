# easySSHTool

[README](README.md) | 简体中文

`easySSHTool` 是一个基于 [Nushell](https://www.nushell.sh/) 的 SSH 管理工具，专为多服务器环境下的 SSH 连接管理而设计。通过格式化输出、安全模式、快捷导入等功能，让 SSH 配置与连接更加便捷，尤其适合对 SSH 管理有特定需求的用户。

## 功能简介

- **配置验证**：自动检查配置文件路径（如服务器列表、私钥文件等）是否有效，确保运行环境无误。
- **安全模式**：隐藏敏感信息（如 `host` 和 `username`），适合在公开环境中安全使用。
- **格式化输出**：所有输出内容符合 Nushell 的格式化要求，清晰规整。
- **快捷导入服务器**：支持直接粘贴 SSH 命令以快速导入服务器配置。
- **初步的 Tab 补全**：提供基础校验和补全功能，提升命令输入的流畅性。

## 配置

`easySSHTool` 支持用户自定义以下配置项：

- **server_list**：指定服务器列表文件路径，默认值为 `~/.ssh/servers.json`。
- **pems_dir**：指定 PEM 密钥文件的存储路径，默认值为 `~/.ssh/pems/`。
- **default_identity_file**：默认身份文件路径，用于指定私钥文件有误时的 callback，默认值为 `~/.ssh/id_rsa`。
- **safemode**：安全模式开关，默认开启。安全模式下遮盖 `host` 和 `username`，可通过 `--unsafe` 参数临时关闭。

可根据需求在 `config` 中调整这些路径和选项。

## 安装

1. **克隆仓库**：
   
   ```bash
   git clone https://github.com/jz0ojiang/nu-easySSHTool.git
   ```

2. **在 Nushell 配置文件中加载模块**：
   打开 Nushell 配置文件并添加以下内容：
   
   ```bash
   source path/to/easySSHTool/easySSHTool.nu
   ```

3. **首次启动**：
   初次运行时会自动在 `~/.ssh/servers.json` 创建服务器配置文件（对应 `config` 中 `server_list` 默认路径）。

## 使用说明

### 列出服务器

列出所有已配置的服务器：

```bash
est list
```

### 连接到服务器

使用指定关键字连接到服务器：

```bash
est connect example_keyword
```

### 新增和删除服务器

- **新增服务器**（支持直接粘贴 SSH 命令导入）：
  
  ```bash
  est add example_keyword "ssh username@newhost.com"
  ```

- **删除服务器**：
  
  ```bash
  est remove example_keyword
  ```

### 使用安全模式

默认开启安全模式，隐藏敏感信息。可通过 `--unsafe(-u)` 参数临时关闭：

```bash
est -u list
```

## 未来优化

未来计划增加与 `.ssh/config` 文件的同步，并考虑用 Go 进行重构以提升跨平台性能和运行效率。

## 贡献方式

欢迎对 `easySSHTool` 提出建议并贡献代码！参与方式如下：

1. **Fork 仓库并克隆到本地**。

2. **创建功能分支**：
   
   ```bash
   git checkout -b feature_branch
   ```

3. **提交代码并推送**：
   
   ```bash
   git commit -m "添加新功能"
   git push origin feature_branch
   ```

4. **发起 Pull Request**。

感谢您的支持和贡献！😊




