//-------------------------------------------
//Author  : Nguyen Hung Quan
//Website : https://nguyenquanicd.blogspot.com/
//Date    : 2019.Aug.26
// Function:
// -- testbench for crc calculator
//===================================================================================

module tbcrcInitialValue;
  parameter CRC_GPW_MAX = 8;
  parameter DWIDTH      = 16;
  parameter DWIDTH_LSB  = DWIDTH-CRC_GPW_MAX;
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

  crcInitialValue crcInitialValue (
     clk,
     rstN,
     ctrlEn,
     dataIn,
     GenPoly,
     crcSeq,
     crcReady
     );
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    rstN = 1'b0;
    #20
    rstN = 1'b1;
  end
  //
  initial begin
    ctrlEn  = 1'b0;
    dataIn = 16'b0000_1010_0101_0101; //0x0A_55
    GenPoly = 8'b1101_0101; //0xD5
    #26
    ctrlEn = 1'b1;
    #10
    ctrlEn = 1'b0;
    #200
    $stop;
  end
  //
endmodule
