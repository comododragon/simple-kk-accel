/* ********************************************************************************************* */
/* * KK-Algorithm for Strongly Non-Singular Matrices Inversion (Hardware Accelerator)          * */
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

package KKIteration;

	import FixedPoint::*;
	import Vector::*;

	/**
	 * @brief KKIteration interface.
	 *
	 * @param t Type of matrix elements.
	 * @param nt Size of matrix.
	 */
	interface KKIteration#(type t, numeric type nt);
		/**
		 * @brief Put a matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 * @param a The element itself.
		 */
		method Action putElem(UInt#(32) i, UInt#(32) j, t a);

		/**
		 * @brief Get intermediate matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 *
		 * @return The element itself.
		 */
		method t getIntElem(UInt#(32) i, UInt#(32) j);

		/**
		 * @brief Get determinant matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 *
		 * @return The element itself.
		 */
		method t getDetElem(UInt#(32) i, UInt#(32) j);

		/**
		 * @brief Start process.
		 */
		method Action start;

		/**
		 * @brief Check if system is still running.
		 *
		 * @return True if system is still running, false otherwise.
		 */
		method Bool isRunning;

		/**
		 * @brief Get cycles counter.
		 *
		 * @return Number of cycles used to calculate.
		 */
		method UInt#(32) getCounter;

		/**
		 * @brief Get division by zero flag.
		 *
		 * @return True if division by zero occurred in last attempt.
		 */
		method Bool divZero;
	endinterface

	/**
	 * @brief Size (in bits) of state register, based on matrix size.
	 */
	`define STATEREGSZ TAdd#(TLog#(TAdd#(nt, 2)), 1)

	/**
	 * @brief Maximum possible value for state register based on STATEREGSZ.
	 */
	`define STATEMAXVAL TSub#(TExp#(TAdd#(TLog#(TAdd#(nt, 2)), 1)), 1)

	/**
	 * @brief Construct a Fixed-point KK iterator.
	 */
	module mkFixedPointKKIteration(KKIteration#(FixedPoint#(iw, fw), nt));

		/* Cast to integer size of matrix */
		Integer n = valueOf(nt);
		/* Cast to integer maximum value of state register */
		Integer stateMaxVal = valueOf(`STATEMAXVAL);
		/* Matrix registers */
		Reg#(FixedPoint#(iw, fw)) rX[3][n][n];
		/* State register */
		Reg#(UInt#(`STATEREGSZ)) rState <- mkReg(fromInteger(stateMaxVal));
		/* Cycles counter */
		Reg#(UInt#(32)) rCounter <- mkRegU;
		/* Division by zero flag */
		Reg#(Bool) rDivZero <- mkRegU;

		/* Initialise all registers */
		for(Integer k = 0; k < 3; k = (k + 1))
			for(Integer i = 0; i < n; i = (i + 1))
				for(Integer j = 0; j < n; j = (j + 1))
					rX[k][i][j] <- mkRegU;

		/* State MAX-1: Initialise variables */
		rule init((fromInteger(stateMaxVal) - 1) == rState);
			rCounter <= 0;
			rDivZero <= False;

			rState <= 0;
		endrule

		/* State 0..(MAX-2): Calculate iterations */
		rule iterate(rState < (fromInteger(stateMaxVal) - 1));
			/* Indexes for previous, current and next matrix */
			UInt#(`STATEREGSZ) iPrev = rState % 3;
			UInt#(`STATEREGSZ) iCurr = (rState + 1) % 3;
			UInt#(`STATEREGSZ) iNext = (rState + 2) % 3;

			/* Calculate iteration */
			for(Integer i = 0; i < n; i = (i + 1)) begin
				for(Integer j = 0; j < n; j = (j + 1)) begin
					rX[iNext][i][j] <= ((rX[iCurr][i][j] * rX[iCurr][(i + 1) % n][(j + 1) % n]) - (rX[iCurr][(i + 1) % n][j] * rX[iCurr][i][(j + 1) % n])) /
										((0 == rState)? 1.0 : rX[iPrev][(i + 1) % n][(j + 1) % n]);
				end
			end

			/* Jump to state MAX (idle state) if process is done */
			rState <= (fromInteger(n) - 1 == rState)? fromInteger(stateMaxVal) : (rState + 1);
		endrule

		/* Count how many cycles took to process */
		rule countCycles(rState < (fromInteger(stateMaxVal) - 1));
			rCounter <= rCounter + 1;
		endrule

		/**
		 * @brief Return input value (dummy function needed as an argument for reducing division by zero flag).
		 *
		 * @param in A boolean value.
		 *
		 * @return The same boolean value.
		 */
		function Bool isTrue(Bool in);
			return in;
		endfunction

		/* Check if division by zero would occur in any processing element */
		rule checkDivZero(rState < (fromInteger(stateMaxVal) - 1));
			Vector#(TMul#(nt, nt), Bool) divZero;

			/* For each position, check if element is zero (would cause division by zero) */
			for(Integer i = 0; i < n; i = (i + 1)) begin
				for(Integer j = 0; j < n; j = (j + 1)) begin
					divZero[(i * n) + j] = ((rState != 0) && (0 == rX[rState % 3][(i + 1) % n][(j + 1) % n]));
				end
			end

			/* If any divZero[i] is True, rDivZero is set to True */
			rDivZero <= any(isTrue, divZero);
		endrule

		/**
		 * @brief Put a matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 * @param a The element itself.
		 */
		method Action putElem(UInt#(32) i, UInt#(32) j, FixedPoint#(iw, fw) a);
			rX[1][i][j] <= a;
		endmethod

		/**
		 * @brief Get intermediate matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 *
		 * @return The element itself.
		 */
		method FixedPoint#(iw, fw) getIntElem(UInt#(32) i, UInt#(32) j);
			return rX[(n - 1) % 3][i][j];
		endmethod

		/**
		 * @brief Get determinant matrix element.
		 *
		 * @param i Line index.
		 * @param j Column index.
		 *
		 * @return The element itself.
		 */
		method FixedPoint#(iw, fw) getDetElem(UInt#(32) i, UInt#(32) j);
			return rX[n % 3][i][j];
		endmethod

		/**
		 * @brief Start process.
		 */
		method Action start;
			if(fromInteger(stateMaxVal) == rState)
				rState <= fromInteger(stateMaxVal) - 1;
		endmethod

		/**
		 * @brief Check if system is still running.
		 *
		 * @return True if system is still running, false otherwise.
		 */
		method Bool isRunning;
			return (rState != fromInteger(stateMaxVal));
		endmethod

		/**
		 * @brief Get cycles counter.
		 *
		 * @return Number of cycles used to calculate.
		 */
		method UInt#(32) getCounter;
			return rCounter;
		endmethod

		/**
		 * @brief Get division by zero flag.
		 *
		 * @return True if division by zero occurred in last attempt.
		 */
		method Bool divZero;
			return rDivZero;
		endmethod

	endmodule

endpackage