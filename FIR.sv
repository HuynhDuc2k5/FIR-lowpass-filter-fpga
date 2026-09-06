/*

Top module of FIR filter 
-include:
    -ShiftRegister
    -PlusAccumulator
    -LUT of cofficient 

-input:     Q1.15 fixed point signal 
-output:    Q5.15 fixed point signal 
-N-order:   7
-Fs:        100KHz  
-Fcut:      3KHz
*/

`include "LUT.sv"
`include "ShiftRegister.sv"
`include "PlusAccumulator.sv"

module FIR (
    input logic signed [15:0] In, 
    input logic En, 
    input logic CLK, 
    input logic RST,

    output logic signed [19:0] Out
);

//parameter
localparam N = 8;
localparam bitWidth = 16;

//variable calls 
logic signed [15:0] coefficient [0:7] ; 
logic signed [15:0] InputPipeline1 [0:(N-1)] ;
logic signed [32:0] InputPipeline2 [0:(N-1)] ;
logic signed [16:0] InputPipeline3 [0:(N-1)] ;
logic signed [19:0] OutputPipeline1 ;

//main system
LUT LUT (
    .Enable(En),

    .outCoefficient(coefficient)
);

ShiftRegister #(.N(N),.bitWidth(bitWidth)) ShiftRegister (
    .Input(In),
    .CLK(CLK),
    .RST(RST),

    .Output(InputPipeline1)
);

//multtiplier with coeffiecient
genvar i ; 
generate
    for (i = 0; i < 8; i++) begin 
        assign InputPipeline2[i] = (InputPipeline1[i] * coefficient[i]) ; 

        pipelineSigned #(.bitWidth(17)) PipelineBeforeAccumulate (
            .D(InputPipeline2[i][31:15]),
            .CLK(CLK),
            .RST(RST),

            .Q(InputPipeline3[i])
        );
    end
endgenerate

//accumulate
PlusAccumulator PlusAccumulator (
    .In(InputPipeline3),
    .CLK(CLK),
    .RST(RST),

    .Out(OutputPipeline1)
);

pipelineSigned #(.bitWidth(20))pipelineOutput (
    .D(OutputPipeline1),
    .CLK(CLK),
    .RST(RST),

    .Q(Out)
);

endmodule
