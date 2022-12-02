/*************************************************************************
 > Copyright (C) 2021 Sangfor Ltd. All rights reserved.
 > File Name   : PriorityL2.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 09 Apr 2021 06:15:53 PM CST
 ************************************************************************/

`ifdef Cell4
module PriorityCellTest(
   input  wire            ReadCLK,
   output wire            valid  ,
   output wire [4:0]      addrOut,

   input  wire [15:0]    STATE  ,
   output wire [15:0]    ADDREN ,
   output wire [15:0]    SYNC    
);

   wire           L1_VALID_o  ;
   wire           L1_ADDREN_i ;
   wire           L1_SYNCLK_i ;
   wire [4:0]     L1_addres_o ;

   assign L1_ADDREN_i = 1'b1;
   assign L1_SYNCLK_i = ReadCLK;

   assign valid   = L1_VALID_o  ;
   assign addrOut = L1_addres_o ;

   wire [3:0]    L2_VALID_o  ;
   wire [3:0]    L2_ADDREN_i ;
   wire [3:0]    L2_SYNCLK_i ;

   wire [2:0]    L2_addres_o [3:0];

   // Level 1
   PriorityCell4 #(.WID(5)) InstCellL4(
      .STATE  ( L2_VALID_o ), 
      .ADDREO ( L2_ADDREN_i),
      .SYNC   ( L2_SYNCLK_i), 

      .VALID  ( L1_VALID_o ), 
      .ADDREI ( L1_ADDREN_i ),
      .CLKIN  ( L1_SYNCLK_i ),
      .ADDR   ( L1_addres_o ), 

      .ADDRI0 ( L2_addres_o[0]),
      .ADDRI1 ( L2_addres_o[1]),
      .ADDRI2 ( L2_addres_o[2]),
      .ADDRI3 ( L2_addres_o[3])
   );

   wire [15:0]    L3_VALID_o ;
   wire [15:0]    L3_ADDREN_i ;
   wire [15:0]    L3_SYNCLK_i ;


   generate
      genvar i;
      for(i=0; i<4; i=i+1) begin: L2
      PriorityCell4 #(.WID(3)) InstCellL4(
         .STATE  ( L3_VALID_o[i*4+3:i*4]), 
         .ADDREO ( L3_ADDREN_i[i*4+3:i*4]),
         .SYNC   ( L3_SYNCLK_i[i*4+3:i*4]), 

         .VALID  ( L2_VALID_o[i] ), 
         .ADDREI ( L2_ADDREN_i[i] ),
         .CLKIN  ( L2_SYNCLK_i[i] ),
         .ADDR   ( L2_addres_o[i] ), 

         .ADDRI0 ( 1'b1 ),
         .ADDRI1 ( 1'b1 ),
         .ADDRI2 ( 1'b1 ),
         .ADDRI3 ( 1'b1 )
      );
      end
   endgenerate

   assign L3_VALID_o = STATE;

   assign ADDREN     = L3_ADDREN_i;
   assign SYNC       = L3_SYNCLK_i;
endmodule

`else
module PriorityCellTest #(parameter WID=4)(
   input  wire            ReadCLK,
   output wire            valid  ,
   output wire [WID-1:0]  addrOut,

   input  wire [3:0]     STATE  ,
   output wire [3:0]     ADDREN ,
   output wire [3:0]     SYNC    
); 
   wire         L1_VALID_o ;
   wire         L1_ADDREN_i;
   wire         L1_SYNCLK_i;
   wire [3:0]   L1_addres_o;

   wire [1:0]   L2_VALID_o ;
   wire [1:0]   L2_ADDREN_i;
   wire [1:0]   L2_SYNCLK_i;
   wire [2:0]   L2_addres_o [1:0];

   assign valid = L1_VALID_o;
   assign addrOut = L1_addres_o;
   assign L1_SYNCLK_i = ReadCLK ;
   assign L1_ADDREN_i = 1'b1;

   PriorityCell2 #(.WID(4)) InstCellL1(
      .STATE  ( L2_VALID_o ), 
      .ADDREO ( L2_ADDREN_i),
      .SYNC   ( L2_SYNCLK_i), 
      .ADDRI0 ( L2_addres_o[0]),
      .ADDRI1 ( L2_addres_o[1]), 

      .VALID  ( L1_VALID_o  ), 
      .ADDREI ( L1_ADDREN_i ),
      .CLKIN  ( L1_SYNCLK_i ),
      .ADDR   ( L1_addres_o ) 
   );


   PriorityCell2 #(.WID(3)) InstCellL2_1(
      .STATE  ( STATE[1:0] ), 
      .ADDREO ( ADDREN[1:0]),
      .SYNC   ( SYNC[1:0]  ),
      .ADDRI0 ( 2'b00 ),
      .ADDRI1 ( 2'b01 ), 

      .VALID  ( L2_VALID_o[0]  ), 
      .ADDREI ( L2_ADDREN_i[0] ),
      .CLKIN  ( L2_SYNCLK_i[0] ),
      .ADDR   ( L2_addres_o[0] ) 
   );

   PriorityCell2 #(.WID(3)) InstCellL2_2(
      .STATE  ( STATE[3:2] ), 
      .ADDREO ( ADDREN[3:2]),
      .SYNC   ( SYNC[3:2]  ),
      .ADDRI0 ( 2'b00 ),
      .ADDRI1 ( 2'b01 ), 

      .VALID  ( L2_VALID_o[1]  ), 
      .ADDREI ( L2_ADDREN_i[1] ),
      .CLKIN  ( L2_SYNCLK_i[1] ),
      .ADDR   ( L2_addres_o[1] ) 
   );

endmodule

`endif
