//===================================================================================
// Project:	Parallel CRC calculation with an 8-bit block
// Function:
// -- Get 8 bits (1 byte) for each step
// -- Number of calculation cycles: Number of bytes of data input
//===================================================================================
module crcParallelCrcW (
   clk,
   rstN,
   ctrlEn,
   dataIn,
   GenPoly,
   crcSeq,
   crcReady
   );
  //bit width of CRC sequence
  parameter CRC_WIDTH = 8;
  //bit width of data input
  parameter DWIDTH    = 32;
  //bit width of input of CRC calculator
  parameter CALWIDTH  = CRC_WIDTH;
  //Number of calculation times. Exmaple: 32/8 = 4
  parameter CALNUM  = DWIDTH/CALWIDTH;
  //bit width of shift counter
  parameter COUNTERW  = clog2(CALNUM);
  //bit width of imtermediate signal
  //of CRC calculator
  parameter TMP_WIDTH = CALWIDTH*CRC_WIDTH;
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
  wire [CALWIDTH+CRC_WIDTH-1:0] dataInCal;
  reg [COUNTERW-1:0] shiftCounter;
  wire setReady;
  wire [CALWIDTH-1:0] xorInput;
  //--------------------------------------
  //Store data and Generator polynomial
  //--------------------------------------
  always @ (posedge clk) begin
    if (ctrlEn)
      GenPolyReg[CRC_WIDTH-1:0] <= GenPoly[CRC_WIDTH-1:0];
  end
  always @ (posedge clk) begin
    if (ctrlEn)
      dataInReg[DWIDTH-1:0] <= dataIn[DWIDTH-1:0];
    else if (~crcReady)
      dataInReg[DWIDTH-1:0] <= dataInReg[DWIDTH-1:0] << CRC_WIDTH;
  end
  //--------------------------------------
  //Input for CRC calculator
  //--------------------------------------
  assign xorInput[CALWIDTH-1:0] = dataInReg[DWIDTH-1:DWIDTH-CALWIDTH] ^ crcSeq[CRC_WIDTH-1:0];
  assign dataInCal[CALWIDTH+CRC_WIDTH-1:0] =
         {xorInput[CALWIDTH-1:0], {CRC_WIDTH{1'b0}}};
  //--------------------------------------
  //Shift counter
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      shiftCounter[COUNTERW-1:0] <= {COUNTERW{1'b0}};
    else if (crcReady)
      shiftCounter[COUNTERW-1:0] <= {COUNTERW{1'b0}};
    else
      shiftCounter[COUNTERW-1:0] <= shiftCounter[COUNTERW-1:0] + 1'b1;
  end
  //--------------------------------------
  //Ready signal
  //--------------------------------------
  assign setReady = (shiftCounter[COUNTERW-1:0] == (CALNUM-1));
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      crcReady <= 1'b1;
    else if (ctrlEn)
      crcReady <= 1'b0;
    else if (setReady)
      crcReady <= 1'b1;
  end
  //--------------------------------------
  //Combinaltional logic calculates CRC
  //--------------------------------------
  generate
    genvar i;
    assign subCrc[TMP_WIDTH-1:(TMP_WIDTH-1)-(CRC_WIDTH-1)]
           = dataInCal[CALWIDTH+CRC_WIDTH-1]?
             dataInCal[CALWIDTH+CRC_WIDTH-2:(CALWIDTH+CRC_WIDTH-1)-(CRC_WIDTH-1)-1] ^ GenPolyReg[CRC_WIDTH-1:0]
           : dataInCal[CALWIDTH+CRC_WIDTH-2:(CALWIDTH+CRC_WIDTH-1)-(CRC_WIDTH-1)-1];
    for (i=1; i < CALWIDTH; i=i+1) begin: CrcCal
      assign subCrc[TMP_WIDTH-1-(i*CRC_WIDTH):(TMP_WIDTH-1)-(i*CRC_WIDTH)-(CRC_WIDTH-1)]
              = subCrc[TMP_WIDTH-1-(i-1)*CRC_WIDTH]? 
                  {subCrc[(TMP_WIDTH-1)-((i-1)*CRC_WIDTH)-1:(TMP_WIDTH-1)-(i*CRC_WIDTH-1)],
                  dataInCal[(CALWIDTH+CRC_WIDTH-1)-CRC_WIDTH-i]} ^ GenPolyReg[CRC_WIDTH-1:0]
                : {subCrc[(TMP_WIDTH-1)-((i-1)*CRC_WIDTH)-1:(TMP_WIDTH-1)-(i*CRC_WIDTH-1)],
                dataInCal[(CALWIDTH+CRC_WIDTH-1)-CRC_WIDTH-i]};
    end
  endgenerate
  //--------------------------------------
  //CRC register
  //--------------------------------------
  always @ (posedge clk, negedge rstN) begin
    if (~rstN)
      crcSeq[CRC_WIDTH-1:0] <= {CRC_WIDTH{1'b0}};
    else if (ctrlEn)
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

endmodule //crcParallelCrcW
