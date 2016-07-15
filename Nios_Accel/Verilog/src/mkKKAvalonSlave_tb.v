/* ********************************************************************************************* */
/* * KK-Algorithm Hardware Interface to Avalon-MM Slave Testbench                              * */
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

/* NOTE: Assuming DUT hardware is set with values N = 4, IW and FW = 16 */

module mkKKAvalonSlave_Tb;

	/* Registers to and from DUT */
	reg rClk;
	reg rRstN;
	reg rRead;
	reg rWrite;
	reg [17:0] rAddress;
	reg [31:0] rWritedata;
	wire wWaitrequest;
	wire [31:0] wReaddata;
	wire wReaddatavalid;

	initial begin
		/* Initialise dumping and variables */
		$dumpfile("mkKKAvalonSlave_tb.vcd");
		$dumpvars(1, rClk, rRstN, rRead, rWrite, rAddress, rWritedata, wWaitrequest, wReaddata, wReaddatavalid);
		rClk <= 'b0;
		rRstN <= 'b0;
		rRead <= 'b0;
		rWrite <= 'b0;

		/* Deassert reset */
		#50 @(posedge rClk);
		rRstN <= 'b1;

		/* Put matrix element (0,0) */
		#50 @(posedge rClk);
		rAddress <= 'h00000;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (0,1) */
		#50 @(posedge rClk);
		rAddress <= 'h00001;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (0,2) */
		#50 @(posedge rClk);
		rAddress <= 'h00002;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (0,3) */
		#50 @(posedge rClk);
		rAddress <= 'h00003;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (1,0) */
		#50 @(posedge rClk);
		rAddress <= 'h00100;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (1,1) */
		#50 @(posedge rClk);
		rAddress <= 'h00101;
		rWritedata <= 'h00020000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (1,2) */
		#50 @(posedge rClk);
		rAddress <= 'h00102;
		rWritedata <= 'h00040000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (1,3) */
		#50 @(posedge rClk);
		rAddress <= 'h00103;
		rWritedata <= 'h00080000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (2,0) */
		#50 @(posedge rClk);
		rAddress <= 'h00200;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (2,1) */
		#50 @(posedge rClk);
		rAddress <= 'h00201;
		rWritedata <= 'h00030000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (2,2) */
		#50 @(posedge rClk);
		rAddress <= 'h00202;
		rWritedata <= 'h00090000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (2,3) */
		#50 @(posedge rClk);
		rAddress <= 'h00203;
		rWritedata <= 'h001B0000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (3,0) */
		#50 @(posedge rClk);
		rAddress <= 'h00300;
		rWritedata <= 'h00010000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (3,1) */
		#50 @(posedge rClk);
		rAddress <= 'h00301;
		rWritedata <= 'h00040000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (3,2) */
		#50 @(posedge rClk);
		rAddress <= 'h00302;
		rWritedata <= 'h00100000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Put matrix element (3,3) */
		#50 @(posedge rClk);
		rAddress <= 'h00303;
		rWritedata <= 'h00400000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Start process */
		#50 @(posedge rClk);
		rAddress <= 'h10000;
		#50 @(posedge rClk);
		rWrite <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rWrite <= 'b0;

		/* Get isRunning (should be still running) */
		#50 @(posedge rClk);
		rAddress <= 'h10001;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get isRunning (should be done by now) */
		#50 @(posedge rClk);
		rAddress <= 'h10001;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get cycle counter */
		#50 @(posedge rClk);
		rAddress <= 'h10002;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get division by zero flag */
		#50 @(posedge rClk);
		rAddress <= 'h10003;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (0,0) */
		#50 @(posedge rClk);
		rAddress <= 'h20000;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (0,1) */
		#50 @(posedge rClk);
		rAddress <= 'h20001;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (0,2) */
		#50 @(posedge rClk);
		rAddress <= 'h20002;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (0,3) */
		#50 @(posedge rClk);
		rAddress <= 'h20003;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (1,0) */
		#50 @(posedge rClk);
		rAddress <= 'h20100;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (1,1) */
		#50 @(posedge rClk);
		rAddress <= 'h20101;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (1,2) */
		#50 @(posedge rClk);
		rAddress <= 'h20102;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (1,3) */
		#50 @(posedge rClk);
		rAddress <= 'h20103;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (2,0) */
		#50 @(posedge rClk);
		rAddress <= 'h20200;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (2,1) */
		#50 @(posedge rClk);
		rAddress <= 'h20201;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (2,2) */
		#50 @(posedge rClk);
		rAddress <= 'h20202;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (2,3) */
		#50 @(posedge rClk);
		rAddress <= 'h20203;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (3,0) */
		#50 @(posedge rClk);
		rAddress <= 'h20300;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (3,1) */
		#50 @(posedge rClk);
		rAddress <= 'h20301;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (3,2) */
		#50 @(posedge rClk);
		rAddress <= 'h20302;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get intermediate matrix element (3,3) */
		#50 @(posedge rClk);
		rAddress <= 'h20303;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* Get determinant matrix element (0,0) */
		#50 @(posedge rClk);
		rAddress <= 'h30000;
		#50 @(posedge rClk);
		rRead <= 'b1;
		@(posedge rClk && !wWaitrequest);
		rRead <= 'b0;

		/* We're done */
		#50 @(posedge rClk);
		$finish;
	end

	/* Toggle clock */
	always begin
		#50 rClk <= ~rClk;
	end

	/* Connect DUT */
	mkKKAvalonSlave inst(
		.CLK(rClk),
		.RST_N(rRstN),

		.s0_read(rRead),
		.s0_write(rWrite),
		.s0_address(rAddress),
		.s0_writedata(rWritedata),
		.s0_waitrequest(wWaitrequest),
		.s0_readdata(wReaddata),
		.s0_readdatavalid(wReaddatavalid)
	);

endmodule
