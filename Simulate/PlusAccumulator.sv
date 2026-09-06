/*

Plus accumulator module 
N - order = 8, with N divisible by 2
-pipeline register
-input: Q2.15 
*/

module PlusAccumulator 
(
    input logic CLK, 
    input logic RST,
    input logic signed [16:0] In [0:7], 

    output logic signed [19:0] Out 
); 

//stage 1
logic signed [17:0] stage1Sum [0:3] ;
logic signed [17:0] stage1Reg [0:3] ;
//stage 2
logic signed [18:0] stage2Sum [0:1] ;
logic signed [18:0] stage2Reg [0:1] ;
//stage 3
logic signed [19:0] stage3Sum ;

//stage 1 block
genvar i ; 
generate
    //stage 1
    for(i = 0; i < 4; i++) begin: stage1
        assign stage1Sum[i] = In[i*2] + In[i*2 + 1] ;

        pipelineSigned #(.bitWidth(18)) stage1Pipeline(
            .CLK(CLK),
            .RST(RST),
            .D(stage1Sum[i]),

            .Q(stage1Reg[i])
        );
    end 

    //stage 2
    for(i = 0; i < 2; i++) begin: stage2 
        assign stage2Sum[i] = stage1Reg[i*2] + stage1Reg[i*2 + 1] ;

        pipelineSigned #(.bitWidth(19)) stage2Pipeline(
            .CLK(CLK),
            .RST(RST),
            .D(stage2Sum[i]),

            .Q(stage2Reg[i])
        );
    end 

endgenerate

//stage 3 
assign stage3Sum = stage2Reg[0] + stage2Reg[1] ;

pipelineSigned #(.bitWidth(20)) stage3Pipeline(
    .CLK(CLK),
    .RST(RST),
    .D(stage3Sum),

    .Q(Out)
);

endmodule

module pipelineSigned 
#(parameter int bitWidth)
(
    input logic CLK, 
    input logic RST,
    input logic signed [(bitWidth-1):0] D, 

    output logic signed [(bitWidth-1):0] Q
);

always_ff @(posedge CLK or posedge RST ) begin
    if(RST) begin
        Q <= '0 ; 
    end

    else begin
        Q <= D ;
    end
end
endmodule