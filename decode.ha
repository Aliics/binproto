type bindata = []u8;

type decode_error = !(out_of_bounds | eof);

type out_of_bounds = !struct {
	limit: int,
	n: int,
};

type eof = !void;

fn decode_int(d: bindata) (int | decode_error) = {
	let l = len(d);
	if (l != 4) return out_of_bounds { limit = l: int, n = 4 };

	return d[0]: int << 24 | d[1]: int << 16 | d[2]: int << 8 | d[3]: int;
};

@test fn decode_int_happy_path() void = {
	let i = decode_int([0x0A, 0x1B, 0xF2, 0xCC])!;
	assert(i == 0x0A1BF2CC);
};

@test fn decode_int_not_enough_bytes() void = {
	let i = decode_int([0x0A, 0x1B]);
	assert(i is out_of_bounds);
};
