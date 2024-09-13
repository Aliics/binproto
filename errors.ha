type decode_error = !(out_of_bounds | eof);

type out_of_bounds = !struct {
	limit: size,
	n: size,
};

type eof = !void;

