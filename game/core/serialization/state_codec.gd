class_name StateCodec
extends RefCounted

static func bounded_integer(value: Variant, maximum: int, minimum: int = 0) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	var number: float = float(value)
	return is_finite(number) and number >= float(minimum) \
		and number <= float(maximum) and number == floor(number)


static func signed_integer_text(value: Variant) -> bool:
	if not value is String:
		return false
	var text: String = value
	if text.is_empty() or text.length() > 20 or not text.is_valid_int():
		return false
	var negative: bool = text.begins_with("-")
	var digits: String = text.substr(1) if negative else text
	var limit: String = "9223372036854775808" if negative else "9223372036854775807"
	if digits.length() > limit.length() or (digits.length() == limit.length() and digits > limit):
		return false
	# The range check above prevents overflow before conversion.
	return str(text.to_int()) == text


static func fingerprint(value: Dictionary) -> String:
	# Caller supplies normalized bounded integer/string/bool data, never live objects.
	return JSON.stringify(value, "", true, true).sha256_text()
