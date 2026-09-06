`timescale 1ps/1ps
`include "ShiftRegister.sv"
`include "LUT.sv"
`include "PlusAccumulator.sv"

//TB for Shift register

module TB();

localparam int N = 32;
localparam int bitWidth =16 ;

logic signed [(bitWidth-1):0] A ;
logic signed [(bitWidth-1):0] B [0:(N-1)];
logic signed [15:0] testCoef [0:7] ; 

logic signed [16:0] testAccumulatorA [0:7] ;
logic signed [19:0] testAccumulatorB ;

logic CLK; 
logic RST;
logic En ;

//--- DUT ---
ShiftRegister #(.N(N), .bitWidth(bitWidth)) DUT
(   
    .CLK(CLK),
    .RST(RST),
    .En(En),
    .Input(A),

    .Output(B)
) ;

LUT DUT_2 (
    .Enable(En),

    .outCoefficient(testCoef)
);

PlusAccumulator DUT_3 (
    .CLK(CLK),
    .RST(RST),
    .In(testAccumulatorA),

    .Out(testAccumulatorB)
);

//--- clock ---
initial CLK = 0 ;
always #5 CLK = ~CLK ;


//begin simulation 
    initial begin
        RST = 1;
        En  = 0;
        A   = 16'sd0;

        @(posedge CLK);
        @(posedge CLK);
        RST = 0;              // release reset
        En  = 1;

        // feed in N known values, one per clock
        for (int i = 0; i < N; i++) begin
            @(posedge CLK);
            A = i + 1;        
        end

        @(posedge CLK);
        En = 0;                // stop shifting, hold/blank output per your design

        #20;
        //test accumulator
        for (int i = 0; i < 8; i++) begin
        testAccumulatorA[i] = 17'b01111111111111111;
        end

        for (int i = 0; i < 21; i++) begin
            @(posedge CLK);
        end
        $finish;
    end
endmodule