#!/usr/bin/env python3
"""
Claude Code hook to block dangerous bash commands.
Exit code 2 blocks the command and shows the error message to Claude.
"""
import json
import sys
import re

# Define dangerous command patterns
# Each tuple: (regex_pattern, human_readable_reason)
DANGEROUS_PATTERNS = [
    # rm -rf variations
    (r"rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|f[a-zA-Z]*r)[a-zA-Z]*\s", "rm -rf: recursive force delete"),
    (r"rm\s+-rf\b", "rm -rf: recursive force delete"),
    (r"rm\s+-fr\b", "rm -fr: recursive force delete"),

    # git force push variations
    (r"git\s+push\s+.*--force", "git push --force: force push to repository"),
    (r"git\s+push\s+.*-f(?:\s|$)", "git push -f: force push to repository"),
    (r"git\s+push\s+--force", "git push --force: force push to repository"),

    # git reset --hard to remote (dangerous)
    (r"git\s+reset\s+--hard\s+origin", "git reset --hard origin: destructive reset to remote"),
]


def check_command(command: str) -> tuple[bool, str]:
    """Check if command matches any dangerous patterns."""
    for pattern, reason in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, reason
    return False, ""


def main():
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # If we can't parse input, let it through (fail open)
        sys.exit(0)

    command = input_data.get("tool_input", {}).get("command", "")

    if not command:
        sys.exit(0)

    is_dangerous, reason = check_command(command)

    if is_dangerous:
        print(f"BLOCKED: {reason}", file=sys.stderr)
        print(f"Command: {command}", file=sys.stderr)
        print("This command is blocked by a safety hook. Ask the user if they want to run it manually.", file=sys.stderr)
        sys.exit(2)  # Exit code 2 blocks the tool call

    sys.exit(0)


if __name__ == "__main__":
    main()
