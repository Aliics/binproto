export type decode_error = !(out_of_bounds | eof);

export type out_of_bounds = !struct {
	limit: size,
	n: size,
};

export type eof = !void;

