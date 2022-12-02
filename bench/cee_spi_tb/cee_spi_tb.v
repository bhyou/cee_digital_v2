/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : spi_bench.sv
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Thu 01 Dec 2022 12:48:31 PM CST
 ************************************************************************/
 
module spi_bench;
    parameter cWriteCmd = 8'h0;
    parameter cReadCmd  = 8'h1;

    reg         spi_refclk_i;
    wire        spi_reset_i;
    reg         sys_clk_i;
    reg         sys_rstn_i;

    parameter cWidth = 16;
    reg [cWidth-1:0]  tx_data;
    reg               tx_valid;
    wire [cWidth-1:0] rx_data;
    wire              rx_valid;

    wire              spi_clk_o ;
    wire              spi_csb_o ;
    wire              spi_sdo_o ;
    wire              spi_sdi_i ;

    
    initial begin
        sys_clk_i = 1'b0;
        forever #20000 sys_clk_i = ~ sys_clk_i;
    end
    initial begin
        spi_refclk_i = 0;
        forever #50000 spi_refclk_i = ~ spi_refclk_i;  
    end

    initial begin
        sys_rstn_i  = 1'b0;
        repeat(4) @(posedge sys_clk_i);
        sys_rstn_i = 1'b1;
    end

    wire [14:0] cfg_data;
    wire        cfg_valid;
    wire [7:0] addr0_out;
    wire [7:0] addr1_out;
    wire [7:0] addr2_out;
    wire [7:0] addr3_out;
    wire [7:0] addr4_out;
    wire [7:0] addr5_out;

    assign addr4_out = cfg_data[7:0];
    assign addr5_out = {cfg_valid, cfg_data[14:8]};


    spi_serdes spi_master(
        .sys_clock_i  (spi_refclk_i),
        .sys_reset_i  (spi_reset_i),
        .start_trans_i(tx_valid),
        .send_data_i  (tx_data ),
        .recv_data_o  (rx_data),
        .done_trans_o (rx_valid),
        .spi_clk_o    (spi_clk_o),
        .spi_csb_o    (spi_csb_o),
        .spi_sdo_o    (spi_sdo_o),
        .spi_sdi_i    (spi_sdi_i) 
    );

    cee_spi_slave inst_slave(
        .sys_clk_i  (sys_clk_i),
        .sys_rstn_i (sys_rstn_i),
    //SPI Slave Interface
        .s_spi_csb_ (spi_csb_o),
        .s_spi_sclk (spi_clk_o),
        .s_spi_mosi (spi_sdo_o),
        .s_spi_miso (spi_sdi_i),
    // Regsiter Ouptut
        .addr0_out (addr0_out),
        .addr1_out (addr1_out),
        .addr2_out (addr2_out),
        .cfg_addr  (addr3_out),
        .cfg_valid (cfg_valid),
        .cfg_data  (cfg_data)


        //.addr3_out (addr3_out),
        //.addr4_out (addr4_out),
        //.addr5_out (addr5_out)
    );

    spi_stimulation inst_stimu(
        .sys_clk_i   (sys_clk_i   ),
        .sys_rstn_i  (sys_rstn_i  ),
        .spi_refclk_i(spi_refclk_i),
        .spi_reset_i (spi_reset_i ),
        .tx_data     (tx_data ),
        .tx_valid    (tx_valid),
        .rx_data     (rx_data ),
        .rx_valid    (rx_valid),
        .addr0_out   (addr0_out),
        .addr1_out   (addr1_out),
        .addr2_out   (addr2_out),
        .addr3_out   (addr3_out),
        .addr4_out   (addr4_out),
        .addr5_out   (addr5_out)

    );
    
endmodule