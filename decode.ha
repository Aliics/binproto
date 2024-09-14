export type bindata = []u8;

export type node = (bool | i16 | i32 | i64);

export fn decode_bool(d: bindata) (bool | decode_error) = {
	assert_data_length(d, 1)?;
	return d[0] != 0;
};

export fn decode_i16(d: bindata) (i16 | decode_error) = {
	assert_data_length(d, 2)?;
	return d[0]: i16 << 8 | d[1]: i16;
};

export fn decode_i32(d: bindata) (i32 | decode_error) = {
	assert_data_length(d, 4)?;
	let n: i32 = 0;
	for (let i = 0z; i < 4; i += 1) {
		const bit_range = 32 - (i + 1) * 8;
		n |= d[i]: i32 << bit_range: i32;
	};
	return n;
};

export fn decode_i64(d: bindata) (i64 | decode_error) = {
	assert_data_length(d, 8)?;
	let n: i64 = 0;
	for (let i = 0z; i < 8; i += 1) {
		const bit_range = 64 - (i + 1) * 8;
		n |= d[i]: i64 << bit_range: i64;
	};
	return n;
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

@test fn decode_bool_not_enough_bytes() void = {
	let e = decode_bool([]): out_of_bounds;
	assert(e.limit == 0);
	assert(e.n == 1);
};

@test fn decode_bool_too_many_bytes() void = {
	let e = decode_bool([0x0A, 0x1B]): out_of_bounds;
	assert(e.limit == 2);
	assert(e.n == 1);
};

@test fn decode_i16_happy_path() void = {
	let i = decode_i16([0x0F, 0x2C])!;
	assert(i == 0x0F2C);
};

@test fn decode_i16_not_enough_bytes() void = {
	let e = decode_i16([0x0A]): out_of_bounds;
	assert(e.limit == 1);
	assert(e.n == 2);
};

@test fn decode_i16_too_many_bytes() void = {
	let e = decode_i16([0x0A, 0xFF, 0xFF]): out_of_bounds;
	assert(e.limit == 3);
	assert(e.n == 2);
};

@test fn decode_i32_happy_path() void = {
	let i = decode_i32([0x0A, 0x1B, 0xF2, 0xCC])!;
	assert(i == 0x0A1BF2CC);
};

@test fn decode_i32_not_enough_bytes() void = {
	let e = decode_i32([0x0A, 0x1B]): out_of_bounds;
	assert(e.limit == 2);
	assert(e.n == 4);
};

@test fn decode_i32_too_many_bytes() void = {
	let e = decode_i32([0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF]): out_of_bounds;
	assert(e.limit == 6);
	assert(e.n == 4);
};

@test fn decode_i64_happy_path() void = {
	let i = decode_i64([0x0A, 0x1B, 0xF2, 0xCC, 0x0A, 0x1B, 0xF2, 0xCC])!;
	assert(i == 0x0A1BF2CC0A1BF2CC);
};

@test fn decode_i64_not_enough_bytes() void = {
	let e = decode_i64([0x0A, 0x1B, 0x3C]): out_of_bounds;
	assert(e.limit == 3);
	assert(e.n == 8);
};

@test fn decode_i64_too_many_bytes() void = {
	let e = decode_i64([0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]): out_of_bounds;
	assert(e.limit == 9);
	assert(e.n == 8);
};
