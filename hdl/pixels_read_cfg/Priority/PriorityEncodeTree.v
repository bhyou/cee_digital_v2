/*************************************************************************
 > Copyright (C) 2021 Sangfor Ltd. All rights reserved.
 > File Name   : PriorityEncodeTree.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Thu 08 Apr 2021 05:24:01 PM CST
 ************************************************************************/
module PriorityEncodeTree #(parameter PIXS=90)(
   input  wire               ReadCLK,
   output wire               valid  ,
   output wire [14:0]        addrOut,

   input  wire [PIXS*8-1:0]  timeCnt,
   input  wire [PIXS-1:0]    STATE  ,
   output wire [PIXS-1:0]    ADDREN ,
   output wire [PIXS-1:0]    SYNC    
);

   localparam  Cell2Num = PIXS/2;

//  level 1 : 1                     |
//  level 2 : 4        |        |        |        |
//  level 3 : 16    | | | |  | | | |  | | | |  | | | |
//  level 4 : 64
//  level 5 : 128

   // level 2

   wire           L1_VALID_o  ;
   wire           L1_ADDREN_i ;
   wire           L1_SYNCLK_i ;
   wire [14:0]    L1_addres_o ;

   assign L1_ADDREN_i = 1'b1   ;
   assign L1_SYNCLK_i = ReadCLK;

   assign valid   = L1_VALID_o  ;
   assign addrOut = L1_addres_o ;

   wire [2:0]    L2_VALID_o ;
   wire [3:0]    L2_ADDREN_i ;
   wire [3:0]    L2_SYNCLK_i ;

   wire [12:0]    L2_addres_o [2:0];

   // Level 1
   PriorityCell4 #(.WID(15)) InstCellL4(
      .STATE  ( {1'b0,L2_VALID_o} ), 
      .ADDREO ( L2_ADDREN_i),
      .SYNC   ( L2_SYNCLK_i), 

      .VALID  ( L1_VALID_o ), 
      .ADDREI ( L1_ADDREN_i ),
      .CLKIN  ( L1_SYNCLK_i ),
      .ADDR   ( L1_addres_o ), 

      .ADDRI0 ( L2_addres_o[0]),
      .ADDRI1 ( L2_addres_o[1]),
      .ADDRI2 ( L2_addres_o[2]),
      .ADDRI3 ( 13'h0  )

   );

   wire [11:0]    L3_VALID_o ;
   wire [11:0]    L3_ADDREN_i ;
   wire [11:0]    L3_SYNCLK_i ;

   wire [10:0]     L3_addres_o [11:0];
   generate
      genvar i;
      for(i=0; i<3; i=i+1) begin: L2
      PriorityCell4 #(.WID(13)) InstCellL4(
         .STATE  ( L3_VALID_o[i*4+3:i*4]), 
         .ADDREO ( L3_ADDREN_i[i*4+3:i*4]),
         .SYNC   ( L3_SYNCLK_i[i*4+3:i*4]), 

         .VALID  ( L2_VALID_o[i] ), 
         .ADDREI ( L2_ADDREN_i[i] ),
         .CLKIN  ( L2_SYNCLK_i[i] ),
         .ADDR   ( L2_addres_o[i] ), 

         .ADDRI0 ( L3_addres_o[i*4+0]),
         .ADDRI1 ( L3_addres_o[i*4+1]),
         .ADDRI2 ( L3_addres_o[i*4+2]),
         .ADDRI3 ( L3_addres_o[i*4+3])
      );
      end
   endgenerate

   wire [44:0]    L4_VALID_o  ;
   wire [47:0]    L4_ADDREN_i ;
   wire [47:0]    L4_SYNCLK_i ;

   wire [8:0]     L4_addres_o [44:0] ;

   generate
      for(i=0; i<12; i=i+1) begin: L3
      if(i==11) begin 
      PriorityCell4 #(.WID(11)) InstCellL3_4(
         .STATE  ( {3'h0,L4_VALID_o[44]} ), 
         .ADDREO ( L4_ADDREN_i[47:44] ),
         .SYNC   ( L4_SYNCLK_i[47:44] ), 

         .VALID  ( L3_VALID_o[i] ), 
         .ADDREI ( L3_ADDREN_i[i] ),
         .CLKIN  ( L3_SYNCLK_i[i] ),
         .ADDR   ( L3_addres_o[i] ),
 
         .ADDRI0 ( L4_addres_o[44]),
         .ADDRI1 ( 9'h0 ),
         .ADDRI2 ( 9'h0 ),
         .ADDRI3 ( 9'h0 )
      );
      end
      else begin 
      PriorityCell4 #(.WID(11)) InstCellL3(
         .STATE  ( L4_VALID_o[i*4+3:i*4]), 
         .ADDREO ( L4_ADDREN_i[i*4+3:i*4]),
         .SYNC   ( L4_SYNCLK_i[i*4+3:i*4]), 

         .VALID  ( L3_VALID_o[i] ), 
         .ADDREI ( L3_ADDREN_i[i] ),
         .CLKIN  ( L3_SYNCLK_i[i] ),
         .ADDR   ( L3_addres_o[i] ),
 
         .ADDRI0 ( L4_addres_o[i*4+0]),
         .ADDRI1 ( L4_addres_o[i*4+1]),
         .ADDRI2 ( L4_addres_o[i*4+2]),
         .ADDRI3 ( L4_addres_o[i*4+3])
      );
      end
      end
   endgenerate


 //  assign L4_VALID_o = STATE;
 //
 //  assign ADDREN = L4_ADDREN_i;
 //  assign SYNC   = L4_SYNCLK_i; 

   wire [89:0]    L5_STATE ;
   wire [89:0]    L5_ADDRE ;
   wire [89:0]    L5_SYNCH ;

   wire  [7:0]     L5_address_o [PIXS-1:0];
   
   generate
      for(i=0; i<45; i=i+1) begin: L4
      PriorityCell2 #(.WID(9)) InstCellL4(
         .STATE  ( L5_STATE[i*2+1:i*2]), 
         .ADDREO ( L5_ADDRE[i*2+1:i*2]),
         .SYNC   ( L5_SYNCH[i*2+1:i*2]),

         .ADDRI0 ( L5_address_o[i*2+0] ),
         .ADDRI1 ( L5_address_o[i*2+1] ),
 
         .VALID  ( L4_VALID_o[i]  ), 
         .ADDREI ( L4_ADDREN_i[i] ),
         .CLKIN  ( L4_SYNCLK_i[i] ),
         .ADDR   ( L4_addres_o[i] ) 
      );
      end
   endgenerate

   assign L5_STATE[PIXS-1:0] = STATE;

   assign ADDREN = L5_ADDRE[PIXS-1:0];
   assign SYNC   = L5_SYNCH[PIXS-1:0]; 

   generate 
      for(i=0; i<90; i=i+1) begin 
         assign L5_address_o[i] = timeCnt[i*8+7:i*8];
      end 
   endgenerate
/*
*/
endmodule
 
