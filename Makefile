# FPGA variables
PROJECT = fpga/frequency_counter
SOURCES= src/frequency_counter.v src/seven_segment.v src/edge_detect.v
ICEBREAKER_DEVICE = up5k
ICEBREAKER_PIN_DEF = fpga/icebreaker.pcf
ICEBREAKER_PACKAGE = sg48
SEED = 1

# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH := test:$(PYTHONPATH)
export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

all: test_frequency_counter test_seven_segment

# if you run rules with NOASSERT=1 it will set PYTHONOPTIMIZE, which turns off assertions in the tests
test_edge_detect:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s edge_detect -s dump -g2012 src/edge_detect.v test/dump_edge_detect.v 
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_edge_detect vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_frequency_counter:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s frequency_counter -s dump -g2012 src/frequency_counter.v src/edge_detect.v src/seven_segment.v test/dump_frequency_counter.v 
	PYTHONOPTIMIZE=${NOASSERT} TESTCASE=test_all MODULE=test.test_frequency_counter vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_frequency_counter_with_period:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s frequency_counter -s dump -g2012 src/frequency_counter.v src/edge_detect.v src/seven_segment.v test/dump_frequency_counter.v 
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_frequency_counter vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

test_seven_segment:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s seven_segment -s dump -g2012 src/seven_segment.v test/dump_seven_segment.v 
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_seven_segment vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp
	! grep failure results.xml

show_%: %.vcd %.gtkw
	gtkwave $^

# FPGA recipes

show_synth_%: src/%.v
	yosys -p "read_verilog $<; proc; opt; show -colors 2 -width -signed"

%.json: $(SOURCES)
	yosys -l fpga/yosys.log -p 'synth_ice40 -top frequency_counter -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l fpga/nextpnr.log --seed $(SEED) --freq 20 --package $(ICEBREAKER_PACKAGE) --$(ICEBREAKER_DEVICE) --asc $@ --pcf $(ICEBREAKER_PIN_DEF) --json $<

%.bin: %.asc
	icepack $< $@

prog: $(PROJECT).bin
	iceprog $<

# general recipes

lint:
	verible-verilog-lint src/*v --rules_config verible.rules

clean:
	rm -rf *vcd sim_build fpga/*log fpga/*bin test/__pycache__

.PHONY: clean
