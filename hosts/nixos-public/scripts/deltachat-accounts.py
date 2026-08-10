"""TUI to disable/enable DeltaChat relay accounts.

Disabling an address blanks its password file and locks the maildir
(mode 0500, owned by root) so chatmaild's doveauth can neither
authenticate the old password nor silently re-provision a new one on
the next login attempt. Enabling restores vmail ownership and mode 0750.
"""

import curses
import grp
import os
import pwd
import re
import subprocess
import sys

MAILDIR_BASE = "/var/lib/deltachat/mail"
ENABLED_MODE = 0o750
DISABLED_MODE = 0o500

QUEUE_ID_RE = re.compile(r"^\S+ \S+ postfix/\S+\[\d+\]: ([0-9A-F]+): (.*)$")
FROM_RE = re.compile(r"from=<([^>]*)>")
TO_RE = re.compile(r"to=<([^>]*)>")


def list_accounts():
    try:
        entries = os.listdir(MAILDIR_BASE)
    except FileNotFoundError:
        return []
    return sorted(e for e in entries if "@" in e)


def is_disabled(addr):
    path = os.path.join(MAILDIR_BASE, addr)
    st = os.stat(path)
    return st.st_uid == 0


def disable_account(addr):
    maildir = os.path.join(MAILDIR_BASE, addr)
    password_path = os.path.join(maildir, "password")
    os.chmod(maildir, 0o750)
    with open(password_path, "wb") as f:
        f.truncate(0)
    os.chown(maildir, 0, 0)
    os.chmod(maildir, DISABLED_MODE)


def enable_account(addr):
    vmail = pwd.getpwnam("vmail")
    vmail_grp = grp.getgrnam("vmail")
    maildir = os.path.join(MAILDIR_BASE, addr)
    os.chown(maildir, vmail.pw_uid, vmail_grp.gr_gid)
    os.chmod(maildir, ENABLED_MODE)


MAX_LOG_ROWS = 500


def fetch_sent_log(addr, since="2 days ago"):
    """Return a list of (date, from, to) for messages sent by addr,
    newest first, by correlating postfix queue IDs across log lines."""
    try:
        out = subprocess.run(
            [
                "journalctl",
                "-u",
                "postfix",
                "--no-pager",
                "-o",
                "short-iso",
                "--since",
                since,
            ],
            capture_output=True,
            text=True,
            check=False,
        ).stdout
    except FileNotFoundError:
        return []

    queues = {}
    order = []
    for line in out.splitlines():
        m = QUEUE_ID_RE.match(line)
        if not m:
            continue
        qid, rest = m.groups()
        date = line.split(" ", 1)[0]
        entry = queues.setdefault(qid, {"date": date, "from": None, "to": []})
        fm = FROM_RE.search(rest)
        if fm:
            entry["from"] = fm.group(1)
            if qid not in order:
                order.append(qid)
        tm = TO_RE.search(rest)
        if tm:
            entry["to"].append(tm.group(1))

    rows = []
    for qid in order:
        entry = queues[qid]
        if entry["from"] != addr:
            continue
        to = ", ".join(entry["to"]) if entry["to"] else "(unknown)"
        rows.append((entry["date"], entry["from"], to))
    rows.reverse()
    return rows[:MAX_LOG_ROWS]


def draw(stdscr, accounts, selected, status):
    stdscr.erase()
    h, w = stdscr.getmaxyx()
    stdscr.addstr(
        0, 0, "DeltaChat accounts".ljust(w - 1)[: w - 1], curses.A_BOLD
    )
    stdscr.addstr(
        1,
        0,
        "up/down move  space toggle  right log  q quit".ljust(w - 1)[: w - 1],
    )

    for i, addr in enumerate(accounts):
        row = 3 + i
        if row >= h - 2:
            break
        disabled = is_disabled(addr)
        label = "DISABLED" if disabled else "enabled "
        attr = curses.A_REVERSE if i == selected else curses.A_NORMAL
        if disabled:
            attr |= curses.color_pair(1)
        line = f"[{label}] {addr}"
        stdscr.addstr(row, 0, line.ljust(w - 1)[: w - 1], attr)

    if status:
        stdscr.addstr(h - 1, 0, status.ljust(w - 1)[: w - 1])
    stdscr.refresh()


def draw_log(stdscr, addr, rows, top, selected, status):
    stdscr.erase()
    h, w = stdscr.getmaxyx()
    stdscr.addstr(
        0, 0, f"Sent mail: {addr}".ljust(w - 1)[: w - 1], curses.A_BOLD
    )
    stdscr.addstr(
        1, 0, "up/down scroll  left back  q quit".ljust(w - 1)[: w - 1]
    )

    visible_h = h - 4
    for i in range(visible_h):
        idx = top + i
        if idx >= len(rows):
            break
        date, sender, to = rows[idx]
        row = 3 + i
        attr = curses.A_REVERSE if idx == selected else curses.A_NORMAL
        line = f"{date}  from={sender}  to={to}"
        stdscr.addstr(row, 0, line.ljust(w - 1)[: w - 1], attr)

    if not rows:
        stdscr.addstr(3, 0, "(no sent mail found in log window)")

    if status:
        stdscr.addstr(h - 1, 0, status.ljust(w - 1)[: w - 1])
    stdscr.refresh()


def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_RED, -1)

    accounts = list_accounts()
    selected = 0
    status = f"{len(accounts)} account(s)"
    mode = "list"
    log_addr = None
    log_rows = []
    log_top = 0
    log_selected = 0

    while True:
        if mode == "list":
            draw(stdscr, accounts, selected, status)
            if not accounts:
                key = stdscr.getch()
                if key in (ord("q"), 27):
                    return
                continue

            key = stdscr.getch()
            if key in (ord("q"), 27):
                return
            elif key in (curses.KEY_UP, ord("k")):
                selected = max(0, selected - 1)
            elif key in (curses.KEY_DOWN, ord("j")):
                selected = min(len(accounts) - 1, selected + 1)
            elif key == ord(" "):
                addr = accounts[selected]
                try:
                    if is_disabled(addr):
                        enable_account(addr)
                        status = f"enabled {addr}"
                    else:
                        disable_account(addr)
                        status = f"disabled {addr}"
                except PermissionError:
                    status = "permission denied — run as root"
                except FileNotFoundError:
                    accounts = list_accounts()
                    selected = min(selected, max(0, len(accounts) - 1))
                    status = f"{addr} no longer exists"
            elif key in (curses.KEY_RIGHT, ord("l")):
                log_addr = accounts[selected]
                log_rows = fetch_sent_log(log_addr)
                log_top = 0
                log_selected = 0
                mode = "log"

        elif mode == "log":
            log_status = f"{len(log_rows)} message(s), last 2 days"
            draw_log(stdscr, log_addr, log_rows, log_top, log_selected, log_status)
            key = stdscr.getch()
            if key in (ord("q"), 27):
                return
            elif key in (curses.KEY_LEFT, ord("h")):
                mode = "list"
            elif key in (curses.KEY_UP, ord("k")):
                if log_selected > 0:
                    log_selected -= 1
                    if log_selected < log_top:
                        log_top = log_selected
            elif key in (curses.KEY_DOWN, ord("j")):
                if log_selected < len(log_rows) - 1:
                    log_selected += 1
                    h, _ = stdscr.getmaxyx()
                    visible_h = h - 4
                    if log_selected >= log_top + visible_h:
                        log_top = log_selected - visible_h + 1


if __name__ == "__main__":
    if os.geteuid() != 0:
        print("must run as root", file=sys.stderr)
        sys.exit(1)
    curses.wrapper(main)
