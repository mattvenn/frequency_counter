import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.reset  <= 1

    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)

@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.clk, 83.3, units="ns") # 12 MHz
    cocotb.fork(clock.start())

#    input_signal = Clock(dut.signal, 2, units="us") # 500kHz
#    input_signal = Clock(dut.signal, 10, units="us") # 100kHz
    input_signal = Clock(dut.signal, 1.45, units="us") # 69kHz
    cocotb.fork(input_signal.start())

    await reset(dut)
    await ClockCycles(dut.clk, 2000)
