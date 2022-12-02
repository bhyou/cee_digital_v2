/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : pixel_rd_cfg.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 02 Dec 2022 10:10:00 AM CST
 ************************************************************************/
 
module pixel_read_cfg(
    input  wire             sys_clock    ,
    input  wire             sys_resetn   ,
    // Priority readout
    output wire              up_valid_o  ,
    output wire [14:0]       up_addr_o   ,
    output wire              down_valid_o,
    output wire [14:0]       down_addr_o ,

    input  wire [180*8-1:0]  timeCnt,
    input  wire [179:0]      STATE  ,
    output wire [179:0]      ADDREN ,
    output wire [179:0]      SYNC   ,
    // from spi slave
    input  wire [7:0]       spi_cfg_addr ,
    input  wire [14:0]      spi_cfg_data ,
    input  wire             spi_cfg_valid,
    // to pixels matrix
    output reg  [179:0]     pixel_sel  ,
    output reg  [14:0]      pixel_wdata,
    output reg              pixel_wren 
);

    wire up_rdclk_i ;
    wire down_rdclk_i;

    assign up_rdclk_i = sys_clock & up_valid_o;
    assign down_rdclk_i = sys_clock & down_valid_o;

    PriorityEncodeTree  up_bank(
       .ReadCLK(up_rdclk_i),
       .valid  (up_valid_o  ),
       .addrOut(up_addr_o),
       .timeCnt(timeCnt[180*8-1:90*8]),
       .STATE  (STATE[179:90]  ),
       .ADDREN (ADDREN[179:90] ),
       .SYNC   (SYNC[179:90]   ) 
    );

    PriorityEncodeTree  down_bank(
       .ReadCLK(down_rdclk_i),
       .valid  (down_valid_o  ),
       .addrOut(down_addr_o),
       .timeCnt(timeCnt[90*8-1:0]),
       .STATE  (STATE[89:0]  ),
       .ADDREN (ADDREN[89:0] ),
       .SYNC   (SYNC[89:0]   ) 
    );

    pixel_cfg_decode inst_decoder(
        .clock      (sys_clock    ),
        .resetn     (sys_resetn   ),
        .cfg_addr   (spi_cfg_addr ),
        .cfg_data   (spi_cfg_data ),
        .cfg_valid  (spi_cfg_valid),
        .pixel_sel  (pixel_sel    ),
        .pixel_wdata(pixel_wdata  ),
        .pixel_wren (pixel_wren   )
    );
endmodule