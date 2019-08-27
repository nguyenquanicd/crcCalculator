//-------------------------------------------
//Author  : Nguyen Hung Quan
//Website : https://nguyenquanicd.blogspot.com/
//Date    : 2019.Aug.27
// Project:	Parallel CRC calculation
// Function:
// -- Get all inputs and calculate parallel
// -- Number of calculation cycles: 1
//===================================================================================
module crcParallel (
   clk,
   rstN,
   ctrlEn,
   dataIn,
   GenPoly,
   crcSeq,
   crcReady
   );
  parameter CRC_WIDTH = 8;
  parameter DWIDTH    = 16;
  parameter TMP_WIDTH = DWIDTH*CRC_WIDTH;
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
  output reg crcReady;
  //
  //Internal signals
  //
  reg [DWIDTH-1:0] dataInReg;
  reg [CRC_WIDTH-1:0] GenPolyReg;
  wire [TMP_WIDTH-1:0]  subCrc;
  wire [DWIDTH+CRC_WIDTH-1:0] dataInCal;
  //--------------------------------------
  //Store data and Generator polynomial
  //--------------------------------------
  always @ (posedge clk) begin
    if (ctrlEn) begin
      GenPolyReg[CRC_WIDTH-1:0] <= GenPoly[CRC_WIDTH-1:0];
      dataInReg[DWIDTH-1:0]   <= dataIn[DWIDTH-1:0];
    end
  end
  assign dataInCal[DWIDTH+CRC_WIDTH-1:0] =
         {dataInReg[DWIDTH-1:0], {CRC_WIDTH{1'b0}}};
  //---------------------------------
  //Ready signal
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      crcReady <= 1'b1;
    else if (ctrlEn)
      crcReady <= 1'b0;
    else
      crcReady <= 1'b1;
  end
  //--------------------------------------
  //Combinaltional logic calculates CRC
  //--------------------------------------
  generate
    genvar i;
    assign subCrc[TMP_WIDTH-1:(TMP_WIDTH-1)-(CRC_WIDTH-1)]
           = dataInCal[DWIDTH+CRC_WIDTH-1]?
             dataInCal[DWIDTH+CRC_WIDTH-2:(DWIDTH+CRC_WIDTH-1)-(CRC_WIDTH-1)-1] ^ GenPolyReg[CRC_WIDTH-1:0]
           : dataInCal[DWIDTH+CRC_WIDTH-2:(DWIDTH+CRC_WIDTH-1)-(CRC_WIDTH-1)-1];
    for (i=1; i < DWIDTH; i=i+1) begin: CrcCal
      assign subCrc[TMP_WIDTH-1-(i*CRC_WIDTH):(TMP_WIDTH-1)-(i*CRC_WIDTH)-(CRC_WIDTH-1)]
              = subCrc[TMP_WIDTH-1-(i-1)*CRC_WIDTH]? 
                  {subCrc[(TMP_WIDTH-1)-((i-1)*CRC_WIDTH)-1:(TMP_WIDTH-1)-(i*CRC_WIDTH-1)],
                  dataInCal[(DWIDTH+CRC_WIDTH-1)-CRC_WIDTH-i]} ^ GenPolyReg[CRC_WIDTH-1:0]
                : {subCrc[(TMP_WIDTH-1)-((i-1)*CRC_WIDTH)-1:(TMP_WIDTH-1)-(i*CRC_WIDTH-1)],
                dataInCal[(DWIDTH+CRC_WIDTH-1)-CRC_WIDTH-i]};
    end
  endgenerate
  //--------------------------------------
  //CRC register
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      crcSeq[CRC_WIDTH-1:0] <= {CRC_WIDTH{1'b0}};
    else if (~crcReady)
      crcSeq[CRC_WIDTH-1:0] <= subCrc[CRC_WIDTH-1:0];
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
