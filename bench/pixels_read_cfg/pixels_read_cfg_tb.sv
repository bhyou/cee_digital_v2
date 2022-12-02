/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : pixels_read_cfg_tb.sv
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 02 Dec 2022 10:26:58 AM CST
 ************************************************************************/
 
module pixels_read_cfg_tb;

    reg             sys_clock    ;
    reg             sys_resetn   ;
    // Priority readout
    wire              up_valid_o  ;
    wire [14:0]       up_addr_o   ;
    wire              down_valid_o;
    wire [14:0]       down_addr_o ;

    reg  [180*8-1:0]  timeCnt;
    reg  [179:0]      STATE  ;
    wire [179:0]      ADDREN ;
    wire [179:0]      SYNC   ;
    // from spi slave
    reg  [7:0]       spi_cfg_addr ;
    reg  [14:0]      spi_cfg_data ;
    reg              spi_cfg_valid;
    // to pixels matrix
    wire [179:0]     pixel_sel  ;
    wire [14:0]      pixel_wdata;
    wire             pixel_wren ; 


    initial begin
        sys_clock = 1'b1;
        forever # 25000 sys_clock = ~ sys_clock;       
    end


    initial begin
        sys_resetn = 1'b0;
        repeat(20) @(posedge sys_clock);
        sys_resetn = 1'b1;
    end

    pixel_read_cfg inst_pixels_read(
        .sys_clock    (sys_clock    ),
        .sys_resetn   (sys_resetn   ),
        .up_valid_o   (up_valid_o   ),
        .up_addr_o    (up_addr_o    ),
        .down_valid_o (down_valid_o ),
        .down_addr_o  (down_addr_o  ),
        .timeCnt      (timeCnt      ),
        .STATE        (STATE        ),
        .ADDREN       (ADDREN       ),
        .SYNC         (SYNC         ),
        .spi_cfg_addr (spi_cfg_addr ),
        .spi_cfg_data (spi_cfg_data ),
        .spi_cfg_valid(spi_cfg_valid),
        .pixel_sel    (pixel_sel    ),
        .pixel_wdata  (pixel_wdata  ),
        .pixel_wren   (pixel_wren   )  
    );


    pixel_read_stimul  inst_read_stimulation(
        .sys_clock    (sys_clock    ),
        .sys_resetn   (sys_resetn   ),
        .up_valid_i   (up_valid_o   ),
        .up_addr_i    (up_addr_o    ),
        .down_valid_i (down_valid_o ),
        .down_addr_i  (down_addr_o  ),
        .timeCnt      (timeCnt      ),
        .STATE        (STATE        ),
        .ADDREN       (ADDREN       ),
        .SYNC         (SYNC         )
    );


    pixel_cfg_stimul  inst_cfg_stimulation(
        .sys_clock    (sys_clock    ),
        .sys_resetn   (sys_resetn   ),
        .spi_cfg_addr (spi_cfg_addr ),
        .spi_cfg_data (spi_cfg_data ),
        .spi_cfg_valid(spi_cfg_valid),
        .pixel_sel    (pixel_sel    ),
        .pixel_wdata  (pixel_wdata  ),
        .pixel_wren   (pixel_wren   )  
    );


endmodule