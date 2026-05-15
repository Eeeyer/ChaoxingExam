"""EEEYER 核心功能模块."""

import json
import os
from pathlib import Path


CONFIG_DIR = Path.home() / ".eeeeyr"
CONFIG_FILE = CONFIG_DIR / "config.json"

DEFAULT_CONFIG = {
    "username": "",
    "cookies": "",
    "auto_save": True,
    "search_limit": 10,
}


class ExamHelper:
    """超星考试辅助核心类."""

    def __init__(self):
        self.config = self._load_config()

    def _load_config(self) -> dict:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        if CONFIG_FILE.exists():
            try:
                return json.loads(CONFIG_FILE.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                return dict(DEFAULT_CONFIG)
        return dict(DEFAULT_CONFIG)

    def _save_config(self):
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        CONFIG_FILE.write_text(
            json.dumps(self.config, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    def login(self, username: str = None, password: str = None):
        """登录超星账号."""
        print("[EEEYER] 登录功能开发中...")
        print(f"  用户名: {username or '(未提供)'}")

    def exam_list(self):
        """列出可用考试."""
        print("[EEEYER] 考试列表功能开发中...")

    def exam_start(self, exam_id: str = None):
        """开始考试."""
        print(f"[EEEYER] 开始考试: {exam_id or '(未指定)'}")

    def exam_submit(self, exam_id: str = None):
        """提交考试."""
        print(f"[EEEYER] 提交考试: {exam_id or '(未指定)'}")

    def search(self, query: str, limit: int = 10):
        """搜索题库."""
        print(f"[EEEYER] 搜索: {query} (limit={limit})")

    def show_config(self):
        """显示当前配置."""
        print("[EEEYER] 当前配置:")
        for k, v in self.config.items():
            if k == "cookies" and v:
                display = v[:20] + "..." if len(v) > 20 else v
            else:
                display = v
            print(f"  {k}: {display}")
