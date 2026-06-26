# Killer Sudoku Test Suite — Design

**Date:** 2026-05-07
**Author:** Claude

## Overview

Add a GDScript-based automated test suite for the killer sudoku generator, solver, and grid logic. Tests run within Godot (no external runner) and cover regression safety, puzzle correctness, and edge cases.

## Tech Stack

- **Framework:** Godot 4.4, GDScript
- **Tests run:** Within Godot editor or via headless `--test` export flag
- **Output:** Runtime results printed to output panel / console

## Approach: Property-Based Tests (No Fixtures)

The generator is seeded and non-deterministic — storing golden output would require constant maintenance as the algorithm evolves. Instead, tests assert **invariants** that hold regardless of which puzzle is generated.

### Core Invariants

Every generated puzzle must satisfy:
1. **Sudoku validity** — each row, column, and 3x3 block contains digits 1-9 exactly once
2. **Cage coverage** — all 81 cells belong to exactly one cage, no cell in two cages
3. **Cage sum correctness** — each cage's declared sum equals the sum of its cells' numbers
4. **Exactly one solution** — the puzzle has a unique valid solution (verified by independent solver)
5. **Cage size sanity** — no cage has fewer than 2 cells (singleton sums are auto-filled)

### Optional Fixture Generation

For manual validation, tests can optionally save a puzzle at a specific moment (for debugging or manual review):

```gdscript
TestRunner.generate_fixture(path)  # generate + save JSON on demand
```

This is manual-only — not run in CI or on every test pass.

### Why No Golden Fixtures?

- Seeded generation means output changes with algorithm changes
- Maintaining fixture parity would be a maintenance burden
- Property-based tests provide better coverage: every *new* puzzle is tested, not just a snapshot

## File Structure

```
project/
├── tests/
│   ├── runner/
│   │   └── test_runner.gd # Autoload singleton, runs all suites
│   ├── test_grid.gd       # Grid fill + transformation tests
│   ├── test_cage.gd       # Cage sum + coverage tests
│   ├── test_generator.gd  # End-to-end generation tests
│   └── test_solver.gd     # Solver/verifier correctness tests
└── script/
    └── Game Logic/
        └── generator.gd   # Add _self_test() + debug exports
```

## TestRunner Autoload

`TestRunner` is a Tool-mode autoload singleton:

| Method | Description |
|--------|-------------|
| `run_all()` | Runs every test script, returns pass/fail summary |
| `run_suite(name)` | Run one suite by name (`grid`, `cage`, `generator`, `solver`) |

Test output format:
```
[PASS] grid::random_fill_unique_rows
[PASS] grid::random_fill_unique_cols
[PASS] grid::random_fill_unique_blocks
[FAIL] cage::sum_matches_cells — expected 15, got 14
Ran 4 suites, 23 tests, 22 passed, 1 failed
```

## Test Suites

### grid (`test_grid.gd`)

Tests for `grid.gd`:
- `random_fill_unique_rows` — after `random_fill()`, each row has digits 1-9
- `random_fill_unique_cols` — each column has digits 1-9
- `random_fill_unique_blocks` — each 3x3 block has digits 1-9
- `transform_rotate_preserves_uniqueness` — 90° rotation keeps valid sudoku
- `transform_mirror_preserves_uniqueness` — mirroring keeps valid sudoku
- `transform_shuffle_preserves_uniqueness` — row/col swapping keeps valid sudoku

### cage (`test_cage.gd`)

Tests for `cage_cluster.gd`:
- `cage_sums_match_cell_values` — each cage sum equals sum of its cells' `number`
- `cages_cover_all_cells` — all 81 cells belong to exactly one cage
- `no_cell_in_two_cages` — cell membership is exclusive
- `cage_sizes_valid` — no cage has fewer than 2 cells

### generator (`test_generator.gd`)

Tests for `generator.gd`:
- `generate_produces_valid_grid` — generated grid passes all sudoku uniqueness checks
- `generate_produces_valid_cages` — cage sums match cell values
- `generate_produces_valid_cage_coverage` — all 81 cells covered exactly once
- `generate_multiple_produces_unique_results` — N sequential generations are all different (or one is a transformed variant)

### solver (`test_solver.gd`)

Tests for `solver.gd`:
- `verify_house_valid` — a correctly-filled house returns `true`
- `verify_house_invalid_duplicate` — duplicate digits return `false`
- `verify_grid_valid` — a correct full grid returns `true`
- `verify_grid_invalid` — an incorrect grid returns `false`
- `get_possible_daughters_correct` — `_get_possible_daughters()` returns exact combinations for test sums

## Generator Extensions

### `_self_test() -> bool`

Static method for quick ad-hoc testing:
- Generates N puzzles (default 20, configurable)
- Asserts each passes all invariants (cage coverage, cage sums, sudoku uniqueness)
- Returns `true` if all pass, prints summary to output



## CLI / Editor Integration

### Editor Debug Menu

Add a "Run Tests" button/menu item in the debug panel that calls `TestRunner.run_all()` and prints results to the output panel.

### Headless Test Mode

Add a `--test` command-line flag to the Godot export. When present:
- Skip game UI, call `TestRunner.run_all()` immediately
- Print results to stdout / console
- Exit with code 0 on all pass, 1 on any failure

## Implementation Order

1. Create `tests/` directory and `TestRunner` autoload skeleton
2. Implement `test_grid.gd` suite — grid fill + transformation invariants
3. Implement `test_cage.gd` suite — cage coverage + sum invariants
4. Implement `test_solver.gd` suite — solver/verifier correctness
5. Implement `test_generator.gd` suite — end-to-end batch generation tests
6. Add `_self_test()` method to generator
7. Add debug menu "Run Tests" integration
8. Add headless `--test` flag (optional)


