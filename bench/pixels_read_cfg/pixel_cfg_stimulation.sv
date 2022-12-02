/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : pixel_cfg_stimulation.sv
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 02 Dec 2022 01:22:20 PM CST
 ************************************************************************/
 
module pixel_cfg_stimul(
    input  wire             sys_clock    ,
    input  wire             sys_resetn   ,
    output reg [7:0]        spi_cfg_addr ,
    output reg [14:0]       spi_cfg_data ,
    output reg              spi_cfg_valid,
    input  wire [179:0]     pixel_sel    ,
    input  wire [14:0]      pixel_wdata  ,
    input  wire             pixel_wren   
);

    always@(posedge sys_clock, negedge sys_resetn) begin
        if(!sys_resetn) begin
            spi_cfg_addr <= 8'h0;
            spi_cfg_data <= 0;
            spi_cfg_valid <= 0;
        end else begin
            if(spi_cfg_addr==179)
                spi_cfg_addr <= 179;
            else if(pixel_sel[spi_cfg_addr])
                spi_cfg_addr <= spi_cfg_addr + 1;
            
            if(&spi_cfg_data) 
                spi_cfg_data <= 15'h7fff;
            if(spi_cfg_data == pixel_wdata)
                spi_cfg_data <= spi_cfg_data + 1;
            
            if(pixel_wren==spi_cfg_valid)
                spi_cfg_valid <= ~ spi_cfg_valid;
        end
    end

    wire addr_chk_done = (spi_cfg_addr ==179);
    wire data_chk_done = (spi_cfg_data==15'h7fff);

endmodule