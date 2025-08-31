module spi_shifter_tb();



reg PCLK,PRESET_n;
	reg ss_i,send_data_i;
	reg lsbfe_i,cpha_i,cpol_i;
	reg miso_receive_sclk_i,miso_receive_sclk0_i;
	reg mosi_send_sclk_i,mosi_send_sclk0_i;
	reg [7:0]data_mosi_i;
	reg miso_i;
	reg  receive_data_i;

	wire mosi_o;
	wire [7:0]data_miso_o;




spi_shifter DUT( .PCLK(PCLK), .PRESET_n(PRESET_n), .ss_i(ss_i), .send_data_i(send_data_i), .lsbfe_i(lsbfe_i),
               .cpha_i(cpha_i), .cpol_i(cpol_i), .miso_receive_sclk_i(miso_receive_sclk_i), .data_mosi_i(data_mosi_i),
               .miso_receive_sclk0_i(miso_receive_sclk0), .mosi_send_sclk_i(mosi_send_sclk), .miso_i(miso_i),
               .receive_data_i(receive_data_i), .mosi_send_sclk0_i(mosi_send_sclk0_i), .mosi_o(mosi_o),
               .data_miso_o(data_mosi_o));
				
initial 
begin
       PCLK = 1'b0;
       forever #10 PCLK = ~PCLK;
end
		 
		 
task reset();
begin
        @(negedge PCLK);
        PRESET_n = 1'b0;
        @(negedge PCLK);
        PRESET_n = 1'b1;
end
endtask 
		 
task sending(input [7:0]send, input l,m,n,o,p);
begin 
    ss_i=1;
	 send_data_i=1;
	 lsbfe_i=l;
	 cpha_i=0;
	 cpol_i=1;
	 data_mosi_i=send;
	 mosi_send_sclk_i=m;
	 mosi_send_sclk0_i=n;
	 miso_receive_sclk_i=o;
	 miso_receive_sclk0_i=p;
end
endtask

		 
task receiving(input l,o,p,m,n);
begin 
    ss_i=1;
	 receive_data_i=1;
	 lsbfe_i=l;
	 cpha_i=0;
	 cpol_i=1;
	 miso_receive_sclk_i=o;
	 miso_receive_sclk0_i=p;
	 mosi_send_sclk_i=m;
	 mosi_send_sclk0_i=n;
end
endtask


initial
begin

ss_i=0;
lsbfe_i=0;
cpol_i=0;
cpha_i=0;
send_data_i=0;
receive_data_i=0;
miso_receive_sclk_i=0;
	 miso_receive_sclk0_i=0;
	 mosi_send_sclk_i=0;
	 mosi_send_sclk0_i=0;
#100;

reset;

sending(8'b00101011,1'b1,1'b0,1'b1,1'b0,1'b0);
#100;
receiving(1'b1,1'b0,1'b1,1'b0,1'b0);
end

endmodule
    		 
