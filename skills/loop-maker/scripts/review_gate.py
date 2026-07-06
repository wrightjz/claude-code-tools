#!/usr/bin/env python3
"""Tier-2 review gate — turns a subjective rubric score into a binary verdict.

The reviewer (a separate agent) scores code 0-1 on each axis and writes them as
JSON. This script is the deterministic half of the maker/checker split: it reads
those scores, computes the weighted total, and exits 0 (pass) only if the code
clears the senior bar. The loop reads the EXIT CODE, never the prose — that is
how a taste judgment still ends in a hard gate.

Policy lives here as the single source of truth. It must match
`templates/review-rubric.md.tmpl`; if you change one, change the other.

Usage:
  review_gate.py <score.json>
  review_gate.py --min-overall 0.90 --min-axis 0.80 <score.json>   # stricter
  echo '{"correctness":0.9,...}' | review_gate.py -                 # stdin

Exit:  0 = passes the bar (accept) · 1 = below the bar (iterate) · 2 = misuse
"""
from __future__ import annotations

import json
import sys

# Authoritative policy — keep in sync with review-rubric.md.tmpl.
WEIGHTS = {
    "correctness": 0.30,
    "simplicity": 0.20,
    "readability": 0.20,
    "maintainability": 0.20,
    "test_quality": 0.10,
}
MIN_OVERALL = 0.85  # weighted total must reach this
MIN_AXIS = 0.70     # no single axis may fall below this


def _load(path: str) -> dict:
    text = sys.stdin.read() if path == "-" else open(path, encoding="utf-8").read()
    return json.loads(text)


def evaluate(scores: dict, min_overall: float, min_axis: float):
    """Return (passed, overall, failures) — pure, so it is unit-testable."""
    missing = [axis for axis in WEIGHTS if axis not in scores]
    if missing:
        raise KeyError(f"score is missing required axes: {', '.join(sorted(missing))}")

    failures = []
    for axis in WEIGHTS:
        value = float(scores[axis])
        if not 0.0 <= value <= 1.0:
            raise ValueError(f"axis {axis!r} out of range [0,1]: {value}")
        if value < min_axis:
            failures.append(f"{axis}={value:.2f} < floor {min_axis:.2f}")

    overall = sum(WEIGHTS[axis] * float(scores[axis]) for axis in WEIGHTS)
    if overall < min_overall:
        failures.append(f"overall={overall:.3f} < threshold {min_overall:.2f}")

    return (not failures, overall, failures)


def _main(argv) -> int:
    min_overall, min_axis, path = MIN_OVERALL, MIN_AXIS, None
    it = iter(argv)
    for arg in it:
        if arg == "--min-overall":
            min_overall = float(next(it))
        elif arg == "--min-axis":
            min_axis = float(next(it))
        else:
            path = arg
    if path is None:
        print("usage: review_gate.py [--min-overall F] [--min-axis F] <score.json|->", file=sys.stderr)
        return 2

    try:
        scores = _load(path)
        passed, overall, failures = evaluate(scores, min_overall, min_axis)
    except (OSError, ValueError, KeyError) as err:
        print(f"MISUSE: {err}", file=sys.stderr)
        return 2

    if passed:
        print(f"PASS: overall={overall:.3f} (>= {min_overall:.2f}), all axes >= {min_axis:.2f}")
        return 0
    print(f"FAIL: {'; '.join(failures)}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(_main(sys.argv[1:]))
