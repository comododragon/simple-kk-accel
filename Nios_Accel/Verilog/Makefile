SRCS=src/mkKKAvalonSlave_tb.v ../Bluespec/verilog/mkKKAvalonSlave.v src/FIFO2.v
BIN=bin/mkKKAvalonSlave_tb

$(BIN): $(SRCS)
	iverilog $(SRCS) -o $(BIN)

clean:
	rm -f $(BIN)
