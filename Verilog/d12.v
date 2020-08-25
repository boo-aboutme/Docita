// delay half clock for 12-bit bus

module D12 #(parameter _DELAY = 50)
   (
    input wire 	      iCLK,
    input wire [11:0] iBUS,
    output reg [11:0] oBUS
    );
   always @(posedge iCLK or negedge iCLK) 
     #_DELAY oBUS <= iBUS;
endmodule // D12
