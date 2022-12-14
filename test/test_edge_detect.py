import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout

@cocotb.test()
async def test_edge_detect(dut):

    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # unsynchronised input signal
    for input_signal_period in [50, 100, 333, 600]:
        input_signal = cocotb.start_soon(Clock(dut.signal, input_signal_period,  units="us").start())

        # wait for unknown flip flop state to propagate and finish
        await ClockCycles(dut.clk, 10)

        for i in range(10):
            # wait for rising edge of input signal
            await RisingEdge(dut.signal)

            # edge detect must go high in at most 2 clock cycles
            for cycles in range(3):
                if dut.leading_edge_detect == 1:
                    break
                await RisingEdge(dut.clk)
            assert dut.leading_edge_detect == 1

            # wait for another full clock cycle 
            await RisingEdge(dut.clk)
            await FallingEdge(dut.clk)

            # assert edge detect is low
            assert dut.leading_edge_detect == 0

        input_signal.kill()
