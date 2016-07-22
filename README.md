# Accelerated KK Inversion Algorithm

## Authors

* André Bannwart Perina
* Luciano Falqueto
* Rodrigo Brunelli

## Notes

This project was based on an algorithm available [here](http://dl.acm.org/citation.cfm?id=803034).

## Notes about Bluespec Avalon Interface

Bluespec Avalon Interface was developed by Kermin Fleming and Paulo Matias, Copyright (c) 2008 under MIT license.

See `AvalonCommon.bsv`, `AvalonMaster.bsv` or `AvalonSlave.bsv` for further details.

## Files description

* **Nios:** Quartus II project of a NIOS II system for inverting matrixes without acceleration
	* **software:** Nios II EDS project folder
		* **KKNios:** Inversion C project
			* **main.c:** Source file
		* **KKNios_bsp:** BSP project for current system
	* **KKNios.qpf:** Quartus II project file
	* **KKNios.qsf:** Quartus II assignments file
	* **KKNiosQsys.qsys:** Qsys system containing NIOS II
	* **KKNiosQsys.sopcinfo:** Qsys system output description file used by NIOS II EDS
	* **TOP.v:** Top-level Verilog file for current project
	* **de2i_150_golden_top.tcl:** Script containing all pin assignments for DE2i-150 development kit
* **Nios_accel:** Quartus II project of a NIOS II system for inverting matrixes with hardware acceleration
	* **Bluespec:** Bluespec project folder
		* **bsv:** Bluespec source files folder
			* **AvalonCommon.bsv:** Common definitions for Avalon-MM Bluespec modules
			* **AvalonMaster.bsv:** Avalon-MM Master module
			* **AvalonSlave.bsv:** Avalon-MM Slave module
			* **KKAvalonSlave.bsv:** Inversion accelerator interfaced through Avalon-MM Slave (wrapper module)
			* **KKIteration.bsv:** Inversion accelerator with no standard interface (inner module)
			* **TbKKIteration.bsv:** Testbench for KKIteration module
		* **KKAvalonSlave.bspec:** Synthesisable KKAvalonSlave project
		* **TbKKIteration.bspec:** Simulation KKIteration project
	* **Quartus:** Quartus II projects
		* **Standalone:** Quartus II project for compiling accelerator by itself (only for resource counting)
		* **System:** Quartus II project of a NIOS II system for inverting matrixes with acceleration
			* **software:** Nios II EDS project folder
				* **KKNios:** Inversion C project
					* **main.c:** Source file
				* **KKNios_bsp:** BSP project for current system
			* **KKNios.out.sdc:** Timing constraints for this project
			* **KKNios.qpf:** Quartus II project file
			* **KKNios.qsf:** Quartus II assignments file
			* **KKNiosQsys.qsys:** Qsys system containing NIOS II and accelerator
			* **KKNiosQsys.sopcinfo:** Qsys system output description file used by NIOS II EDS
			* **TOP.v:** Top-level Verilog file for current project
			* **de2i_150_golden_top.tcl:** Script containing all pin assignments for DE2i-150 development kit
			* **kk_accel_hw.tcl:** Qsys description file for accelerator module
	* **Verilog:** Verilog files folder
		* **src:** Verilog sources
			* **FIFO2.v:** Bluespec FIFO module used by accelerator
			* **mkKKAvalonSlave_tb.v:** Testbench for KKAvalonSlave module
		* **Makefile:** Makefile for testbench
* **PC:** Plain C version of algorithm with no acceleration
	* **main.c:** Algorithm in C

## How to compile Bluespec files

NOTE: Bluespec version used: 2014.07A

1. Create empty folders used by the project (inside `/Nios_accel/Bluespec/`):
	* `bluesim`
	* `boba`
	* `info`
	* `verilog`
1. Open Bluespec Workstation
2. Open desired project (`*.bspec`)
	* `KKAvalonSlave.bspec` is only for synthesis, no Bluesim simulation available
	* `TbKKIteration.bspec` is only for Bluesim simulation

## How to compile Verilog testbench file

1. Compile Bluespec project for synthesis (`KKAvalonSlave.bspec`)
1. Create empty folder used by the project (inside `/Nios_accel/Verilog/`):
	* `bin`
2. Make sure you have `iverilog` simulator installed
3. Run `make`
4. Run `./bin/mkKKAvalonSlave_tb`
5. Use waveform software to view generated vcd file, such as GtkWave

## How to compile Quartus II project

NOTE: Quartus projects are ready for use in Terasic DE2i-150 development kit. Other kits may need pin reassignments.

NOTE2: Quartus II version used: 14.1

1. Compile Bluespec project for synthesis (`KKAvalonSlave.bspec`) if project to be compiled uses hardware acceleration
2. Open desired project (`*.qpf`) in quartus
3. Generate Qsys project using available Qsys file
4. Compile project
5. Open NIOS II EDS and import projects inside `/Nios/software/` or `/Nios_accel/Quartus/System/software/` folder
6. Compile software and run