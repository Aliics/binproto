type bindata = []u8;

type node = (bool | int);

fn decode_bool(d: bindata) (bool | decode_error) = {
	let l = len(d);
	if (l != 1) return out_of_bounds { limit = l, n = 1 };

	return d[0] != 0;
};

fn decode_int(d: bindata) (int | decode_error) = {
	let l = len(d);
	if (l != 4) return out_of_bounds { limit = l, n = 4 };

	return d[0]: int << 24 | d[1]: int << 16 | d[2]: int << 8 | d[3]: int;
};

@test fn decode_bool_happy_path() void = {
	let truthy = decode_bool([0x01])!;
	let falsy = decode_bool([0x00])!;
	assert(truthy);
	assert(!falsy);
};

@test fn decode_bool_too_many_bytes() void = {
	let i = decode_bool([0x0A, 0x1B]);
	assert(i is out_of_bounds);
};

@test fn decode_int_happy_path() void = {
	let i = decode_int([0x0A, 0x1B, 0xF2, 0xCC])!;
	assert(i == 0x0A1BF2CC);
};

@test fn decode_int_not_enough_bytes() void = {
	let i = decode_int([0x0A, 0x1B]);
	assert(i is out_of_bounds);
};
