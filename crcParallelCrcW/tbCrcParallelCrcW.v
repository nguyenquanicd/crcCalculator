module tbCrcParallelCrcW;
  //bit width of CRC sequence
  parameter CRC_WIDTH = 8;
  //bit width of data input
  parameter DWIDTH    = 32;
  //bit width of input of CRC calculator
  parameter CALWIDTH  = CRC_WIDTH;
  //Number of calculation times. Exmaple: 32/8 = 4
  parameter CALNUM  = DWIDTH/CALWIDTH;
  //bit width of shift counter
  //parameter COUNTERW  = clog2(CALNUM);
  //bit width of imtermediate signal
  //of CRC calculator
  parameter TMP_WIDTH = CALWIDTH*CRC_WIDTH;
  //
  //Inputs
  //
  reg clk;
  reg rstN;
  reg ctrlEn;
  reg [DWIDTH-1:0] dataIn;
  reg [CRC_WIDTH-1:0] GenPoly;
  //
  //Outputs
  //
  wire [CRC_WIDTH-1:0] crcSeq;
  wire crcReady;
  //
  crcParallelCrcW crcParallelCrcW (
   clk,
   rstN,
   ctrlEn,
   dataIn,
   GenPoly,
   crcSeq,
   crcReady
   );
  //
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rstN = 1'b0;
    #20
    rstN = 1'b1;
  end
  
  initial begin
    ctrlEn = 1'b0;
    //dataIn = 32'h0102_0304;
    //GenPoly = 8'b0001_1101; //0x1D
    GenPoly = 8'b0000_0111; //0x07
    //GenPoly = 8'b1101_0101; //0xD5
    //dataIn = 64'h0102_0304_0506_0708;
    //GenPoly = 16'h1021;
    #26
    //dataIn = 64'h0102_0304_0506_0708;
    dataIn = 32'h0102_0304;
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    wait (crcReady);
    #20
    dataIn = 32'haabb_ccdd;
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    wait (crcReady);
    #20
    dataIn = 32'hffff_0000;
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    wait (crcReady);
    #20
    dataIn = 32'h0000_0000;
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    wait (crcReady);
    #20
    dataIn = 32'hffff_ffff;
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    #200
    $stop;
  end
  reg crcReadyReg;
  wire risingCrcReady;
  always @ (posedge clk, negedge rstN) begin
    if (~rstN) crcReadyReg <= 1;
    else crcReadyReg <= crcReady;
  end
  assign risingCrcReady = ~crcReadyReg & crcReady;
  always @ (posedge clk) begin
   if (rstN & ctrlEn)
    $display ("--Data Input: %8h\n", dataIn);
   if (rstN & risingCrcReady)
    $display ("--CRC result: %2h\n\n", crcSeq);
  end
endmodule //tbCrcParallelCrcW
