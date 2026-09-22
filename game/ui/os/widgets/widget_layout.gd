class_name WidgetLayout
extends RefCounted

# Ordered rail packing. Rectangles are derived; only IDs, regions, forms and order persist.
const VERSION: int = 1
const IDS: PackedStringArray = ["work_scan", "recent_activity"]
const REGIONS: PackedStringArray = ["bottom", "right"]
const FORMS: PackedStringArray = ["compact", "wide", "tall", "major"]
const GAP: int = 12
const TITLES: Dictionary = {"work_scan": "Work Scan", "recent_activity": "Recent Activity"}


static func defaults() -> Dictionary:
	return {"version": VERSION, "placements": [
		{"id": "work_scan", "region": "bottom", "form": "wide", "order": 0},
		{"id": "recent_activity", "region": "right", "form": "tall", "order": 0},
	]}


static func validate(value: Variant) -> bool:
	if not value is Dictionary or value.size() != 2 or not value.has_all(["version", "placements"]):
		return false
	if not WorkspaceLayout._integer(value["version"]) or int(value["version"]) != VERSION:
		return false
	if not value["placements"] is Array or value["placements"].size() != IDS.size():
		return false
	var seen: Dictionary = {}
	var orders: Dictionary = {"bottom": [], "right": []}
	for raw: Variant in value["placements"]:
		if not raw is Dictionary or raw.size() != 4 or not raw.has_all(["id", "region", "form", "order"]):
			return false
		if typeof(raw["id"]) != TYPE_STRING or raw["id"] not in IDS or seen.has(raw["id"]):
			return false
		if typeof(raw["region"]) != TYPE_STRING or raw["region"] not in REGIONS \
				or typeof(raw["form"]) != TYPE_STRING or raw["form"] not in FORMS:
			return false
		if not WorkspaceLayout._integer(raw["order"]) or int(raw["order"]) < 0 or int(raw["order"]) >= IDS.size():
			return false
		seen[raw["id"]] = true
		orders[raw["region"]].append(int(raw["order"]))
	for region: String in REGIONS:
		orders[region].sort()
		for index: int in range(orders[region].size()):
			if orders[region][index] != index:
				return false
	return true


static func normalize(value: Dictionary) -> Dictionary:
	var result: Dictionary = {"version": VERSION, "placements": []}
	for region: String in REGIONS:
		var members: Array[Dictionary] = in_region(value, region)
		for index: int in range(members.size()):
			var entry: Dictionary = members[index].duplicate(true)
			entry["order"] = index
			result["placements"].append(entry)
	return result


static func in_region(layout: Dictionary, region: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in layout.get("placements", []):
		if entry["region"] == region:
			result.append(entry.duplicate(true))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["order"]) < int(b["order"]) if a["order"] != b["order"] else str(a["id"]) < str(b["id"]))
	return result


static func placement(layout: Dictionary, id: String) -> Dictionary:
	for entry: Dictionary in layout.get("placements", []):
		if entry["id"] == id:
			return entry.duplicate(true)
	return {}


static func minimum(form: String, region: String) -> Vector2:
	var narrow: float = 272.0 if region == "bottom" else 224.0
	match form:
		"wide": return Vector2(420, 128)
		"tall": return Vector2(narrow, 240)
		"major": return Vector2(460, 260)
	return Vector2(narrow, 128)


static func solve(layout: Dictionary, capacities: Dictionary) -> Dictionary:
	var result: Dictionary = {"items": {}, "regions": {}}
	if not validate(layout):
		return result
	for region: String in REGIONS:
		var available: Vector2 = capacities.get(region, Vector2.ZERO)
		if not available.is_finite():
			available = Vector2.ZERO
		available = available.max(Vector2.ZERO)
		var members: Array[Dictionary] = in_region(layout, region)
		var forms: Array[String] = []
		for member: Dictionary in members:
			var wanted: String = member["form"]
			var min_size: Vector2 = minimum(wanted, region)
			forms.append(wanted if min_size.x <= available.x and min_size.y <= available.y else "compact")
		# Compact the greatest primary-axis saving first, with stable order for ties.
		for attempt: int in range(IDS.size()):
			if _used(forms, region) <= _axis(available, region):
				break
			var best: int = -1
			var saving: float = 0.0
			for index: int in range(forms.size()):
				var delta: float = _axis(minimum(forms[index], region), region) - _axis(minimum("compact", region), region)
				if delta > saving or (delta == saving and delta > 0):
					best = index
					saving = delta
			if best < 0:
				break
			forms[best] = "compact"
		var cursor: float = 0.0
		var needed: Vector2 = available
		var surplus: float = maxf(0.0, available.x - _used(forms, region)) / maxf(1, members.size()) if region == "bottom" else 0.0
		for index: int in range(members.size()):
			var min_size: Vector2 = minimum(forms[index], region)
			var item_size: Vector2 = Vector2(min_size.x + surplus, maxf(min_size.y, available.y)) if region == "bottom" else Vector2(maxf(min_size.x, available.x), min_size.y)
			var origin: Vector2 = Vector2(cursor, 0) if region == "bottom" else Vector2(0, cursor)
			result["items"][members[index]["id"]] = {"region": region, "form": forms[index], "rect": Rect2(origin, item_size)}
			needed = needed.max(origin + item_size)
			cursor += _axis(item_size, region) + GAP
		result["regions"][region] = {"content_size": needed, "overflow": needed.x > available.x + 0.1 or needed.y > available.y + 0.1}
	return result


static func _axis(value: Vector2, region: String) -> float:
	return value.x if region == "bottom" else value.y


static func _used(forms: Array[String], region: String) -> float:
	var total: float = maxf(0, forms.size() - 1) * GAP
	for form: String in forms:
		total += _axis(minimum(form, region), region)
	return total


static func propose_move(layout: Dictionary, capacities: Dictionary, id: String, region: String, index: int) -> Dictionary:
	if not validate(layout) or id not in IDS or region not in REGIONS:
		return {}
	var current: Dictionary = placement(layout, id)
	var target: Array[Dictionary] = in_region(layout, region)
	target = target.filter(func(entry: Dictionary) -> bool: return entry["id"] != id)
	var other: Array[Dictionary] = in_region(layout, "right" if region == "bottom" else "bottom")
	other = other.filter(func(entry: Dictionary) -> bool: return entry["id"] != id)
	var moved: Dictionary = current.duplicate(true)
	moved["region"] = region
	target.insert(clampi(index, 0, target.size()), moved)
	for order: int in range(target.size()): target[order]["order"] = order
	for order: int in range(other.size()): other[order]["order"] = order
	var candidate: Dictionary = normalize({"version": VERSION, "placements": target + other})
	var resolved: Dictionary = solve(candidate, capacities)
	if bool(resolved["regions"][region]["overflow"]):
		return {}
	# A cross-rail move adapts the moved widget to the form actually offered by its preview.
	for entry: Dictionary in candidate["placements"]:
		if entry["id"] == id:
			entry["form"] = resolved["items"][id]["form"]
	return candidate


static func propose_form(layout: Dictionary, capacities: Dictionary, id: String, form: String) -> Dictionary:
	if not validate(layout) or id not in IDS or form not in FORMS:
		return {}
	var candidate: Dictionary = normalize(layout)
	var region: String = ""
	for entry: Dictionary in candidate["placements"]:
		if entry["id"] == id:
			entry["form"] = form
			region = entry["region"]
	var result: Dictionary = solve(candidate, capacities)
	if result["regions"][region]["overflow"] or result["items"][id]["form"] != form:
		return {}
	return candidate
