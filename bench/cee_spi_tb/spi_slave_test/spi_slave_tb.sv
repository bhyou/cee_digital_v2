/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : spi_slave_tb.sv
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Thu 01 Dec 2022 04:02:44 PM CST
 ************************************************************************/
 
module spi_slave_tb;

    parameter cWriteCmd = 8'h1;
    parameter cReadCmd  = 8'h2;

    reg         spi_refclk_i;
    reg         spi_reset_i;
    
    wire [7:0]  ibp_cmd   ;
    wire [7:0]  ibp_addr  ;
    wire        ibp_sel   ;
    wire [15:0] ibp_wdata ;
    wire        ibp_enable;
    reg [15:0]  ibp_rdata ;

    reg         spi_clk_o ;
    reg         spi_csb_o ;
    reg         spi_sdo_o ;
    wire        spi_sdi_i ;


    initial begin
        spi_refclk_i = 0;
        forever begin
          #10000 spi_refclk_i = ~ spi_refclk_i;  
        end
    end

    initial begin
        spi_csb_o = 1;
        spi_sdo_o = 0;
        repeat(4) @(posedge spi_refclk_i);

        spi_write_word(cWriteCmd, 8'h13,16'h3456);
    end

    task spi_write_word(input bit[7:0] cmd, addr, input bit [15:0] data);
        @(posedge spi_refclk_i);
        spi_csb_o <= #3 1'b0;
        spi_write_byte(cmd);
        spi_write_byte(addr);
        spi_write_byte(data[15:8]);
        spi_write_byte(data[7:0]);
        @(posedge spi_refclk_i);
        @(posedge spi_refclk_i);
        @(posedge spi_refclk_i);
        @(posedge spi_refclk_i);
        @(posedge spi_refclk_i);
        @(posedge spi_refclk_i);
        spi_csb_o <= #3 1'b1;
    endtask

    task spi_write_byte(input bit [7:0] wbyte);
        for(int item = 8; item > 0; item --) begin
            @(negedge spi_refclk_i);
            spi_sdo_o <= wbyte[item-1];
        end
    endtask



    spi_slave_inf #(
        .cWriteCmd(cWriteCmd),
        .cReadCmd (cReadCmd )
    ) spi_slave(
        .csb_       (spi_csb_o),
        //.sclk       (spi_clk_o),
        .sclk       (spi_refclk_i),
        .mosi       (spi_sdo_o),
        .miso       (spi_sdi_i),
        .ibp_cmd    (ibp_cmd   ),
        .ibp_addr   (ibp_addr  ),
        .ibp_sel    (ibp_sel   ),  
        .ibp_wdata  (ibp_wdata ),
        .ibp_enable (ibp_enable), 
        .ibp_rdata  (ibp_rdata )
    );



endmodule