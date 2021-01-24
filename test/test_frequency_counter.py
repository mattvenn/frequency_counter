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
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())

    input_signal = Clock(dut.signal, 80, units="us")
    cocotb.fork(input_signal.start())

    await reset(dut)
    await ClockCycles(dut.clk, 2000)
