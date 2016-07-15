/* ********************************************************************************************* */
/* * KK-Algorithm Hardware Interface to NIOS II Processor Testbench                            * */
/* * Authors: André Bannwart Perina, Luciano Falqueto, Rodrigo Brunelli                        * */
/* * Based on algorithm developed by Rajani M. Kant and Takayuki Kimura                        * */
/* * Available at: http://dl.acm.org/citation.cfm?id=803034                                    * */
/* ********************************************************************************************* */
/* * Copyright (c) 2016 André B. Perina                                                        * */
/* *                    Luciano Falqueto                                                       * */
/* *                    Rodrigo Brunelli                                                       * */
/* *                                                                                           * */
/* * Permission is hereby granted, free of charge, to any person obtaining a copy of this      * */
/* * software and associated documentation files (the "Software"), to deal in the Software     * */
/* * without restriction, including without limitation the rights to use, copy, modify,        * */
/* * merge, publish, distribute, sublicense, and/or sell copies of the Software, and to        * */
/* * permit persons to whom the Software is furnished to do so, subject to the following       * */
/* * conditions:                                                                               * */
/* *                                                                                           * */
/* * The above copyright notice and this permission notice shall be included in all copies     * */
/* * or substantial portions of the Software.                                                  * */
/* *                                                                                           * */
/* * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,       * */
/* * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  * */
/* * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE * */
/* * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR      * */
/* * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER    * */
/* * DEALINGS IN THE SOFTWARE.                                                                 * */
/* ********************************************************************************************* */

`timescale 1ns/1ps
`define BSV_POSITIVE_RESET

/* NOTE: Assuming DUT hardware is set with values N = 4, IW and FW = 16 */

module mkKKNiosTb;

	/* Registers to and from DUT */
	reg rClk;
	reg rRst;
	reg rStart;
	reg [7:0] rN;
	reg [31:0] rDataA;
	reg [31:0] rDataB;
	wire wDone;
	wire [31:0] wResult;

	initial begin
		/* Initialise dumping and variables */
		$dumpfile("mkKKNios_tb.vcd");
		$dumpvars(1, rClk, rRst, rStart, rN, rDataA, rDataB, wDone, wResult);
		rClk <= 'b0;
		rRst <= 'b1;
		rStart <= 'b0;
		rN <= 'h0;
		rDataA <= 'h0;
		rDataB <= 'h0;

		/* Deassert reset */
		#50 @(posedge rClk);
		rRst <= 'b0;

		/* Put matrix element (0,0) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00000000;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (0,1) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00000001;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (0,2) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00000002;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (0,3) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00000003;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (1,0) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00010000;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (1,1) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00010001;
		rDataB <= 'h00020000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (1,2) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00010002;
		rDataB <= 'h00040000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (1,3) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00010003;
		rDataB <= 'h00080000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (2,0) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00020000;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (2,1) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00020001;
		rDataB <= 'h00030000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (2,2) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00020002;
		rDataB <= 'h00090000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (2,3) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00020003;
		rDataB <= 'h001B0000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (3,0) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00030000;
		rDataB <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (3,1) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00030001;
		rDataB <= 'h00040000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (3,2) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00030002;
		rDataB <= 'h00100000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Put matrix element (3,3) */
		#50 @(posedge rClk);
		rN <= 'h0;
		rDataA <= 'h00030003;
		rDataB <= 'h00400000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Start iterations */
		#50 @(posedge rClk);
		rN <= 'h1;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get isRunning flag (should be still running) */
		#50 @(posedge rClk);
		rN <= 'h2;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get isRunning flag (should be done for now) */
		#50 @(posedge rClk);
		rN <= 'h2;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get cycles counter */
		#50 @(posedge rClk);
		rN <= 'h3;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get division by zero flag */
		#50 @(posedge rClk);
		rN <= 'h4;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (0,0) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00000000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (0,1) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00000001;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (0,2) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00000002;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (0,3) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00000003;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (1,0) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00010000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (1,1) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00010001;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (1,2) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00010002;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (1,3) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00010003;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (2,0) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00020000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (2,1) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00020001;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (2,2) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00020002;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (2,3) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00020003;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (3,0) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00030000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (3,1) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00030001;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (3,2) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00030002;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get intermediate matrix element (3,3) */
		#50 @(posedge rClk);
		rN <= 'h5;
		rDataA <= 'h00030003;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* Get determinant matrix element (0,0) */
		#50 @(posedge rClk);
		rN <= 'h6;
		rDataA <= 'h00000000;
		#50 @(posedge rClk);
		rStart <= 'b1;
		#50 @(posedge rClk);
		rStart <= 'b0;
		@(wDone);

		/* We're done */
		#50 @(posedge rClk);
		$finish;
	end

	/* Toggle clock */
	always begin
		#50 rClk <= ~rClk;
	end

	/* Connect DUT */
	mkKKNios inst(
		.CLK(rClk),
		.RST(rRst),

		.EN_operate(rStart),
		.operate_n(rN),
		.operate_dataA(rDataA),
		.operate_dataB(rDataB),

		.RDY_getResult(wDone),
		.getResult(wResult)
	);

endmodule
