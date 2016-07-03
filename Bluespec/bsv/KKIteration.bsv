// TODO: Comentar
// TODO: Implementar detector de divisao por zero
// TODO: Implementar contador de ciclos

package KKIteration;

	import FixedPoint::*;

	interface KKIteration#(type t, numeric type nt);
		method Action putElem(UInt#(32) i, UInt#(32) j, t a);
		method t getInvElem(UInt#(32) i, UInt#(32) j);
		method t getDet();
		method Action start();
		method Bool isRunning();
		method UInt#(32) getCounter();
		method Bool divZero();
	endinterface

	`define STATEREGSZ TAdd#(TLog#(TAdd#(nt, 2)), 1)
	`define STATEMAXVAL TSub#(TExp#(TAdd#(TLog#(TAdd#(nt, 2)), 1)), 1)

	module mkFixedPointKKIteration(KKIteration#(FixedPoint#(iw, fw), nt));


		Integer n = valueOf(nt);
		Integer stateMaxVal = valueOf(`STATEMAXVAL);
		Reg#(FixedPoint#(iw, fw)) rX[3][n][n];
		Reg#(UInt#(`STATEREGSZ)) rState <- mkReg(fromInteger(stateMaxVal));
		Reg#(UInt#(32)) rCounter <- mkRegU;
		Reg#(Bool) rDivZero <- mkRegU;

		for(Integer k = 0; k < 3; k = (k + 1))
			for(Integer i = 0; i < n; i = (i + 1))
				for(Integer j = 0; j < n; j = (j + 1))
					rX[k][i][j] <- mkRegU;

		rule init((fromInteger(stateMaxVal) - 1) == rState);
			rCounter <= 0;
			rDivZero <= False;

			rState <= 0;
		endrule

		rule iterate(rState < (fromInteger(stateMaxVal) - 1));
			UInt#(`STATEREGSZ) iPrev = rState % 3;
			UInt#(`STATEREGSZ) iCurr = (rState + 1) % 3;
			UInt#(`STATEREGSZ) iNext = (rState + 2) % 3;

			for(Integer i = 0; i < n; i = (i + 1)) begin
				for(Integer j = 0; j < n; j = (j + 1)) begin
					rX[iNext][i][j] <= ((rX[iCurr][i][j] * rX[iCurr][(i + 1) % n][(j + 1) % n]) - (rX[iCurr][(i + 1) % n][j] * rX[iCurr][i][(j + 1) % n])) /
										((0 == rState)? 1.0 : rX[iPrev][(i + 1) % n][(j + 1) % n]);
				end
			end

			// TODO: Rever essa condição de parada
			rState <= (fromInteger(n) - 1 == rState)? fromInteger(stateMaxVal) : (rState + 1);
		endrule

		method Action putElem(UInt#(32) i, UInt#(32) j, FixedPoint#(iw, fw) a);
			rX[1][i][j] <= a;
		endmethod

		method FixedPoint#(iw, fw) getInvElem(UInt#(32) i, UInt#(32) j);
			return rX[(n - 1) % 3][i][j];
		endmethod

		method FixedPoint#(iw, fw) getDet();
			return rX[n % 3][0][0];
		endmethod

		method Action start();
			if(fromInteger(stateMaxVal) == rState)
				rState <= fromInteger(stateMaxVal) - 1;
		endmethod

		method Bool isRunning();
			return (rState != fromInteger(stateMaxVal));
		endmethod

		method UInt#(32) getCounter();
			return rCounter;
		endmethod

		method Bool divZero();
			return True;
		endmethod


	endmodule

endpackage
