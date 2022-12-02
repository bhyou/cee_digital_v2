/*************************************************************************
 > Copyright (C) 2021 Sangfor Ltd. All rights reserved.
 > File Name   : bitdec.v
 > Author      : 
 > Mail        :  
 > Created Time: 
 ************************************************************************/
module pixel_cfg_decode(
   input  wire             clock  ,
   input  wire             resetn ,
   input  wire [7:0]       cfg_addr ,
   input  wire [14:0]      cfg_data ,
   input  wire             cfg_valid,

   output reg  [179:0]     pixel_sel ,
   output reg  [14:0]      pixel_wdata,
   output reg              pixel_wren 
);


   always@(posedge clock, negedge resetn) begin 
      if(~resetn) begin
         pixel_sel <= 180'h0;
         pixel_wdata <= 15'h0;
         pixel_wren  <= 1'b0;
      end else begin
         pixel_wdata <= cfg_data;
         pixel_wren  <= cfg_valid;
         pixel_sel   <= (cfg_valid) ? (1 << cfg_addr ) : 180'h0;
      end
   end

endmodule



 
