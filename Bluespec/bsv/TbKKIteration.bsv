package TbKKIteration;

	import FixedPoint::*;
	import KKIteration::*;
	import Real::*;

	typedef 3 N;
	typedef 16 IW;
	typedef 16 FW;

	module mkTbKKIteration(Empty);

		Integer n = valueOf(N);
		Reg#(FixedPoint#(IW, FW)) rX[5][5];
		Reg#(UInt#(32)) rState <- mkReg(0);
		KKIteration#(FixedPoint#(IW, FW), N) kk <- mkFixedPointKKIteration();

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

		rule putData(rState < (fromInteger(n) * fromInteger(n)));
			UInt#(32) i = rState / fromInteger(n);
			UInt#(32) j = rState % fromInteger(n);

			kk.putElem(i, j, rX[i][j]);

			rState <= rState + 1;
		endrule

		rule iterate((fromInteger(n) * fromInteger(n)) == rState);
			kk.start();

			rState <= rState + 1;
		endrule

		rule waitAndPrintResults((rState > (fromInteger(n) * fromInteger(n))) && (rState <= (2 * fromInteger(n) * fromInteger(n))) && !kk.isRunning());
			UInt#(32) i = (rState - (fromInteger(n) * fromInteger(n)) - 1) / fromInteger(n);
			UInt#(32) j = (rState - (fromInteger(n) * fromInteger(n)) - 1) % fromInteger(n);

			fxptWrite(3, kk.getInvElem(i, j));
			if((fromInteger(n) - 1) == j)
				$write("\n");
			else
				$write(" ");

			rState <= rState + 1;
		endrule

		rule printTheRest(rState > (2 * fromInteger(n) * fromInteger(n)));
			$write("Determinant: ");
			fxptWrite(3, kk.getDet());
			$write("\n");
			$display("Division by zero? %d", kk.divZero());
			$display("Ticks: %d", kk.getCounter());

			$finish;
		endrule

	endmodule

endpackage
