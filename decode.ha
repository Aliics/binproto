type bindata = []u8;

type node = (bool | i16 | i32);

fn decode_bool(d: bindata) (bool | decode_error) = {
	assert_data_length(d, 1)?;
	return d[0] != 0;
};

fn decode_i16(d: bindata) (i16 | decode_error) = {
	assert_data_length(d, 2)?;
	return d[0]: i16 << 8 | d[1]: i16;
};

fn decode_i32(d: bindata) (i32 | decode_error) = {
	assert_data_length(d, 4)?;
	return d[0]: i32 << 24 | d[1]: i32 << 16 | d[2]: i32 << 8 | d[3]: i32;
};

fn assert_data_length(d: bindata, n: size) (void | decode_error) = {
	const l = len(d);
	if (l != n) return out_of_bounds { limit = l, n = n };
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

@test fn decode_i16_happy_path() void = {
	let i = decode_i16([0x0F, 0x2C])!;
	assert(i == 0x0F2C);
};

@test fn decode_i16_not_enough_bytes() void = {
	let i = decode_i16([0x0A]);
	assert(i is out_of_bounds);
};

@test fn decode_i32_happy_path() void = {
	let i = decode_i32([0x0A, 0x1B, 0xF2, 0xCC])!;
	assert(i == 0x0A1BF2CC);
};

@test fn decode_i32_not_enough_bytes() void = {
	let i = decode_i32([0x0A, 0x1B]);
	assert(i is out_of_bounds);
};
