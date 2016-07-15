module TOP(
		CLOCK_50,
		KEY
	);

	input CLOCK_50;
	input [3:0] KEY;

	KKNiosQsys inst(
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY[0])
	);

endmodule