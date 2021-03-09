import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout
import random

async def reset(dut):
    dut.reset  <= 1
    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    dut.load <= 0;
    await ClockCycles(dut.clk, 5)

segments = {
    63  : 0,
    6   : 1,
    91  : 2,
    79  : 3,
    102 : 4,
    109 : 5,
    124 : 6,
    7   : 7,
    127 : 8,
    103 : 9,
    }

async def read_segments(dut):
    await with_timeout(FallingEdge(dut.digit), 100, 'us')
    tens = segments[int(dut.segments)]
    await with_timeout(RisingEdge(dut.digit), 100, 'us')
    units = segments[int(dut.segments)]
    number = tens * 10 + units
    dut.log.debug("segments show %02d" % number)
    return number

@cocotb.test()
async def test_seven_segment(dut):

    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())

    await reset(dut)

    for tens in range(10):
        for units in range(10):
            dut.ten_count <= tens
            dut.unit_count <= units
            dut.load <= 1
            await ClockCycles(dut.clk, 1)
            dut.load <= 0
            await ClockCycles(dut.clk, 2) # have to wait a couple of cycles for flops
            assert await read_segments(dut) == tens * 10 + units
