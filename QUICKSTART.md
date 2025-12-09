# AdByBy-Open 快速开始指南

## 🚀 一键获取编译版本

### 方法1：直接下载（推荐）

1. **访问Releases页面**
   - 打开：https://github.com/tekintian/adbyby-open/releases
   - 下载最新版本的 `adbyby-open-*.tar.gz`

2. **解压并使用**
   ```bash
   tar -xzf adbyby-open-*.tar.gz
   cd adbyby-open/
   # adbyby 就是编译好的可执行文件
   ```

### 方法2：从Actions下载

1. **访问Actions页面**
   - 打开：https://github.com/tekintian/adbyby-open/actions
   - 点击最新的构建任务

2. **下载Artifacts**
   - 在页面下方找到 "Artifacts" 部分
   - 下载 `adbyby-open-*.tar.gz`

## 📦 安装到路由器

### 自动安装（如果包含安装脚本）
```bash
# 上传到路由器后
./install_adbyby.sh
```

### 手动安装
```bash
# 1. 创建目录
mkdir -p /usr/share/adbyby
mkdir -p /usr/share/adbyby/data
mkdir -p /usr/share/adbyby/doc

# 2. 复制主程序
cp adbyby /usr/share/adbyby/
chmod +x /usr/share/adbyby/adbyby

# 3. 复制配置和数据文件
cp -r share/* /usr/share/adbyby/
chmod +x /usr/share/adbyby/*.sh

# 4. 复制配置脚本
cp *.sh /etc_ro/ 2>/dev/null || true
```

## 🔧 启动服务

```bash
# 启动AdByBy
/usr/share/adbyby/adbyby

# 或使用脚本
/usr/bin/adbyby.sh
```

## ✅ 验证安装

1. **检查进程**
   ```bash
   ps | grep adbyby
   ```

2. **检查端口**
   ```bash
   netstat -an | grep 8118
   ```

3. **测试代理**
   - 浏览器设置代理：`路由器IP:8118`
   - 访问网站查看是否过滤广告

## 📋 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| `adbyby` | 主程序（MIPS架构） |
| `share/` | 配置文件和规则库 |
| `share/data/` | 规则数据文件 |
| `share/*.sh` | 管理脚本 |
| `*.sh` | 根目录配置脚本 |
| `VERSION.txt` | 版本和构建信息 |

## ⚙️ 基本配置

### 修改代理端口（默认8118）
```bash
# 编辑启动脚本
vi /usr/share/adbyby/adbyby.sh

# 修改 -p 参数
./adbyby -p 8080
```

### 更新规则库
```bash
# 使用更新脚本
/usr/share/adbyby/adbybyupdate.sh

# 或手动下载更新
/usr/share/adbyby/adupdate.sh
```

## 🛠️ 常见问题

### 1. 程序无法启动
```bash
# 检查架构
file /usr/share/adbyby/adbyby
# 应显示：ELF 32-bit LSB executable, MIPS, ...

# 检查权限
ls -la /usr/share/adbyby/adbyby
# 确保有执行权限
```

### 2. 端口被占用
```bash
# 查看占用进程
netstat -an | grep 8118

# 修改端口
./adbyby -p 8080
```

### 3. 规则不生效
```bash
# 检查规则文件
ls -la /usr/share/adbyby/data/

# 重新加载规则
kill -HUP `cat /var/run/adbyby.pid`
```

## 🔄 更新版本

1. **下载新版本**
   ```bash
   wget https://github.com/tekintian/adbyby-open/releases/latest/download/adbyby-open-*.tar.gz
   ```

2. **备份配置**
   ```bash
   cp -r /usr/share/adbyby/share /tmp/adbyby_backup
   ```

3. **替换程序**
   ```bash
   # 停止服务
   killall adbyby
   
   # 替换主程序
   cp adbyby /usr/share/adbyby/
   chmod +x /usr/share/adbyby/adbyby
   ```

4. **重启服务**
   ```bash
   /usr/share/adbyby/adbyby &
   ```

## 📞 获取帮助

- **项目主页**: https://github.com/tekintian/adbyby-open
- **问题反馈**: https://github.com/tekintian/adbyby-open/issues
- **详细文档**: 查看 `README.md` 和 `CI-README.md`

---

**提示**: 如果遇到问题，请先查看日志文件或运行调试模式：
```bash
/usr/share/adbyby/adbyby -d --no-daemon
```