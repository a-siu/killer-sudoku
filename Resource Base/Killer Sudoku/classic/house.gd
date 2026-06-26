extends Resource
class_name House


@export var content : Array[Cell]

func verify() -> bool:
	var numbers : Array = []
	for cell in content:
		if not cell.display:  
			continue
		if cell.display in numbers:
			#print('Collision:', cell.number)
			return false
		numbers.append(cell.number)
	return numbers.size() == content.size()
	

func test() -> bool:
	var numbers : Array = []
	for cell in content:
		if not cell.number:  
			continue
		if cell.number in numbers:
			#print('Collision:', cell.number)
			return false
			
		numbers.append(cell.number)
	return true	

func assign_all(numbers : Array) -> void:
	for i in range(len(numbers)):
		content[i].number = numbers[i]



func _to_string() -> String:
	var arr : Array = []
	for i in content:
		arr.append(str(i))
	arr.insert(6, ' ')
	arr.insert(3, ' ')
	return ''.join(arr)
