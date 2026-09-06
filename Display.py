#lib
import numpy as np 
import matplotlib.pyplot as plt 


def HexfileRead (fileName):

    hexData = []

    with open(fileName,'r') as file:
        for line in file: 
            cleanLine = line.split('//')[0].strip()

            if not cleanLine:
                continue

            hexData.append(cleanLine)

    return hexData


def FixedPointConverted(rawData, integer, fractional, signed=True):
    total_bits = integer + fractional

    fractional_mask = (1 << fractional) - 1
    integer_mask = ((1 << integer) - 1) << fractional

    def convert_one(value):
        if (isinstance(value, str)):
            value = int(value, 16)

        # handle two's complement signed 
        if (signed and value >= (1 << (total_bits - 1))):
            value -= (1 << total_bits)

        if (value < 0):
            sign = -1
        else:
            sign = 1

        magnitude = abs(value)

        #Integer part (Q I.F -> I)
        int_bits = (magnitude & integer_mask) >> fractional
        integerData = int_bits

        #Fractional part (Q I.F -> F)
        frac_bits = magnitude & fractional_mask
        fractionalData = frac_bits / (2 ** fractional)

        #Combine
        decimalData = sign * (integerData + fractionalData)

        return decimalData

    #loop
    if isinstance(rawData, (list, tuple)):
        return [convert_one(v) for v in rawData]
    else:
        #done ! 
        return convert_one(rawData)

    

#main
file = 'FilteredOutput.hex'

rawData = HexfileRead(
    fileName=file
)

decimalData = FixedPointConverted(
    rawData=rawData,
    integer=5,
    fractional=15
)

print(decimalData)

Frequency = 100
SamplingRate = 100000
N = len(decimalData)
 
t = np.arange(N) / SamplingRate
t_ms = t * 1000
 
plt.plot(t_ms, decimalData, color='blue', linewidth=1.5)
plt.title("system verilog filtered signal")
plt.xlabel("Time (ms)")
plt.ylabel("Amplitude")
plt.grid(True)
plt.tight_layout()
plt.show()