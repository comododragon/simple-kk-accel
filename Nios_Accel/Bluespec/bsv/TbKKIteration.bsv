/* ********************************************************************************************* */
/* * KK-Algorithm Hardware Testbench                                                           * */
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

package TbKKIteration;

	import FixedPoint::*;
	import KKIteration::*;
	import Real::*;

	/**
	 * @brief Matrix size.
	 */
	typedef 4 N;

	/**
	 * @brief Integer part (in bits) of fixedpoint.
	 */
	typedef 16 IW;

	/**
	 * @brief Fractional part (in bits) of fixedpoint.
	 */
	typedef 16 FW;

	module mkTbKKIteration(Empty);

		/* Cast to integer size of matrix */
		Integer n = valueOf(N);
		/* Test input matrix */
		Reg#(FixedPoint#(IW, FW)) rX[5][5];
		/* State register */
		Reg#(UInt#(32)) rState <- mkReg(0);
		/* KK Iterator using fixedpoint */
		KKIteration#(FixedPoint#(IW, FW), N) kk <- mkFixedPointKKIteration();

		/* Initialise vandermonde matrix */
		rX[0][0] <- mkReg(1.0);
		rX[0][1] <- mkReg(1.0);
		rX[0][2] <- mkReg(1.0);
		rX[0][3] <- mkReg(1.0);
		rX[0][4] <- mkReg(1.0);
		rX[1][0] <- mkReg(1.0);
		rX[1][1] <- mkReg(2.0);
		rX[1][2] <- mkReg(4.0);
		rX[1][3] <- mkReg(8.0);
		rX[1][4] <- mkReg(16.0);
		rX[2][0] <- mkReg(1.0);
		rX[2][1] <- mkReg(3.0);
		rX[2][2] <- mkReg(9.0);
		rX[2][3] <- mkReg(27.0);
		rX[2][4] <- mkReg(81.0);
		rX[3][0] <- mkReg(1.0);
		rX[3][1] <- mkReg(4.0);
		rX[3][2] <- mkReg(16.0);
		rX[3][3] <- mkReg(64.0);
		rX[3][4] <- mkReg(256.0);
		rX[4][0] <- mkReg(1.0);
		rX[4][1] <- mkReg(5.0);
		rX[4][2] <- mkReg(25.0);
		rX[4][3] <- mkReg(125.0);
		rX[4][4] <- mkReg(625.0);

		/* Put data on DUT */
		rule putData(rState < (fromInteger(n) * fromInteger(n)));
			UInt#(32) i = rState / fromInteger(n);
			UInt#(32) j = rState % fromInteger(n);

			kk.putElem(i, j, rX[i][j]);

			rState <= rState + 1;
		endrule

		/* Start DUT */
		rule iterate((fromInteger(n) * fromInteger(n)) == rState);
			kk.start();

			rState <= rState + 1;
		endrule

		/* Wait for DUT to finish and print intermediate matrix */
		rule waitAndPrintResults((rState > (fromInteger(n) * fromInteger(n))) && (rState <= (2 * fromInteger(n) * fromInteger(n))) && !kk.isRunning());
			UInt#(32) i = (rState - (fromInteger(n) * fromInteger(n)) - 1) / fromInteger(n);
			UInt#(32) j = (rState - (fromInteger(n) * fromInteger(n)) - 1) % fromInteger(n);

			fxptWrite(3, kk.getIntElem(i, j));
			if((fromInteger(n) - 1) == j)
				$write("\n");
			else
				$write(" ");

			rState <= rState + 1;
		endrule

		/* Print remaining information provided by the DUT */
		rule printTheRest(rState > (2 * fromInteger(n) * fromInteger(n)));
			$write("Determinant: ");
			fxptWrite(3, kk.getDetElem(0, 0));
			$write("\n");
			$display("Division by zero? %d", kk.divZero());
			$display("Ticks: %d", kk.getCounter());

			$finish;
		endrule

	endmodule

endpackage
