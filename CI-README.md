# GitHub CI/CD 使用说明

## 概述

本项目配置了完整的GitHub Actions CI/CD流程，用于自动编译AdByBy程序并发布到GitHub。

## 工作流程说明

### 1. 自动构建工作流 (`.github/workflows/build.yml`)

**触发条件：**
- 推送到 `main` 或 `master` 分支
- 创建Pull Request
- 创建Release
- 手动触发

**执行步骤：**
1. 检出代码
2. 安装构建环境
3. 下载MIPS交叉编译工具链
4. 编译AdByBy程序
5. 打包发布包
6. 上传构建产物
7. 自动创建GitHub Release

### 2. 版本发布工作流 (`.github/workflows/release.yml`)

**触发条件：**
- 推送版本标签（如 `v1.0.0`、`v2.1.3`）

**执行步骤：**
1. 检出代码
2. 设置构建环境
3. 下载交叉编译工具链
4. 编译程序
5. 创建发布包
6. 生成校验和
7. 创建GitHub Release

## 使用方法

### 方法一：自动构建（推荐）

1. **推送代码触发构建**
   ```bash
   git push origin main
   ```

2. **查看构建状态**
   - 访问项目的Actions页面
   - 查看构建日志和结果

3. **下载构建产物**
   - 从Actions页面下载 `adbyby-open-*.tar.gz`
   - 或从Release页面下载

### 方法二：标签发布

1. **创建版本标签**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **自动触发发布流程**
   - GitHub Actions会自动构建并创建Release

3. **下载发布版本**
   - 访问项目的Releases页面
   - 下载对应版本的压缩包

### 方法三：手动触发

1. **访问Actions页面**
   - 进入项目的Actions标签页
   - 选择"Build and Release AdByBy"工作流

2. **手动运行工作流**
   - 点击"Run workflow"按钮
   - 选择分支并确认运行

## 构建产物说明

### 压缩包内容
每个构建会生成 `adbyby-open-{版本号}-mipsel.tar.gz`，包含：

```
adbyby-open/
├── adbyby                 # 主程序（MIPS架构）
├── *.sh                   # 根目录脚本文件
├── *.conf                 # 配置文件（如果有）
├── install.sh             # 安装脚本
├── README.md              # 说明文档
├── VERSION.txt            # 版本信息
└── share/                 # 共享资源目录
    ├── *.conf             # 配置文件
    ├── *.sh               # 脚本文件
    ├── data/              # 数据文件目录
    └── doc/               # 文档目录
```

### 文件说明
- **adbyby**: 编译后的主程序，适用于MIPS架构路由器
- **VERSION.txt**: 包含构建信息（版本、日期、提交哈希等）
- **share/**: AdByBy运行所需的配置文件、规则文件等
- **checksums.txt**: 文件的SHA256校验和，用于验证文件完整性

## 本地测试

如果需要在本地测试构建流程：

```bash
# 1. 克隆项目
git clone https://github.com/tekintian/adbyby-open.git
cd adbyby-open

# 2. 下载工具链
wget https://github.com/tekintian/padavan/releases/download/toolchain/mipsel-linux-musl.tar.xz
tar -xf mipsel-linux-musl.tar.xz

# 3. 设置环境变量
export CROSS_COMPILE=$PWD/toolchain/bin/mipsel-linux-musl-
export PATH=$PWD/toolchain/bin:$PATH

# 4. 编译
make clean
make compile

# 5. 验证结果
file adbyby  # 应该显示 ELF 32-bit LSB executable, MIPS, ...
```

## 故障排除

### 常见问题

1. **编译失败**
   - 检查工具链是否正确下载
   - 检查交叉编译器是否可用
   - 查看构建日志中的错误信息

2. **下载失败**
   - 检查网络连接
   - 确认工具链URL是否可访问

3. **发布失败**
   - 检查GitHub Token权限
   - 确认仓库设置允许创建Release

### 调试方法

1. **查看详细日志**
   - 在Actions页面点击具体的构建任务
   - 查看每个步骤的详细输出

2. **本地复现**
   - 使用相同的工具链和环境
   - 在本地执行相同的构建命令

3. **检查环境**
   - 确认Ubuntu版本兼容性
   - 检查依赖包是否正确安装

## 最佳实践

1. **版本管理**
   - 使用语义化版本号（如 `v1.0.0`）
   - 在发布前确保代码测试通过

2. **提交信息**
   - 编写清晰的提交信息
   - 在发布时会包含在Release说明中

3. **构建优化**
   - 避免不必要的文件被打包
   - 确保生成的包大小合理

4. **安全考虑**
   - 定期更新依赖的Actions版本
   - 检查第三方工具链的安全性

## 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Padavan 工具链](https://github.com/tekintian/padavan/releases)
- [项目主仓库](https://github.com/tekintian/adbyby-open)

## 技术支持

如有问题，请：
1. 查看Actions构建日志
2. 搜索已有的Issues
3. 创建新的Issue并提供详细信息