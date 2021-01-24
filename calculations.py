#!/usr/bin/python3
import pint, math
ureg = pint.UnitRegistry()

clock_freq = 12 * ureg.MHz
clock_period = 1/clock_freq

clocks_per_period = 1200
bits_needed = math.ceil(math.log(clocks_per_period)/math.log(2))

print("bits needed for clocks per period %d = %d" % (clocks_per_period, bits_needed))
print("max clocks in %d bits = %d" % (bits_needed, 2 ** bits_needed))

count_period = clocks_per_period * clock_period.to(ureg.us)
print("count period is %s" % count_period)
print("period frequency is %s" % (1/count_period).to(ureg.kHz))

for i in range(1,100):
    print("%02d = %s = %s" % (i, (i/count_period).to(ureg.MHz), (count_period/i).to(ureg.us)))
