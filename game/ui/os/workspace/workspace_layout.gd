class_name WorkspaceLayout
extends RefCounted

signal changed
signal committed

const VERSION: int = 1
const REFERENCE: Vector2 = Vector2(2560, 1440)
const DESIGN_GRID: Vector2i = Vector2i(32, 18)
const CELL: int = 80
const STEP: int = 20
const MARGIN: int = 8
const SEAM: int = 12
const MIN_WINDOW: Vector2 = Vector2(1280, 800)
const SIDES: PackedStringArray = ["left", "right", "top", "bottom"]
const MINIMUM: Dictionary = {"left": 240, "right": 280, "top": 80, "bottom": 120}
const MAXIMUM: Dictionary = {"left": 800, "right": 800, "top": 560, "bottom": 560}
const COLLAPSED: Dictionary = {"left": 64, "right": 64, "top": 48, "bottom": 48}

var _preferred: Dictionary = defaults()
var _preview: Dictionary = {}
var _active_side: String = ""
var _start_extent: int = 0


static func defaults() -> Dictionary:
	return {"version": VERSION, "scale_percent": 100, "rails": {
		"left": {"extent": 300, "collapsed": false},
		"right": {"extent": 300, "collapsed": false},
		"top": {"extent": 100, "collapsed": false},
		"bottom": {"extent": 200, "collapsed": false},
	}}


static func validate(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var data: Dictionary = value
	if data.size() != 3 or not data.has_all(["version", "scale_percent", "rails"]):
		return false
	if not _integer(data["version"]) or int(data["version"]) != VERSION:
		return false
	if not _integer(data["scale_percent"]) or int(data["scale_percent"]) not in [100, 125]:
		return false
	if not data["rails"] is Dictionary or data["rails"].size() != 4:
		return false
	for side: String in SIDES:
		var rail: Variant = data["rails"].get(side)
		if not rail is Dictionary or rail.size() != 2 or not rail.has_all(["extent", "collapsed"]):
			return false
		if typeof(rail["collapsed"]) != TYPE_BOOL or not _integer(rail["extent"]):
			return false
		var extent: int = int(rail["extent"])
		if extent < int(MINIMUM[side]) or extent > int(MAXIMUM[side]) or extent % STEP != 0:
			return false
	return true


static func _integer(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value)) \
		and float(value) == floor(float(value)) and absf(float(value)) < 1000000.0


func snapshot() -> Dictionary:
	return _preferred.duplicate(true)


func restore(value: Dictionary) -> Error:
	if not validate(value):
		return ERR_INVALID_DATA
	cancel_resize()
	_preferred = value.duplicate(true)
	_preferred["version"] = VERSION
	_preferred["scale_percent"] = int(value["scale_percent"])
	for side: String in SIDES:
		_preferred["rails"][side]["extent"] = int(value["rails"][side]["extent"])
	changed.emit()
	return OK


func active_side() -> String:
	return _active_side


func scale_for(physical_size: Vector2) -> float:
	var desired: float = float(_preferred["scale_percent"]) / 100.0
	# Never automatically shrink text. Preserve an unavailable larger preference for later.
	return desired if physical_size.x >= MIN_WINDOW.x * desired \
		and physical_size.y >= MIN_WINDOW.y * desired else 1.0


func set_scale_percent(value: int) -> Error:
	if value not in [100, 125]:
		return ERR_INVALID_PARAMETER
	cancel_resize()
	if _preferred["scale_percent"] == value:
		return OK
	_preferred["scale_percent"] = value
	changed.emit()
	committed.emit()
	return OK


static func city_minimum(viewport: Vector2) -> Vector2:
	return Vector2(ceil(1440.0 * minf(1.0, viewport.x / REFERENCE.x)),
		ceil(800.0 * minf(1.0, viewport.y / REFERENCE.y)))


func solve(viewport: Vector2) -> Dictionary:
	var source: Dictionary = _preview if not _preview.is_empty() else _preferred
	var extents: Dictionary = {}
	var folded: Dictionary = {}
	for side: String in SIDES:
		folded[side] = source["rails"][side]["collapsed"]
		extents[side] = COLLAPSED[side] if folded[side] else source["rails"][side]["extent"]
	var minimum: Vector2 = city_minimum(viewport)
	_fit_axis(extents, folded, ["right", "left"], floori(viewport.x - 2 * MARGIN - 2 * SEAM - minimum.x))
	_fit_axis(extents, folded, ["bottom", "top"], floori(viewport.y - 2 * MARGIN - 2 * SEAM - minimum.y))
	var left: float = float(extents["left"])
	var right: float = float(extents["right"])
	var top: float = float(extents["top"])
	var bottom: float = float(extents["bottom"])
	var middle_x: float = MARGIN + left + SEAM
	var middle_width: float = maxf(1.0, viewport.x - 2 * MARGIN - left - right - 2 * SEAM)
	var inner_height: float = maxf(1.0, viewport.y - 2 * MARGIN)
	var city_y: float = MARGIN + top + SEAM
	var city_height: float = maxf(1.0, inner_height - top - bottom - 2 * SEAM)
	var rectangles: Dictionary = {
		"left": Rect2(MARGIN, MARGIN, left, inner_height),
		"right": Rect2(viewport.x - MARGIN - right, MARGIN, right, inner_height),
		"top": Rect2(middle_x, MARGIN, middle_width, top),
		"bottom": Rect2(middle_x, viewport.y - MARGIN - bottom, middle_width, bottom),
		"city": Rect2(middle_x, city_y, middle_width, city_height),
		"left_handle": Rect2(middle_x - SEAM, MARGIN, SEAM, inner_height),
		"right_handle": Rect2(middle_x + middle_width, MARGIN, SEAM, inner_height),
		"top_handle": Rect2(middle_x, city_y - SEAM, middle_width, SEAM),
		"bottom_handle": Rect2(middle_x, city_y + city_height, middle_width, SEAM),
	}
	return {"rects": rectangles, "extents": extents, "collapsed": folded,
		"city_minimum": minimum, "supported": viewport.x >= MIN_WINDOW.x and viewport.y >= MIN_WINDOW.y}


static func _fit_axis(extents: Dictionary, folded: Dictionary, order: Array, budget: int) -> void:
	var excess: int = int(extents[order[0]]) + int(extents[order[1]]) - budget
	for side: String in order:
		if excess <= 0:
			break
		var minimum: int = int(COLLAPSED[side]) if folded[side] else int(MINIMUM[side])
		var reduction: int = mini(int(extents[side]) - minimum, ceili(float(excess) / STEP) * STEP)
		extents[side] = int(extents[side]) - reduction
		excess -= reduction
	# A constrained host may temporarily fold regions; preferred choices remain untouched.
	for side: String in order:
		if excess <= 0:
			break
		var reduction: int = int(extents[side]) - int(COLLAPSED[side])
		extents[side] = COLLAPSED[side]
		folded[side] = true
		excess -= reduction


func begin_resize(side: String, viewport: Vector2) -> bool:
	if side not in SIDES or not _active_side.is_empty():
		return false
	_start_extent = int(solve(viewport)["extents"][side])
	_active_side = side
	_preview = _preferred.duplicate(true)
	return true


func preview_delta(delta: float, viewport: Vector2) -> void:
	if _active_side.is_empty() or not is_finite(delta):
		return
	if _set_extent(_preview, _active_side, _start_extent + delta, viewport):
		changed.emit()


func commit_resize() -> bool:
	if _active_side.is_empty():
		return false
	var altered: bool = _preview != _preferred
	if altered:
		_preferred = _preview.duplicate(true)
	_preview.clear()
	_active_side = ""
	changed.emit()
	if altered:
		committed.emit()
	return altered


func cancel_resize() -> void:
	if _active_side.is_empty():
		return
	_preview.clear()
	_active_side = ""
	changed.emit()


func resize_to(side: String, extent: float, viewport: Vector2) -> bool:
	if side not in SIDES or not is_finite(extent):
		return false
	cancel_resize()
	var altered: bool = _set_extent(_preferred, side, extent, viewport)
	if altered:
		changed.emit()
		committed.emit()
	return altered


func _set_extent(target: Dictionary, side: String, requested: float, viewport: Vector2) -> bool:
	var current: Dictionary = solve(viewport)
	var horizontal: bool = side in ["left", "right"]
	var opposite: String = {"left": "right", "right": "left", "top": "bottom", "bottom": "top"}[side]
	var axis: float = viewport.x if horizontal else viewport.y
	var minimum_city: Vector2 = current["city_minimum"]
	var city_extent: float = minimum_city.x if horizontal else minimum_city.y
	var available: int = floori((axis - 2 * MARGIN - 2 * SEAM - city_extent - float(current["extents"][opposite])) / STEP) * STEP
	var upper: int = mini(int(MAXIMUM[side]), available)
	if upper < int(MINIMUM[side]):
		return false
	var value: int = clampi(roundi(requested / STEP) * STEP, int(MINIMUM[side]), upper)
	if target["rails"][side]["extent"] == value and not target["rails"][side]["collapsed"]:
		return false
	target["rails"][side] = {"extent": value, "collapsed": false}
	return true


func set_collapsed(side: String, folded: bool) -> void:
	if side not in SIDES:
		return
	cancel_resize()
	if _preferred["rails"][side]["collapsed"] == folded:
		return
	_preferred["rails"][side]["collapsed"] = folded
	changed.emit()
	committed.emit()


func reset_layout() -> void:
	cancel_resize()
	_preferred = defaults()
	changed.emit()
	committed.emit()
