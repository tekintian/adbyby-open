#!/bin/sh
# AdByBy-Open 安装脚本

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="/usr/share/adbyby"
BIN_DIR="/usr/bin"
CONFIG_DIR="/etc_ro"
BACKUP_DIR="/tmp/adbyby_backup_$(date +%Y%m%d_%H%M%S)"

echo "=== AdByBy-Open 安装程序 ==="
echo "源码目录: $SCRIPT_DIR"
echo "目标目录: $TARGET_DIR"
echo "二进制目录: $BIN_DIR"
echo "配置目录: $CONFIG_DIR"
echo "备份目录: $BACKUP_DIR"

# 检查权限
if [ "$(id -u)" != "0" ]; then
    echo "错误: 需要root权限运行此脚本"
    echo "请使用: sudo $0"
    exit 1
fi

# 检查源文件（检查新结构）
if [ -f "$SCRIPT_DIR/usr/share/adbyby/adbyby" ]; then
    # 新的打包结构
    SOURCE_DIR="$SCRIPT_DIR/usr/share/adbyby"
    BIN_SOURCE="$SCRIPT_DIR/usr/bin/adbyby.sh"
    CONFIG_SOURCE_DIR="$SCRIPT_DIR/etc_ro"
    echo "检测到新的打包结构"
elif [ -f "$SCRIPT_DIR/adbyby" ]; then
    # 旧的结构（兼容性）
    SOURCE_DIR="$SCRIPT_DIR"
    BIN_SOURCE=""
    CONFIG_SOURCE_DIR="$SCRIPT_DIR"
    echo "检测到旧的结构，将进行兼容性安装"
else
    echo "错误: 找不到adbyby程序"
    echo "请确保在正确的目录运行此脚本"
    exit 1
fi

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份原有文件
echo "正在备份原有文件..."
backup_file() {
    local src="$1"
    local dest="$BACKUP_DIR/$(basename "$1")"
    if [ -f "$src" ]; then
        cp "$src" "$dest"
        echo "已备份: $src -> $dest"
    fi
}

# 备份主要文件
backup_file "$TARGET_DIR/adbyby"
backup_file "$BIN_DIR/adbyby.sh"

# 备份配置文件
for file in adbyby_rules.sh adbyby_adblack.sh adbyby_adesc.sh adbyby_adhost.sh adbyby_host.sh adbyby_blockip.sh; do
    backup_file "$CONFIG_DIR/$file"
done

# 备份数据文件
for file in rules.txt user.txt lazy.txt video.txt; do
    backup_file "$TARGET_DIR/data/$file"
done

# 安装程序文件
echo "正在安装程序文件..."
mkdir -p "$TARGET_DIR"
if [ -f "$SOURCE_DIR/adbyby" ]; then
    cp "$SOURCE_DIR/adbyby" "$TARGET_DIR/adbyby"
    chmod +x "$TARGET_DIR/adbyby"
    echo "已安装: $TARGET_DIR/adbyby"
fi

# 安装share目录下的所有文件
if [ -d "$SOURCE_DIR" ]; then
    # 复制配置文件
    for file in adblack.conf adesc.conf adhook.ini adhost.conf blockip.conf rules.txt update.info user.action dnsmasq.adblock dnsmasq.ads dnsmasq.esc firewall.include; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            cp "$SOURCE_DIR/$file" "$TARGET_DIR/"
            echo "已安装: $TARGET_DIR/$file"
        fi
    done
    
    # 复制脚本文件
    for file in adblock.sh adbyby.sh adbybyfirst.sh adbybyupdate.sh admem.sh adupdate.sh; do
        if [ -f "$SOURCE_DIR/$file" ]; then
            cp "$SOURCE_DIR/$file" "$TARGET_DIR/"
            chmod +x "$TARGET_DIR/$file"
            echo "已安装: $TARGET_DIR/$file"
        fi
    done
    
    # 复制data目录
    if [ -d "$SOURCE_DIR/data" ]; then
        mkdir -p "$TARGET_DIR/data"
        cp -r "$SOURCE_DIR/data/"* "$TARGET_DIR/data/"
        echo "已安装: $TARGET_DIR/data/"
    fi
    
    # 复制doc目录
    if [ -d "$SOURCE_DIR/doc" ]; then
        mkdir -p "$TARGET_DIR/doc"
        cp -r "$SOURCE_DIR/doc/"* "$TARGET_DIR/doc/"
        echo "已安装: $TARGET_DIR/doc/"
    fi
fi

# 安装主脚本到/usr/bin/
if [ -n "$BIN_SOURCE" ] && [ -f "$BIN_SOURCE" ]; then
    mkdir -p "$BIN_DIR"
    cp "$BIN_SOURCE" "$BIN_DIR/adbyby.sh"
    chmod +x "$BIN_DIR/adbyby.sh"
    echo "已安装: $BIN_DIR/adbyby.sh"
fi

# 安装配置脚本到/etc_ro/
if [ -n "$CONFIG_SOURCE_DIR" ] && [ -d "$CONFIG_SOURCE_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    for file in adbyby_rules.sh adbyby_adblack.sh adbyby_adesc.sh adbyby_adhost.sh adbyby_host.sh adbyby_blockip.sh; do
        if [ -f "$CONFIG_SOURCE_DIR/$file" ]; then
            cp "$CONFIG_SOURCE_DIR/$file" "$CONFIG_DIR/"
            chmod +x "$CONFIG_DIR/$file"
            echo "已安装: $CONFIG_DIR/$file"
        fi
    done
fi

# 创建默认规则文件（如果不存在）
if [ ! -f "$TARGET_DIR/data/rules.txt" ] || [ ! -s "$TARGET_DIR/data/rules.txt" ]; then
    cat > "$TARGET_DIR/data/rules.txt" << 'EOF'
# AdByBy-Open Rules File
# Format: pattern|type|description
# Types: 0=simple, 1=regex, 2=domain, 3=url, 4=wildcard

# 内置广告域名（程序会自动加载）
# 以下是自定义规则示例

# 常见广告域名
doubleclick.net|2|Google DoubleClick
googleadservices.com|2|Google Ads
googlesyndication.com|2|Google Syndication
google-analytics.com|2|Google Analytics
googletagmanager.com|2|Google Tag Manager

# 社交媒体跟踪
facebook.com/tr|0|Facebook Tracking
connect.facebook.net|2|Facebook Connect

# 其他广告网络
amazon-adsystem.com|2|Amazon Ads
taboola.com|2|Taboola
outbrain.com|2|Outbrain

# 通用广告路径模式
*/ad/*|4|广告路径
*/ads/*|4|广告路径
*/advertisement/*|4|广告页面
*/banner/*|4|横幅广告
*/popup/*|4|弹窗广告

# 跟踪和分析
*analytics*|0|分析服务
*tracking*|0|跟踪服务
*beacon*|0|信标跟踪
*pixel*|0|像素跟踪
EOF
    echo "已创建默认规则文件: $TARGET_DIR/data/rules.txt"
fi

# 创建用户自定义规则文件（如果不存在）
if [ ! -f "$TARGET_DIR/data/user.txt" ] || [ ! -s "$TARGET_DIR/data/user.txt" ]; then
    cat > "$TARGET_DIR/data/user.txt" << 'EOF'
# 用户自定义规则
# 格式: pattern|type|description
# 在这里添加您自己的过滤规则
EOF
    echo "已创建用户规则文件: $TARGET_DIR/data/user.txt"
fi

# 测试安装
echo "正在测试安装..."
if "$TARGET_DIR/adbyby" -h > /dev/null 2>&1; then
    echo "✓ 程序运行正常"
else
    echo "✗ 程序运行异常"
    echo "正在恢复备份..."
    if [ -f "$BACKUP_DIR/adbyby" ]; then
        cp "$BACKUP_DIR/adbyby" "$TARGET_DIR/adbyby"
        echo "已恢复原有程序"
    fi
    exit 1
fi

# 显示规则统计
echo ""
echo "=== 规则统计 ==="
"$TARGET_DIR/adbyby" -s 2>/dev/null | grep -A 5 "Rule Statistics" || echo "无法获取规则统计信息"

echo ""
echo "=== 安装完成 ==="
echo "程序已安装到以下位置:"
echo "  主程序: $TARGET_DIR/adbyby"
echo "  脚本文件: $TARGET_DIR/*.sh"
echo "  配置文件: $TARGET_DIR/*.conf"
echo "  数据文件: $TARGET_DIR/data/"
echo "  文档文件: $TARGET_DIR/doc/"
if [ -f "$BIN_DIR/adbyby.sh" ]; then
    echo "  启动脚本: $BIN_DIR/adbyby.sh"
fi
if [ -d "$CONFIG_DIR" ]; then
    echo "  配置脚本: $CONFIG_DIR/"
fi
echo ""
echo "备份文件位置: $BACKUP_DIR"
echo ""
echo "使用方法:"
echo "  启动服务: $TARGET_DIR/adbyby"
echo "  或者使用: $BIN_DIR/adbyby.sh"
echo "  调试模式: $TARGET_DIR/adbyby -d --no-daemon"
echo "  查看帮助: $TARGET_DIR/adbyby -h"
echo "  查看统计: $TARGET_DIR/adbyby -s"
echo ""
echo "配置文件位置:"
echo "  规则文件: $TARGET_DIR/data/rules.txt"
echo "  用户规则: $TARGET_DIR/data/user.txt"
echo "  数据文件: $TARGET_DIR/data/lazy.txt"
echo "  视频规则: $TARGET_DIR/data/video.txt"
echo ""
echo "注意事项:"
echo "1. 程序默认监听8118端口"
echo "2. 可以通过 -p 参数指定其他端口"
echo "3. 建议定期更新规则文件以获得最佳过滤效果"
echo "4. 配置脚本位于 $CONFIG_DIR/ 目录，用于固件集成"