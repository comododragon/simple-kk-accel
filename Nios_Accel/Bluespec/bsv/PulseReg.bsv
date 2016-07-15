/* ********************************************************************************************* */
/* * PulseReg Module (Similar to PulseWire but using register because why not?)                * */
/* * Author: André Bannwart Perina                                                             * */
/* ********************************************************************************************* */
/* * Copyright (c) 2016 André B. Perina                                                        * */
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

package PulseReg;

	/**
	 * @brief PulseReg Interface.
	 */
	interface PulseReg;
		/**
		 * @brief Send a pulse.
		 */
		(* always_ready *)
		method Action send;

		/**
		 * @brief Read status.
		 *
		 * @return True if pulse received, false otherwise.
		 */
		method Bool _read;
	endinterface

	/**
	 * @brief Standard (and only) PulseReg constructor.
	 */
	module mkPulseReg(PulseReg);

		/* Pulse register */
		Reg#(Bool) rPulse <- mkReg(False);
		/* PulseWire used to override deassert if send is called continuously */
		PulseWire wDontDepulse <- mkPulseWire;

		/* Deassert pulse register (overriden if send is called once again) */
		rule depulse(!wDontDepulse && rPulse);
			rPulse <= False;
		endrule

		/**
		 * @brief Send a pulse.
		 */
		method Action send;
			/* Override depulsing */
			wDontDepulse.send;

			/* Assert pulse register */
			rPulse <= True;
		endmethod

		/**
		 * @brief Read status.
		 *
		 * @return True if pulse received, false otherwise.
		 */
		method Bool _read;
			return rPulse;
		endmethod

	endmodule

endpackage
