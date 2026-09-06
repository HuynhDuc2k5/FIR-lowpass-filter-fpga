`timescale 1ns/1ps
`include "FIR.sv"
//simulation FIR filter

module Simulation();

//signal 
logic CLK ; 
logic RST ; 
logic En ; 
logic signed [15:0] Input ; 
logic signed [19:0] Output ; 

int fd;

//clock 
localparam int freq = 100_000; //100Khz
localparam int period = 1_000_000_000/freq;
localparam int halfPeriod = period/2 ;

localparam int filterLatency = 20 ;
localparam int flushCycles   = filterLatency + 10 ;

initial CLK = 0 ;
always #(halfPeriod) CLK = ~CLK; 

// --- DUT ---
FIR DUT (
    .CLK(CLK),
    .RST(RST),
    .En(En),
    .In(Input),
    .Out(Output)
);

// ---read signal ---
localparam int samples = 1000 ;
logic signed [15:0] testFile [0:(samples-1)] ;
initial begin
    int readCount;
    $readmemh("NoisySignal.hex", testFile) ;
end

// --- write signal (dump output .hex file) ---
always @(posedge CLK) begin
    $fdisplay(fd, "%05h", Output);
end

//begin simulation
    initial begin 
    // Open the output file for writing
    fd = $fopen("FilteredOutput.hex", "w");
    if (fd == 0) begin
        $display("Error: Could not create FilteredOutput.hex");
        $finish;
    end

    RST <= 1 ; 
    En  <= 0 ; 
    Input <= '0 ; 

    //hold for 2 clk
    @(posedge CLK);
    @(posedge CLK);
    RST   <= 0 ; 
    En    <= 1; 
    Input <= 0 ;

    @(posedge CLK) ;
    //begin import the file
    for (int i = 0; i < samples ; i++) begin
        @(posedge CLK);
        Input <= testFile[i] ;
    end

    // outputs corresponding to the last samples are captured.
    repeat(flushCycles) @(posedge CLK);

    $display("=============================================");
    $display("==============Done simulation !==============");
    $display("=============================================");

    // Close the file safely before ending simulation
    $fclose(fd);
    $finish;
    end

endmodule