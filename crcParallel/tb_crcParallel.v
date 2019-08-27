module tb_crcParallel;
  parameter CRC_GPW_MAX = 8;
  parameter DWIDTH      = 16;
  parameter TMP_WIDTH   = DWIDTH*CRC_GPW_MAX;
  //
  //Inputs
  //
  reg clk;
  reg rstN;
  reg ctrlEn;
  reg [DWIDTH-1:0] dataIn;
  reg [CRC_GPW_MAX-1:0] GenPoly;
  //
  //Outputs
  //
  wire [CRC_GPW_MAX-1:0] crcSeq;
  wire crcReady;
  //
  crcParallel crcParallel(
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
    dataIn = 16'b0000_0001_0000_0010; //0x01_02
    //GenPoly = 8'b0001_1101; //0x1D
    GenPoly = 8'b0000_0111; //0x07
    //GenPoly = 8'b1101_0101; //0xD5
    #26
    dataIn = 16'b0000_0001_0000_0010; //0x01_02
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    #20
    dataIn = 16'b1010_0101_0010_0010; //0xa5_22
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    #20
    dataIn = 16'b1111_0000_1110_0101; //0xF0_E5
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
   if (rstN & risingCrcReady)
    $display ("--CRC result: %8h\n", crcSeq);
  end
endmodule
