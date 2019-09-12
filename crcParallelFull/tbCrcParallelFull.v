module tbCrcParallelFull;
  parameter CRC_WIDTH = 16;
  parameter DWIDTH    = 32; //Must be n byte with n=1,2,3,4,...
  parameter TMP_WIDTH = DWIDTH*CRC_WIDTH;
  //
  //Inputs
  //
  reg clk;    //System clock
  reg rstN;   //System Reset
  reg ctrlEn; //CRC enable
  reg [DWIDTH-1:0] dataIn; //Data input
  reg [CRC_WIDTH-1:0] genPoly; //Generator Polynominal
  reg [CRC_WIDTH-1:0] initXorValue; //Initial value, set 0 if don't use
  reg refInEn;  //Reverse bit order in each input byte
  reg refOutEn; //Reverse bit order of CRC output
  reg [CRC_WIDTH-1:0] finalXorValue; //Final XOR value, set 0 if don't use
  //
  //Outputs
  //
  wire [CRC_WIDTH-1:0] crcOut;
  wire crcReady;
  //
  crcParallelFull crcParallelFull (
   clk,
   rstN,
   ctrlEn,
   dataIn,
   genPoly,
   initXorValue,
   refInEn,
   refOutEn,
   finalXorValue,
   crcOut,
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
    //genPoly = 16'h1021;
    genPoly = 16'h8005;
    initXorValue = 16'h0000;
    //initXorValue = 16'hffff;
    //initXorValue = 16'h1D0F;
    //initXorValue = 16'hB2AA;
    //initXorValue = 16'h89ec;
    finalXorValue = 16'h0000;
    //  finalXorValue = 16'hffff;
    refInEn  = 1'b0;
    refOutEn = 1'b0;
    #26
    dataIn = 32'h9abc_def0; 
    ctrlEn = 1'b1;
    refInEn  = 1'b0;
    refOutEn = 1'b0;
    #10
    ctrlEn = 1'b0;
    refInEn  = 1'b0;
    refOutEn = 1'b0;
    #20
    dataIn = 32'haaaa_5555;
    ctrlEn = 1'b1;
    refInEn  = 1'b1;
    refOutEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    refInEn  = 1'b0;
    refOutEn = 1'b0;
    #20
    dataIn = 32'h8998_6996;
    ctrlEn = 1'b1;
    refInEn  = 1'b1;
    refOutEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    refInEn  = 1'b0;
    refOutEn = 1'b0;
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
   if (rstN & risingCrcReady)
    $display ("--GenPoly: %8h \nInitial value: %8h \nFinal XOR value: %8h \nData input: %8h \nrefInEn: %b \nrefOutEn: %b\nCRC result: %8h\n", 
    genPoly, initXorValue, finalXorValue, dataIn, refInEn, refOutEn, crcOut);
  end
endmodule
