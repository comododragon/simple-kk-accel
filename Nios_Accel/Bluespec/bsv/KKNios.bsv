/* ********************************************************************************************* */
/* * KK-Algorithm Hardware Interface to NIOS II Processor                                      * */
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

package KKNios;

	import FixedPoint::*;
	import KKIteration::*;
	import PulseReg::*;

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

	/**
	 * @brief NIOS II custom instruction interface.
	 */
	interface NIOSCustomInst;
		/**
		 * @brief Operate something inside this custom instruction.
		 *
		 * @param EN_operate (implicit wire) enable operation.
		 * @param dataA First operand.
		 * @param dataB Second operand.
		 * @param n Operation indicator.
		 */
		(* always_ready *)
		method Action operate(Bit#(32) dataA, Bit#(32) dataB, Bit#(8) n);

		/**
		 * @brief Get operation result.
		 *
		 * @return The result (valid when implicit wire RDY_getResult is asserted).
		 */
		method Bit#(32) getResult;
	endinterface

	module mkKKNios(NIOSCustomInst);

		/* First operand wire */
		Wire#(Bit#(32)) wDataA <- mkWire;
		/* Second operand wire */
		Wire#(Bit#(32)) wDataB <- mkWire;
		/* Operation indicator wire */
		Wire#(Bit#(8)) wN <- mkWire;
		/* Result register */
		Reg#(Bit#(32)) rRes <- mkRegU;
		/* PulseRegister, asserted when some operation is done */
		PulseReg rResValid <- mkPulseReg;
		/* KK Iterator using fixedpoint */
		KKIteration#(FixedPoint#(IW, FW), N) kk <- mkFixedPointKKIteration();

		/* Operation 0: Put element */
		rule putElem(0 == wN);
			/* First sixteen bits of dataA indicate index i, last 16 indicate j */
			UInt#(32) i = unpack(wDataA >> 16);
			UInt#(32) j = unpack(wDataA & 'hff);

			kk.putElem(i, j, unpack(wDataB));

			/* Assert operation is done */
			rResValid.send;
		endrule

		/* Operation 1: Start hardware */
		rule execute(1 == wN);
			kk.start;

			/* Assert operation is done */
			rResValid.send;
		endrule

		/* Operation 2 and further: Get values returned from hardware */
		rule getData(wN > 1);
			/* First sixteen bits of dataA indicate index i, last 16 indicate j */
			UInt#(32) i = unpack(wDataA >> 16);
			UInt#(32) j = unpack(wDataA & 'hff);

			/* Operation 2: Return isRunning flag */
			if(2 == wN)
				rRes <= extend(pack(kk.isRunning));
			/* Operation 3: Return cycles counter */
			else if(3 == wN)
				rRes <= pack(kk.getCounter);
			/* Operation 4: Return division by zero flag */
			else if(4 == wN)
				rRes <= extend(pack(kk.divZero));
			/* Operation 5: Return intermediate matrix element */
			else if(5 == wN)
				rRes <= pack(kk.getIntElem(i, j));
			/* Operation 6: Return determinant matrix element */
			else
				rRes <= pack(kk.getDetElem(i, j));

			/* Assert operation is done */
			rResValid.send;
		endrule

		/**
		 * @brief Operate something inside this custom instruction.
		 *
		 * @param EN_operate (implicit wire) enable operation.
		 * @param dataA First operand.
		 * @param dataB Second operand.
		 * @param n Operation indicator.
		 */
		method Action operate(Bit#(32) dataA, Bit#(32) dataB, Bit#(8) n);
			wDataA <= dataA;
			wDataB <= dataB;
			wN <= n;
		endmethod

		/**
		 * @brief Get operation result.
		 *
		 * @return The result (valid when implicit wire RDY_getResult is asserted).
		 */
		method Bit#(32) getResult if(rResValid);
			return rRes;
		endmethod

	endmodule

endpackage
