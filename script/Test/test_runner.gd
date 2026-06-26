extends Node

const TEST_SUITES := ["grid", "cage", "generator", "solver"]

var _results := []

func run_all() -> bool:
	_results.clear()
	var all_passed := true
	for suite in TEST_SUITES:
		var result := await run_suite(suite)
		if not result:
			all_passed = false
	_print_summary()
	return all_passed

func run_suite(name: String) -> bool:
	prints("[TEST] Running suite:", name)
	var result := false
	match name:
		"grid":      result = _run_grid_tests()
		"cage":      result = await _run_cage_tests()
		"solver":    result = _run_solver_tests()
		"generator": result = await _run_generator_tests()
	_results.append(result)
	return result

func _run_grid_tests() -> bool:
	var passed := 0
	var failed := 0

	var g := Grid.new()
	g.random_fill()
	var cells := g.cells

	if _rows_unique(cells):
		prints("[PASS] grid::random_fill_unique_rows")
		passed += 1
	else:
		prints("[FAIL] grid::random_fill_unique_rows")
		failed += 1

	if _cols_unique(cells):
		prints("[PASS] grid::random_fill_unique_cols")
		passed += 1
	else:
		prints("[FAIL] grid::random_fill_unique_cols")
		failed += 1

	if _blocks_unique(cells):
		prints("[PASS] grid::random_fill_unique_blocks")
		passed += 1
	else:
		prints("[FAIL] grid::random_fill_unique_blocks")
		failed += 1

	prints("  Grid tests:", passed, "passed,", failed, "failed")
	return failed == 0

func _run_cage_tests() -> bool:
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

	prints("  Cage tests:", (2 - failed), "passed,", failed, "failed")
	return failed == 0

func _run_solver_tests() -> bool:
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

	prints("  Solver tests:", (2 - failed), "passed,", failed, "failed")
	return failed == 0

func _run_generator_tests() -> bool:
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
			continue

		var cage_ok := true
		for cage in cages:
			var sum := 0
			for cell in cage.cells:
				sum += cell.number
			if sum != cage.sum:
				prints("[FAIL] generator::batch_" + str(i) + "_cage_sum_mismatch")
				failed += 1
				cage_ok = false
				break

		if cage_ok:
			prints("[PASS] generator::batch_" + str(i))

	prints("  Generator: ", (N - failed), "/", N, "puzzles passed")
	return failed == 0

func _print_summary() -> void:
	var passed := _results.count(true)
	var total := _results.size()
	prints("")
	prints("=============================")
	prints("Ran", total, "suites,", passed, "passed,", total - passed, "failed")
	prints("=============================")

func _rows_unique(cells: Array) -> bool:
	for row in range(9):
		var seen := {}
		for col in range(9):
			var n: int = cells[row * 9 + col].number
			if n < 1 or n > 9 or seen.has(n):
				return false
			seen[n] = true
	return true

func _cols_unique(cells: Array) -> bool:
	for col in range(9):
		var seen := {}
		for row in range(9):
			var n: int = cells[row * 9 + col].number
			if n < 1 or n > 9 or seen.has(n):
				return false
			seen[n] = true
	return true

func _blocks_unique(cells: Array) -> bool:
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

func _cage_sums_match(cages: Array, cells: Array) -> bool:
	for cage in cages:
		var cage_sum := 0
		for cell in cage.cells:
			cage_sum += cell.number
		if cage_sum != cage.sum:
			prints("  Cage sum mismatch: expected", cage.sum, "got", cage_sum)
			return false
	return true

func _cages_cover_all(cages: Array, cells: Array) -> bool:
	var covered := {}
	for cage in cages:
		for cell in cage.cells:
			var key := str(cell.coords)
			if covered.has(key):
				prints("  Cell", key, "in multiple cages")
				return false
			covered[key] = true
	if covered.size() != 81:
		prints("  Only", covered.size(), "/81 cells covered")
		return false
	return true
