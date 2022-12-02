`timescale 1ns/1ps
module PriorityCell4 #(parameter WID=4)(
   input   wire   [3:0]     STATE , 
   output  wire   [3:0]     ADDREO,
   output  wire   [3:0]     SYNC  ,  
   
   input   wire             ADDREI,   //address enable input
   input   wire   [WID-3:0] ADDRI0,   // address input previous cell
   input   wire   [WID-3:0] ADDRI1, 
   input   wire   [WID-3:0] ADDRI2, 
   input   wire   [WID-3:0] ADDRI3,
    
   input   wire             CLKIN ,
   output  wire             VALID , 
   output  wire   [WID-1:0] ADDR   
);

   // fast OR
   assign VALID = | STATE;
   
   assign SYNC[0] = (CLKIN & STATE[0]);
   assign SYNC[1] = (CLKIN & (~STATE[0]) & STATE[1]);
   assign SYNC[2] = (CLKIN & (~STATE[0]) & (~STATE[1]) & STATE[2]);
   assign SYNC[3] = (CLKIN & (~STATE[0]) & (~STATE[1]) & (~STATE[2]) & STATE[3]);
   
   assign ADDREO[0] = ADDREI & STATE[0];
   assign ADDREO[1] = ADDREI & (~STATE[0]) & STATE[1];
   assign ADDREO[2] = ADDREI & (~STATE[0]) & (~STATE[1]) & STATE[2];
   assign ADDREO[3] = ADDREI & (~STATE[0]) & (~STATE[1]) & (~STATE[2]) & STATE[3];
   
   assign ADDR[WID-2]   = (ADDREO[1] | ADDREO[3]) ? 1'b1 : 1'b0;
   assign ADDR[WID-1]   = (ADDREO[2] | ADDREO[3]) ? 1'b1 : 1'b0;
   assign ADDR[WID-3:0] =  ADDREO[0] ? ADDRI0 : (ADDREO[1] ?  ADDRI1 :
                          (ADDREO[2] ? ADDRI2 : (ADDREO[3] ?  ADDRI3 : 0)));

endmodule

module PriorityCell2 #(parameter WID=4)(
   input   wire  [1:0]      STATE , 
   output  wire  [1:0]      ADDREO,
   output  wire  [1:0]      SYNC  ,  
   input   wire  [WID-2:0]  ADDRI0,
   input   wire  [WID-2:0]  ADDRI1,
   
   input   wire             ADDREI,   //address enable input
   input   wire             CLKIN ,
   output  wire             VALID , 
   output  wire  [WID-1:0]  ADDR   
);

   // fast OR
   assign VALID = | STATE;
   
   assign SYNC[0] = (CLKIN & STATE[0]);
   assign SYNC[1] = (CLKIN & (~STATE[0]) & STATE[1]);
   
   assign ADDREO[0] = ADDREI & STATE[0];
   assign ADDREO[1] = ADDREI & (~STATE[0]) & STATE[1];
   
   assign ADDR[WID-1] = (ADDREI & ADDREO[1]) ? 1'b1 : 1'b0;
   assign ADDR[WID-2:0] = (ADDREI & ADDREO[1]) ? ADDRI1 : ADDRI0;

endmodule
