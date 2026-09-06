#noisy signal generator 
#frequency = 1k 
#generate file.hex 


import numpy as np 
import matplotlib.pyplot as plt 

#Functions 
#Noisy signal generate 
def NoisyGenerator (Magnitude, Frequency, SignalType, SamplingRate, N, NoiseMagnitude):
    t = np.arange(N)/ SamplingRate 

    Signal_Type = str(SignalType).lower() 
     
    if Signal_Type ==       'sine' :
        Signal = np.sin(2 * np.pi * Frequency * t)

    elif Signal_Type ==     'square' : 
        Signal = np.sign(np.sin(2 * np.pi * Frequency * t))

    elif Signal_Type ==     'sawtooth' :
        Signal = 2 * (t * Frequency - np.floor(0.5 + t * Frequency))

    else: 
        raise ValueError("Unsupported Signals types, try again with 'Sine' 'square' 'sawtooth'")

    #noise 
    Noise = np.random.normal(loc=0.0, scale = NoiseMagnitude, size = (N))

    NoisySignal = Signal*Magnitude + Noise 
    
    return t, Signal*Magnitude, NoisySignal


#hex file generate
def HexFileGenerator (Data, BitDept, FileName ="NoisySignal"): 
    #define boundaries 
    MinInt = -(1 << (BitDept - 1))      # -32768 
    MaxInt = (1 << BitDept - 1) - 1     # +32767


    MaxPeak = np.max(np.abs(Data))
    if MaxPeak == 0:
        ScaledSignal = Data 
    else: 
        ScaledFactor = MaxInt/MaxPeak
        ScaledSignal = Data * ScaledFactor

    #quantized_signal 
    QuantizedSignal = np.clip(np.round(ScaledSignal).astype(int),MinInt,MaxInt)

    Mask = (1 << BitDept) -1 
    HexValue = (BitDept + 3) //4 

    if not FileName.endswith('.hex'):
        FileName += '.hex'

    with open(FileName, 'w') as HexFile:
        for val in QuantizedSignal:
            TwoComplement = val & Mask 
            HexFile.write(f"{TwoComplement:0{HexValue}X}\n")

    print(f"Generate signed hex file with {len(Data)} sample ({BitDept}-bit)")
    return 

def FirFilter (coefficient, inputSignal, fs):
    #read the coefficient file of the FIR filter and then calculate

    coeff = np.array(coefficient,dtype=np.float64) 
    input = np.array(inputSignal,dtype=np.float64)

    output = np.convolve(input,coeff,mode='full')[:len(input)]

    t = np.arange(len(input)) /fs

    return t, output


#main 
#config signal 
Frequency = 100
SamplingRate = 100000
Magnitude = 1
N = 1000
coefficient = [0.0195057993440405,0.0640189492539742,0.166350660194901,0.250124591207085,0.250124591207085,0.166350660194901,0.0640189492539742,0.0195057993440405]

#config noise base on SNR 
SNRdB = 20  
SignalAverage = np.mean(Magnitude)                  #avarage power
SignalAveragedB = 10 * np.log10(SignalAverage)      #convert to dB
NoiseAveragedB = SignalAveragedB - SNRdB            #noise in dB
NoiseAverage = 10** (NoiseAveragedB/10)             #convert to watt

t, CleanSignal, NoisySignal = NoisyGenerator (
    Magnitude = Magnitude,
    Frequency = Frequency,
    SignalType = 'sine', 
    SamplingRate = SamplingRate, 
    N = N, 
    NoiseMagnitude = np.sqrt(NoiseAverage)
)

t_test, outputFiltered = FirFilter(
    coefficient = coefficient,
    inputSignal = NoisySignal,
    fs = SamplingRate 
)

t_ms = t * 1000
t_test_ms = t_test * 1000
#Hex file generate 
HexFileGenerator(NoisySignal,16)
#check number of sample 
print(N)

# Plotting
plt.figure(figsize=(12, 5))
plt.suptitle("Sine Wave Signal Comparison", fontsize=14)

# Subplot 1
plt.subplot(1, 3, 1)
plt.plot(t_ms, CleanSignal, color='blue', linewidth=1.5)
plt.title("Clean Signal ")
plt.xlabel("Time (ms)")
plt.ylabel("Amplitude")
plt.grid(True)

# Subplot 2
plt.subplot(1, 3, 2)
plt.plot(t_ms, NoisySignal, color='orange', alpha=0.8)
plt.title("Noisy Signal ")
plt.xlabel("Time (ms)")
plt.ylabel("Amplitude")
plt.grid(True)

# Subplot 3
plt.subplot(1, 3, 3)
plt.plot(t_ms, outputFiltered, color='orange', alpha=0.8)
plt.title("Ideal filtered signal")
plt.xlabel("Time (ms)")
plt.ylabel("Amplitude")
plt.grid(True)

plt.tight_layout()
plt.show()