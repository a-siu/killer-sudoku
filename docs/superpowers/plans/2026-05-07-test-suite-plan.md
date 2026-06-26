# Killer Sudoku Test Suite — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a GDScript automated test suite covering generator, grid, cages, and solver with property-based tests.

**Architecture:** Tests live in a `tests/` directory with a `TestRunner` autoload singleton. Each test suite (`test_grid.gd`, `test_cage.gd`, etc.) asserts invariants on generated puzzles. Tests run in-tool via a debug menu button.

**Tech Stack:** Godot 4.4, GDScript, Tool-mode scripts

---

## File Map

| File | Type | Responsibility |
|------|------|----------------|
| `script/Test/test_runner.gd` | Create | Autoload singleton, runs suites, prints results |
| `tests/test_grid.gd` | Create | Grid fill + transformation invariant tests |
| `tests/test_cage.gd` | Create | Cage coverage + sum invariant tests |
| `tests/test_solver.gd` | Create | Solver/verifier correctness tests |
| `tests/test_generator.gd` | Create | End-to-end batch generation tests |
| `script/Game Logic/generator.gd` | Modify | Add `_self_test()` static method |
| `project.godot` | Modify | Register `TestRunner` autoload |

---

## Task 1: TestRunner Autoload Skeleton

**Files:**
- Create: `script/Test/test_runner.gd`
- Modify: `project.godot:21-23`

- [ ] **Step 1: Create test_runner.gd**

```gdscript
extends Node

const TEST_SUITES := ["grid", "cage", "generator", "solver"]

var _results := []

func run_all() -> bool:
    _results.clear()
    for suite in TEST_SUITES:
        run_suite(suite)
    _print_summary()
    return _all_passed()

func run_suite(name: String) -> bool:
    prints("[TEST] Running suite:", name)
    return true

func _print_summary() -> void:
    var passed := _results.count(true)
    var total := _results.size()
    prints("Ran", TEST_SUITES.size(), "suites,", total, "tests,", passed, "passed")

func _all_passed() -> bool:
    return _results.all(func(r): return r)
```

- [ ] **Step 2: Register TestRunner in project.godot**

Add below existing autoload:
```
TestRunner="*res://script/Test/test_runner.gd"
```

- [ ] **Step 3: Verify autoload loads without error**

Run in Godot editor, check output for "[TEST] Running suite: grid" etc.

---

## Task 2: test_grid.gd Suite

**Files:**
- Create: `tests/test_grid.gd`

- [ ] **Step 1: Create test_grid.gd skeleton**

```gdscript
class_name TestGrid
extends RefCounted

static func run() -> bool:
    var passed := 0
    var failed := 0

    var g := Grid.new()
    g.random_fill()
    var cells := g.cells

    if _rows_unique(cells):
        prints("[PASS] grid::random_fill_valid")
        passed += 1
    else:
        prints("[FAIL] grid::random_fill_valid")
        failed += 1

    return failed == 0

static func _rows_unique(cells: Array) -> bool:
    for row in range(9):
        var seen := {}
        for col in range(9):
            var n: int = cells[row * 9 + col].number
            if n < 1 or n > 9 or seen.has(n):
                return false
            seen[n] = true
    return true
```

- [ ] **Step 2: Add col and block uniqueness tests**

```gdscript
static func _cols_unique(cells: Array) -> bool:
    for col in range(9):
        var seen := {}
        for row in range(9):
            var n: int = cells[row * 9 + col].number
            if n < 1 or n > 9 or seen.has(n):
                return false
            seen[n] = true
    return true

static func _blocks_unique(cells: Array) -> bool:
    for block_row in range(3):
        for block_col in range(3):
            var seen := {}
            for dr in range(3):
                for dc in range(3):
                    var row := block_row * 3 + dr
                    var col := block_col * 3 + dc
                    var n: int = cells[row * 9 + col].number
                    if n < 1 or n > 9 or seen.has(n):
                        return false
                    seen[n] = true
    return true
```

- [ ] **Step 3: Add transformation tests**

```gdscript
static func test_rotate(grid: Grid) -> bool:
    var before := grid.cells.map(func(c): return c.number)
    grid.rotate()
    var after := grid.cells.map(func(c): return c.number)
    return _rows_unique(after) and _cols_unique(after)
```

- [ ] **Step 4: Update TestRunner to call test_grid.gd**

Modify `run_suite("grid")`:
```gdscript
func run_suite(name: String) -> bool:
    prints("[TEST] Running suite:", name)
    var result := false
    match name:
        "grid":   result = TestGrid.run()
        "cage":   result = TestCage.run()
        "solver": result = TestSolver.run()
        "generator": result = TestGenerator.run()
    _results.append(result)
    return result
```

---

## Task 3: test_cage.gd Suite

**Files:**
- Create: `tests/test_cage.gd`

- [ ] **Step 1: Create test_cage.gd**

```gdscript
class_name TestCage
extends RefCounted

static func run() -> bool:
    var gen := Generator.new()
    await gen.generate_puzzle()

    var cells := gen.grid.cells
    var cages := gen.cages.content
    var failed := 0

    if _cage_sums_match(cages, cells):
        prints("[PASS] cage::sums_match")
    else:
        prints("[FAIL] cage::sums_match")
        failed += 1

    if _cages_cover_all(cages, cells):
        prints("[PASS] cage::coverage_all")
    else:
        prints("[FAIL] cage::coverage_all")
        failed += 1

    return failed == 0

static func _cage_sums_match(cages: Array, cells: Array) -> bool:
    for cage in cages:
        var cage_sum := 0
        for cell in cage.cells:
            cage_sum += cell.number
        if cage_sum != cage.sum:
            prints("  Cage sum mismatch: expected", cage.sum, "got", cage_sum)
            return false
    return true

static func _cages_cover_all(cages: Array, cells: Array) -> bool:
    var covered := {}
    for cage in cages:
        for cell in cage.cells:
            var key := cell.coords
            if covered.has(key):
                prints("  Cell", key, "in multiple cages")
                return false
            covered[key] = true
    if covered.size() != 81:
        prints("  Only", covered.size(), "/81 cells covered")
        return false
    return true
```

---

## Task 4: test_solver.gd Suite

**Files:**
- Create: `tests/test_solver.gd`

- [ ] **Step 1: Create test_solver.gd with fixed test grid**

```gdscript
class_name TestSolver
extends RefCounted

static func run() -> bool:
    var failed := 0

    var g := Grid.new()
    g.random_fill()

    if g.verify():
        prints("[PASS] solver::verify_valid_grid")
    else:
        prints("[FAIL] solver::verify_valid_grid")
        failed += 1

    var bad := Grid.new()
    bad.cells[0].number = 1
    bad.cells[9].number = 1
    if not bad.verify():
        prints("[PASS] solver::verify_invalid_duplicate")
    else:
        prints("[FAIL] solver::verify_invalid_duplicate")
        failed += 1

    return failed == 0
```

---

## Task 5: test_generator.gd Suite

**Files:**
- Create: `tests/test_generator.gd`

- [ ] **Step 1: Create test_generator.gd batch test**

```gdscript
class_name TestGenerator
extends RefCounted

static func run() -> bool:
    const N := 10
    var failed := 0

    for i in range(N):
        var gen := Generator.new()
        await gen.generate_puzzle()
        var grid := gen.grid
        var cages := gen.cages.content

        if not grid.verify():
            prints("[FAIL] generator::batch_" + str(i) + "_grid_invalid")
            failed += 1

        for cage in cages:
            var sum := 0
            for cell in cage.cells:
                sum += cell.number
            if sum != cage.sum:
                prints("[FAIL] generator::batch_" + str(i) + "_cage_sum_mismatch")
                failed += 1
                break

        if failed == 0:
            prints("[PASS] generator::batch_" + str(i))

    if failed == 0:
        prints("All", N, "generated puzzles passed invariants")
    else:
        prints(failed, "puzzles failed invariants")

    return failed == 0
```

---

## Task 6: _self_test() on Generator

**Files:**
- Modify: `script/Game Logic/generator.gd:29-34`

- [ ] **Step 1: Add _self_test() static method**

Add at end of generator.gd:
```gdscript
static func _self_test() -> bool:
    const N := 20
    var failed := 0
    for i in range(N):
        var g := Generator.new()
        await g.generate_puzzle()
        if not g.grid.verify():
            prints("[FAIL] self_test::grid_invalid at iteration", i)
            failed += 1
        for cage in g.cages.content:
            var sum := 0
            for cell in cage.cells:
                sum += cell.number
            if sum != cage.sum:
                prints("[FAIL] self_test::cage_sum_mismatch at iteration", i)
                failed += 1
                break
    if failed == 0:
        prints("self_test: all", N, "puzzles passed")
    else:
        prints("self_test:", failed, "failures in", N, "puzzles")
    return failed == 0
```

---

## Task 7: Debug Menu Integration

**Files:**
- Modify: `script/UI/Interactables/main_menu.gd` (or debug panel)

- [ ] **Step 1: Add test runner button**

In the debug panel or pause menu, add a "Run Tests" button that calls:
```gdscript
var result := TestRunner.run_all()
if result:
    prints("ALL TESTS PASSED")
else:
    prints("SOME TESTS FAILED")
```

---

## Implementation Order

1. Task 1 — TestRunner skeleton + autoload registration
2. Task 2 — test_grid.gd
3. Task 3 — test_cage.gd
4. Task 4 — test_solver.gd
5. Task 5 — test_generator.gd
6. Task 6 — _self_test() on generator
7. Task 7 — Debug menu button

**Plan complete and saved to `docs/superpowers/plans/2026-05-07-test-suite-plan.md`.**

Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints

Which approach?