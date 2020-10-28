// -*- Verilog -*-
// top.inc - top 

   wire _clk, _reset_n;
   wire [11:0] _addr;
   wire [11:0] _st_data;	// TODO: unite with _ld_data
   wire [11:0] _ld_data;	// TODO: 
   wire        _cs_n, _memwren_n;
   
   CLK_GEN clk(.oCLK(_clk), .oRESETn(_reset_n));
   
   DOCITA proc(
	       .iCLK(_clk),
	       .iRESETn(_reset_n),
	       .iDATA(_ld_data),
	       .oDATA(_st_data),
	       .oADDR(_addr),
	       .oCSELn(_cs_n),
	       .oWR_ENn(_memwren_n)
	       );

   MEM mem(
	   .iADDR(_addr),
	   .iDATA(_st_data),
	   .iCSELn(_cs_n),
	   .iWR_ENn(_memwren_n),
	   .oDATA(_ld_data)
	   );
