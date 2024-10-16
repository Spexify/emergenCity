class_name EMC_Util

class Promise:
	signal complete(name : String)
	
	const signal_or_name : String = "signal_or"
	
	func _init(signals : Array[Signal], f_name : String) -> void:
		var f : Callable = Callable(self, f_name)
		for sig : Signal in signals:
			sig.connect(f.bind(sig.get_name()))
	
	func signal_or(name : String) -> void:
		complete.emit(name)
	

class Icon_Patcher:
	
	static func cut_out(texture : Texture2D, region : Rect2) -> Texture2D:
		var result : Image = texture.get_image().get_region(region) 
		
		return ImageTexture.create_from_image(result)
	
	static func combine(textures : Array[Texture2D]) -> Texture2D:
		var width : int = 0
		var height : int = 0
		
		var images : Array[Image] = []
		
		for tex : Texture2D in textures:
			var img : Image = tex.get_image()
			if not images.is_empty() and not images[0].get_format() == img.get_format():
				printerr("EMC_Util.Icon_Patcher.combine: Texture has wrong Fromat, will be ignored")
				continue
			
			width += tex.get_width()
			height += tex.get_height()
			images.append(img)
		
		if images.is_empty():
			printerr("EMC_Util.Icon_Patcher.combine: No valid Images present: abort")
			return
		
		var result : Image = Image.create(width, height, false, images[0].get_format())
		
		var offset : Vector2i = Vector2i(0, 0)
		
		for img : Image in images:
			result.blit_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), offset)
			offset += Vector2i(img.get_width(), 0)
		#result.blit_rect(img2, Rect2(0, 0, img2.get_width(), img2.get_height()), Vector2i(img1.get_width(), img1.get_height()))
		
		return ImageTexture.create_from_image(result)

static var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

static func pick_weighted_random(list : Array[Variant], weights : Array[float], count : int) -> Array[Variant]:
	var result : Array[Variant] = []
	assert(count <= list.size(), "Count cannot be greater than list size")
	assert(list.size() == weights.size(), "The size of list and weights must be equal")
	for i in range(count):
		var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
		var random : float = _rng.randf_range(0.0, sum_of_weight)
		for index in range(list.size()):
			if random < weights[index]:
				result.append(list[index])
				list.remove_at(index)
				weights.remove_at(index)
				break
			random -= weights[index]
	return result
	
static func pick_weighted_random_const(list : Array[Variant], weights : Array[float]) -> Variant:
	assert(1 <= list.size(), "Count cannot be greater than list size")
	assert(list.size() == weights.size(), "The size of list and weights must be equal")
	var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
	var random : float = _rng.randf_range(0.0, sum_of_weight)
	for index in range(list.size()):
		if random < weights[index]:
			return list[index]
		random -= weights[index]
	return
