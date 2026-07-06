import os, sys, json, subprocess
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
import review_gate as rg

GATE = os.path.join(os.path.dirname(__file__), "..", "review_gate.py")

GOOD = {"correctness": 0.95, "simplicity": 0.9, "readability": 0.9, "maintainability": 0.85, "test_quality": 0.8}
TANKED_AXIS = {"correctness": 0.95, "simplicity": 0.95, "readability": 0.95, "maintainability": 0.95, "test_quality": 0.5}
LOW_OVERALL = {"correctness": 0.7, "simplicity": 0.7, "readability": 0.75, "maintainability": 0.75, "test_quality": 0.7}


def test_clears_senior_bar():
    passed, overall, failures = rg.evaluate(GOOD, rg.MIN_OVERALL, rg.MIN_AXIS)
    assert passed and not failures
    assert overall >= rg.MIN_OVERALL


def test_single_tanked_axis_fails_even_with_high_average():
    # test_quality below the 0.70 floor must block despite a strong overall
    passed, overall, failures = rg.evaluate(TANKED_AXIS, rg.MIN_OVERALL, rg.MIN_AXIS)
    assert not passed
    assert any("test_quality" in f for f in failures)


def test_overall_below_threshold_fails():
    passed, _, failures = rg.evaluate(LOW_OVERALL, rg.MIN_OVERALL, rg.MIN_AXIS)
    assert not passed
    assert any("overall" in f for f in failures)


def test_weights_sum_to_one():
    assert abs(sum(rg.WEIGHTS.values()) - 1.0) < 1e-9


def test_missing_axis_is_misuse():
    try:
        rg.evaluate({"correctness": 0.9}, rg.MIN_OVERALL, rg.MIN_AXIS)
    except KeyError:
        return
    assert False, "expected KeyError for missing axes"


def test_out_of_range_axis_rejected():
    try:
        rg.evaluate({**GOOD, "correctness": 1.5}, rg.MIN_OVERALL, rg.MIN_AXIS)
    except ValueError:
        return
    assert False, "expected ValueError for out-of-range score"


def test_cli_pass_via_stdin():
    proc = subprocess.run([sys.executable, GATE, "-"], input=json.dumps(GOOD), text=True, capture_output=True)
    assert proc.returncode == 0
    assert "PASS" in proc.stdout


def test_cli_fail_exit_code():
    proc = subprocess.run([sys.executable, GATE, "-"], input=json.dumps(TANKED_AXIS), text=True, capture_output=True)
    assert proc.returncode == 1


def test_cli_strict_override():
    # GOOD clears the default 0.85 bar but not a 0.98 overall bar
    proc = subprocess.run(
        [sys.executable, GATE, "--min-overall", "0.98", "-"], input=json.dumps(GOOD), text=True, capture_output=True
    )
    assert proc.returncode == 1
