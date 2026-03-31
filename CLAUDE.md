# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

MAVProxy 是一个用 Python 编写的 MAVLink 协议代理和地面站（Ground Station），主要面向命令行操作，适用于嵌入到小型自主飞行器或地面控制站。

## 开发命令

### 安装依赖
```bash
pip install -e .
```

### 代码检查 (Flake8)
项目使用 flake8 进行代码检查，仅检查包含 `AP_FLAKE8_CLEAN` 标记的文件：
```bash
python scripts/run_flake8.py MAVProxy
```

### Windows 构建
使用 GitHub Actions Windows workflow: `.github/workflows/windows_build.yml`

## 架构

### 核心入口
- `MAVProxy/mavproxy.py` - 主程序入口

### 模块系统
所有功能模块继承自 `MPModule` 基类（位于 `MAVProxy/modules/lib/mp_module.py`）：
- 模块文件命名：`mavproxy_<name>.py`
- 核心模块：`mavproxy_link.py`, `mavproxy_console.py`, `mavproxy_mode.py`, `mavproxy_wp.py` 等
- 可选模块：大量功能模块位于 `MAVProxy/modules/` 目录下

模块通过 `mpstate` 对象共享状态，实现 `mavlink_packet()` 钩子处理 MAVLink 消息包。

### 共享库
通用库位于 `MAVProxy/modules/lib/`：
- `mp_module.py` - 模块基类
- `mp_util.py` - 工具函数
- `mp_settings.py` - 设置管理
- `multiproc.py` - 多进程支持
- `wxconsole.py` - 控制台 UI

### 独立工具
- `MAVProxy/tools/MAVExplorer.py` - MAVLink 日志分析工具
- `MAVProxy/tools/mavflightview.py` - 飞行轨迹可视化
- `MAVProxy/tools/mavpicviewer/` - 图片查看器

### 配置目录
用户配置存储在 `~/.mavproxy/` 目录

## 代码规范

- Python 3
- 文件包含 `AP_FLAKE8_CLEAN` 标记表示已通过 flake8 检查
- max-line-length: 127 (见 `.flake8`)
