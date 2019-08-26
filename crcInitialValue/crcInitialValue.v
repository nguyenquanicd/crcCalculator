//-------------------------------------------
//Author  : Nguyen Hung Quan
//Website : https://nguyenquanicd.blogspot.com/
//Date    : 2019.Aug.26
// Project:	Serial CRC calculation with inital value
// Function:
// -- Load the initial value which is MSBs of input data
//    before calculating
// -- Number of calculation cycles = Number of LSBs + CRC width
//===================================================================================
module crcInitialValue (
   clk,
   rstN,
   ctrlEn,
   dataIn,
   GenPoly,
   crcSeq,
   crcReady
   );
  parameter CRC_WIDTH  = 8;
  parameter DWIDTH     = 16;
  parameter DWIDTH_LSB = DWIDTH-CRC_WIDTH;
  parameter COUNTERW   = clog2(DWIDTH);
  //
  //Inputs
  //
  input clk;
  input rstN;
  input ctrlEn;
  input [DWIDTH-1:0] dataIn;
  input [CRC_WIDTH-1:0] GenPoly;
  //
  //Outputs
  //
  output reg [CRC_WIDTH-1:0] crcSeq;
  output wire crcReady;
  //
  //Internal signals
  //
  reg [DWIDTH_LSB-1:0] dataInReg;
  reg [CRC_WIDTH-1:0] GenPolyReg;
  reg calStatus;
  wire clrmCounter;
  reg [COUNTERW-1:0] mCounter;
  //--------------------------------------
  //Set the calculation status
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      calStatus <= 1'b0;
    else if (clrmCounter)
      calStatus <= 1'b0;
    else if (ctrlEn)
      calStatus <= 1'b1;
  end
  //--------------------------------------
  //Store data and Generator polynomial
  //--------------------------------------
  always @ (posedge clk) begin
    if (ctrlEn)
      GenPolyReg[CRC_WIDTH-1:0] <= GenPoly[CRC_WIDTH-1:0];
  end
  always @ (posedge clk) begin
    if (ctrlEn)
      dataInReg[DWIDTH_LSB-1:0]   <= dataIn[DWIDTH_LSB-1:0];
    else if (calStatus)
      dataInReg[DWIDTH_LSB-1:0]   <= dataInReg[DWIDTH_LSB-1:0] << 1;
  end
  //--------------------------------------
  //Monitor counter
  //--------------------------------------
  assign clrmCounter = (mCounter[COUNTERW-1:0] == DWIDTH-1);
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      mCounter[COUNTERW-1:0] <= {COUNTERW{1'b0}};
    else if (clrmCounter)
      mCounter[COUNTERW-1:0] <= {COUNTERW{1'b0}};
    else if (calStatus)
      mCounter[COUNTERW-1:0] <= mCounter[COUNTERW-1:0] + 1'b1;
  end
  //--------------------------------------
  //Ready signal
  //--------------------------------------
  assign crcReady = ~calStatus;
  //--------------------------------------
  //CRC register which contains CRC value
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      crcSeq[CRC_WIDTH-1:0] <= {CRC_WIDTH{1'b0}};
    else if (ctrlEn)
      //Load MSB of dataIn
      crcSeq[CRC_WIDTH-1:0] <= dataIn[DWIDTH-1:DWIDTH-CRC_WIDTH];
    else if (calStatus) begin
      if (crcSeq[CRC_WIDTH-1])
        crcSeq[CRC_WIDTH-1:0] <= {crcSeq[CRC_WIDTH-2:0], dataInReg[DWIDTH_LSB-1]}^GenPolyReg[CRC_WIDTH-1:0];
      else 
        crcSeq[CRC_WIDTH-1:0] <= {crcSeq[CRC_WIDTH-2:0], dataInReg[DWIDTH_LSB-1]};
    end
  end
  //-----------------------------------------------------------
  //log2 function - Not for synthesizing
  //Only use to calculate the parameter value
  //-----------------------------------------------------------
  function integer clog2; 
    input integer value; 
	  integer i;
    begin 
      clog2 = 0;
      for(i = 0; 2**i < value; i = i + 1) 
        clog2 = i + 1; 
      end
  endfunction

endmodule
