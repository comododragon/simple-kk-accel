SRCS=src/mkKKNios_tb.v src/mkKKNios.v
BIN=bin/mkKKNios_tb

$(BIN): $(SRCS)
	iverilog $(SRCS) -o $(BIN)

clean:
	rm -f $(BIN)
