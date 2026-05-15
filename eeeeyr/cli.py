"""EEEYER CLI — 命令行入口."""

import sys
import argparse

from .banner import show
from .core import ExamHelper


def _setup_encoding():
    """确保 Windows 终端使用 UTF-8 编码."""
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, OSError):
            pass


def main():
    _setup_encoding()
    parser = argparse.ArgumentParser(
        prog="er",
        description="EEEYER - 超星考试辅助终端工具",
    )
    parser.add_argument(
        "-v", "--version", action="store_true", help="显示版本号"
    )
    parser.add_argument(
        "--mini", action="store_true", help="显示迷你横幅"
    )

    subparsers = parser.add_subparsers(dest="command", help="子命令")

    # login
    login_parser = subparsers.add_parser("login", help="登录超星账号")
    login_parser.add_argument("-u", "--username", help="用户名/手机号")
    login_parser.add_argument("-p", "--password", help="密码")

    # exam
    exam_parser = subparsers.add_parser("exam", help="考试相关操作")
    exam_parser.add_argument("action", choices=["list", "start", "submit"],
                             help="考试操作: list|start|submit")
    exam_parser.add_argument("--id", help="考试 ID")

    # search
    search_parser = subparsers.add_parser("search", help="搜索题库")
    search_parser.add_argument("query", help="搜索关键词")
    search_parser.add_argument("-n", "--limit", type=int, default=10,
                               help="返回结果数量")

    # config
    subparsers.add_parser("config", help="查看/修改配置")

    args = parser.parse_args()

    # 显示迷你横幅（狭窄终端自适应）
    if args.mini and args.command is None:
        show()
        return

    if args.version:
        from . import __version__
        print(f"EEEYER v{__version__}")
        return

    # 默认情况显示横幅并进入交互
    if args.command is None:
        show()
        print("用法: er <command> [options]")
        print()
        print("可用命令:")
        print("  login    登录超星账号")
        print("  exam     考试相关操作")
        print("  search   搜索题库")
        print("  config   查看/修改配置")
        print()
        print('使用 "er <command> --help" 查看各命令的详细帮助。')
        return

    # 处理子命令
    helper = ExamHelper()

    if args.command == "login":
        helper.login(args.username, args.password)
    elif args.command == "exam":
        if args.action == "list":
            helper.exam_list()
        elif args.action == "start":
            helper.exam_start(args.id)
        elif args.action == "submit":
            helper.exam_submit(args.id)
    elif args.command == "search":
        helper.search(args.query, args.limit)
    elif args.command == "config":
        helper.show_config()


if __name__ == "__main__":
    main()
