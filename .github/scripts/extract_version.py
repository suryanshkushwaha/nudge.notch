#!/usr/bin/env python3
"""
Extract a semver version string from a GitHub PR comment.

Usage:
  python3 extract_version.py -c "/release v0.4.0"
  echo "/release v0.4.0-beta.1" | python3 extract_version.py

Outputs key=value lines for GitHub Actions and CLI consumption:
  version=0.4.0
  is_beta=false
"""

from __future__ import annotations

import os
import re
import sys
from argparse import ArgumentParser

try:
    import semver
except ImportError:
    # Provide a minimal fallback so the script can at least parse basic versions
    semver = None

SEMVER_RE = re.compile(
    r"v?[0-9]+\.[0-9]+(?:\.[0-9]+)?(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?"
)


def find_first_valid(text: str):
    """Return (version_str, parsed) for the first valid semver found in text."""
    for cand in SEMVER_RE.findall(text or ""):
        s = cand.lstrip("v")
        # Normalize: 0.4 -> 0.4.0, 0.4-beta -> 0.4.0-beta
        normalized = re.sub(r"^([0-9]+\.[0-9]+)(?![0-9]*\.)", r"\1.0", s)
        if semver:
            try:
                parsed = semver.VersionInfo.parse(normalized)
                return s, parsed
            except Exception:
                continue
        else:
            # Without semver library, do basic parsing
            is_pre = "-" in normalized
            return s, type("V", (), {"prerelease": normalized.split("-", 1)[1] if is_pre else None})()
    return None, None


def write_github_output(version: str | None, is_beta_flag: bool) -> None:
    """Write outputs for GitHub Actions if GITHUB_OUTPUT is set."""
    out = os.environ.get("GITHUB_OUTPUT")
    if not out:
        return
    try:
        with open(out, "a", encoding="utf-8") as f:
            f.write(f"version={version or ''}\n")
            f.write(f"is_beta={str(is_beta_flag).lower()}\n")
    except Exception:
        pass


def main(argv=None) -> int:
    p = ArgumentParser(description="Extract semver from a release comment")
    p.add_argument(
        "-c", "--comment", help="Comment body to scan (defaults: $COMMENT or stdin)"
    )
    args = p.parse_args(argv)

    comment = args.comment or os.environ.get("COMMENT")
    if not comment:
        comment = sys.stdin.read() or ""

    version, parsed = find_first_valid(comment)
    beta = getattr(parsed, "prerelease", None)

    write_github_output(version, bool(beta))

    # CLI output
    print(f"version={version or ''}")
    print(f"is_beta={str(bool(beta)).lower()}")
    print(f"Found version: {version} (beta: {bool(beta)})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
