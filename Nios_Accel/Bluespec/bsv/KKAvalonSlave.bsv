/* ********************************************************************************************* */
/* * KK-Algorithm Hardware Interface to Avalon-MM Slave                                        * */
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

package KKAvalonSlave;

	import AvalonCommon::*;
	import AvalonSlave::*;
	import ClientServer::*;
	import Connectable::*;
	import FIFO::*;
	import FixedPoint::*;
	import GetPut::*;
	import KKIteration::*;
	import SpecialFIFOs::*;

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
	 * @brief KK Avalon-MM Slave Interface.
	 */
	interface KKAvalonSlave;
		interface AvalonSlaveWires#(18, 32) s0;
	endinterface

	/**
	 * @brief Module constructor.
	 */
	module mkKKAvalonSlave(KKAvalonSlave);

		/* Avalon slave module and FIFO */
		AvalonSlave#(18, 32) aS <- mkAvalonSlave;
		FIFO#(AvalonRequest#(18, 32)) cliReq <- mkBypassFIFO;
		/* The KK iterator */
		KKIteration#(FixedPoint#(IW, FW), N) kk <- mkFixedPointKKIteration;

		/* Connect Avalon slave to FIFO */
		mkConnection(aS.busClient.request, toPut(cliReq));

		/**
		 * @brief Process a write transaction.
		 */
		rule processWrite(cliReq.first matches tagged AvalonRequest{addr:.addr, command:Write, data:.data});
			/**
			 * @brief Put matrix element.
			 * Address: --00 IIIIIIII JJJJJJJJ.
			 *     IIIIIIII : Line index.
			 *     JJJJJJJJ : Column index.
			 * Data: Element itself.
			 */
			if(2'b00 == truncate(addr >> 16)) begin
				/* First eight bits of addr indicate index i, last 8 indicate j */
				UInt#(32) i = extend(unpack((addr >> 8) & 'hff));
				UInt#(32) j = extend(unpack(addr & 'hff));

				kk.putElem(i, j, unpack(data));
			end
			/**
			 * @brief Start process.
			 * Address: --01 00000000 00000000.
			 * Data: None.
			 */
			else if((2'b01 == truncate(addr >> 16)) && (16'h0 == truncate(addr))) begin
				kk.start;
			end

			cliReq.deq;
		endrule

		/**
		 * @brief Process a read transaction.
		 */
		rule processRead(cliReq.first matches tagged AvalonRequest{addr:.addr, command:Read, data:.data});
			Bit#(32) res = 0;

			/**
			 * @brief Get isRunning.
			 * Address: --01 00000000 00000001.
			 * Data: None.
			 * Return: isRunning.
			 */
			if((2'b01 == truncate(addr >> 16)) && (16'h1 == truncate(addr))) begin
				res = extend(pack(kk.isRunning));
			end
			/**
			 * @brief Get cycle counter.
			 * Address: --01 00000000 00000002.
			 * Data: None.
			 * Return: cycle counter.
			 */
			else if((2'b01 == truncate(addr >> 16)) && (16'h2 == truncate(addr))) begin
				res = pack(kk.getCounter);
			end
			/**
			 * @brief Get division by zero flag.
			 * Address: --01 00000000 00000003.
			 * Data: None.
			 * Return: True if any division by zero occurred, False otherwise.
			 */
			else if((2'b01 == truncate(addr >> 16)) && (16'h3 == truncate(addr))) begin
				res = extend(pack(kk.divZero));
			end
			/**
			 * @brief Get intermediate matrix element.
			 * Address: --10 IIIIIIII JJJJJJJJ.
			 *     IIIIIIII : Line index.
			 *     JJJJJJJJ : Column index.
			 * Data: None.
			 * Return: Intermediate matrix element.
			 */
			else if(2'b10 == truncate(addr >> 16)) begin
				/* First eight bits of addr indicate index i, last 8 indicate j */
				UInt#(32) i = extend(unpack((addr >> 8) & 'hff));
				UInt#(32) j = extend(unpack(addr & 'hff));

				res = pack(kk.getIntElem(i, j));
			end
			/**
			 * @brief Get determinant matrix element.
			 * Address: --11 IIIIIIII JJJJJJJJ.
			 *     IIIIIIII : Line index.
			 *     JJJJJJJJ : Column index.
			 * Data: None.
			 * Return: Determinant matrix element.
			 */
			else if(2'b11 == truncate(addr >> 16)) begin
				/* First eight bits of addr indicate index i, last 8 indicate j */
				UInt#(32) i = extend(unpack((addr >> 8) & 'hff));
				UInt#(32) j = extend(unpack(addr & 'hff));

				res = pack(kk.getDetElem(i, j));
			end

			aS.busClient.response.put(res);

			cliReq.deq;
		endrule

		/* Export Avalon slave interface */
		interface s0 = aS.slaveWires;

	endmodule

endpackage
