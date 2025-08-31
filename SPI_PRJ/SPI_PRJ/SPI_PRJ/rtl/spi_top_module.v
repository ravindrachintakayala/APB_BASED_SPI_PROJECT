
module spi_top_module(
       input PCLK, PRESET_n, PWRITE_i, PSEL_i, PENABLE_i, miso_i,
       input [2:0]PADDR_i,
       input [7:0]PWDATA_i,

       output ss_o, sclk_o, PREADY_o, PSLVERR_o, mosi_o, spi_interrupt_request_o,
       output [7:0]PRDATA_o);

wire spiswai,cpol,cpha,miso_receive_sclk,miso_receive_sclk0,mosi_send_sclk,mosi_send_sclk0,mstr,send_data;
wire [2:0]sppr,spr;
wire tip,receive_data,lsbfe;
wire [7:0]miso_data,mosi_data;
wire [1:0]spi_mode;
wire [11:0]BaudRateDivisor;



spi_apb_slave_interface M1( .PCLK(PCLK), .PRESET_n(PRESET_n), .PADDR_i(PADDR_i), .PSEL_i(PSEL_i), .ss_i(ss_o), .cpol_o(cpol),
               .PWRITE_i(PWRITE_i), .PENABLE_i(PENABLE_i), .PWDATA_i(PWDATA_i), .miso_data_i(miso_data),
               .receive_data_i(receive_data), .tip_i(tip), .PRDATA_o(PRDATA_o), .mstr_o(mstr), .spiswai_o(spiswai),
               .cpha_o(cpha), .lsbfe_o(lsbfe), .sppr_o(sppr), .spr_o(spr), .PREADY_o(PREADY_o), .PSLVERR_o(PSLVERR_o),
               .send_data_o(send_data), .mosi_data_o(mosi_data), .spi_interrupt_request_o(spi_interrupt_request_o),
               .spi_mode_o(spi_mode));

spi_baud_generator M2 ( .PCLK(PCLK), .PRESET_n(PRESET_n), .spiswai_i(spiswai), .cpol_i(cpol), .cpha_i(cpha), .ss_i(ss_o), .sppr_i(sppr),
               .spr_i(spr),.spi_mode_i(spi_mode), .BaudRateDivisor_o(BaudRateDivisor),
               .miso_receive_sclk_o(miso_receive_sclk), .miso_receive_sclk0_o(miso_receive_sclk0),
               .mosi_send_sclk_o(mosi_send_sclk),  .mosi_send_sclk0_o(mosi_send_sclk0), .sclk_o(sclk_o));
					

spi_slave_select M3 ( .PCLK(PCLK), .PRESET_n(PRESET_n), .mstr_i(mstr), .spiswai_i(spiswai),
               .spi_mode_i(spi_mode), .send_data_i(send_data), .BaudRateDivisor_i(BaudRateDivisor),
               .receive_data_o(receive_data), .ss_o(ss_o), .tip_o(tip));

  
spi_shifter M4 ( .PCLK(PCLK), .PRESET_n(PRESET_n), .ss_i(ss_o), .send_data_i(send_data), .lsbfe_i(lsbfe),
               .cpha_i(cpha), .cpol_i(cpol), .miso_receive_sclk_i(miso_receive_sclk), .data_mosi_i(mosi_data),
               .miso_receive_sclk0_i(miso_receive_sclk0), .mosi_send_sclk_i(mosi_send_sclk), .miso_i(miso_i),
               .receive_data_i(receive_data), .mosi_send_sclk0_i(mosi_send_sclk0), .mosi_o(mosi_o),
               .data_miso_o(miso_data));

endmodule      
