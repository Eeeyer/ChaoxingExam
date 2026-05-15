"""EEEYER CLI — 命令行入口."""

import sys
import argparse

from .banner import show
from .core import ExamHelper


def _setup_encoding():
    if sys.platform == "win32":
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
            sys.stderr.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, OSError):
            pass


def _print_help():
    """使用 rich 渲染精美的主界面."""
    from . import __version__
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.text import Text
    from rich import box

    console = Console()

    G = "gold1"
    D = "dark_goldenrod"
    W = "bright_white"
    A = "bright_yellow"

    # ── 命令表格 ────────────────────────────────────────────────
    cmd_table = Table(box=box.SIMPLE, show_header=True,
                      header_style=f"bold {G}", expand=False)
    cmd_table.add_column("命令", style=A, no_wrap=True)
    cmd_table.add_column("说明", style=W)
    cmd_table.add_column("选项", style=D)

    cmd_table.add_row(
        "er login [-u <账号>] [-p <密码>]",
        "登录超星账号",
        "-u, -p",
    )
    cmd_table.add_row(
        "er exam {list|start|submit}",
        "查看 / 开始 / 提交考试",
        "--id <考试ID>",
    )
    cmd_table.add_row(
        "er search <关键词>",
        "搜索题库题目",
        "-n <数量>",
    )
    cmd_table.add_row(
        "er config",
        "查看或修改本地配置",
        "",
    )

    # ── 快捷操作 ────────────────────────────────────────────────
    quick = Table(box=box.SIMPLE, show_header=False, expand=False, padding=(0, 2))
    quick.add_column(style=A, no_wrap=True)
    quick.add_column(style=W)
    quick.add_row("er --version", "显示版本号")
    quick.add_row("er --mini", "紧凑模式")
    quick.add_row("er <command> --help", "查看命令详细帮助")

    # ── 组装面板 ────────────────────────────────────────────────
    body = Table.grid(padding=(0, 4))
    body.add_row(cmd_table)
    body.add_row()
    body.add_row(Text("快捷操作", style=f"bold {G}"))
    body.add_row(quick)

    footer = Text(f"v{__version__}  ·  github.com/Eeeyer/ChaoxingExam", style=D)

    panel = Panel(
        body,
        title=Text(" EEEYER · 超星考试辅助终端工具 ", style=f"bold {G}"),
        title_align="left",
        subtitle=footer,
        subtitle_align="right",
        border_style=D,
        box=box.ROUNDED,
        padding=(1, 2),
    )

    console.print(panel)


def main():
    _setup_encoding()

    parser = argparse.ArgumentParser(
        prog="er",
        description="EEEYER - 超星考试辅助终端工具",
        add_help=False,
    )
    parser.add_argument(
        "-v", "--version", action="store_true", help="显示版本号"
    )
    parser.add_argument(
        "--mini", action="store_true", help="迷你横幅"
    )
    parser.add_argument(
        "-h", "--help", action="store_true", help="显示帮助"
    )

    subparsers = parser.add_subparsers(dest="command", title="命令")

    login_parser = subparsers.add_parser("login", help="登录超星账号")
    login_parser.add_argument("-u", "--username", help="用户名/手机号")
    login_parser.add_argument("-p", "--password", help="密码")

    exam_parser = subparsers.add_parser("exam", help="考试相关操作")
    exam_parser.add_argument("action", choices=["list", "start", "submit"],
                             help="list | start | submit")
    exam_parser.add_argument("--id", help="考试 ID")

    search_parser = subparsers.add_parser("search", help="搜索题库")
    search_parser.add_argument("query", help="搜索关键词")
    search_parser.add_argument("-n", "--limit", type=int, default=10,
                               help="返回结果数量")

    subparsers.add_parser("config", help="查看/修改本地配置")

    args = parser.parse_args()

    # ── 路由 ────────────────────────────────────────────────────
    if args.version:
        from . import __version__
        print(f"EEEYER v{__version__}")
        return

    if args.mini and args.command is None:
        show()
        return

    if args.help or args.command is None:
        show()
        _print_help()
        return

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
