module spi_baud_generator_tb();

reg PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i;
reg [1:0]spi_mode_i;
reg [2:0]sppr_i,spr_i;

wire sclk_o, miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o;
wire [11:0]BaudRateDivisor_o;

spi_baud_generator DUT(.PCLK(PCLK), .PRESET_n(PRESET_n), .spiswai_i(spiswai_i), 
.cpol_i(cpol_i), .cpha_i(cpha_i), .ss_i(ss_i), .spi_mode_i(spi_mode_i), .sppr_i(sppr_i),
 .spr_i(spr_i), .sclk_o(sclk_o), .miso_receive_sclk_o(miso_receive_sclk_o), 
.miso_receive_sclk0_o(miso_receive_sclk0_o),  .mosi_send_sclk_o(mosi_send_sclk_o),
.mosi_send_sclk0_o(mosi_send_sclk0_o), .BaudRateDivisor_o(BaudRateDivisor_o));

initial
   begin
	  PCLK=0;
	  forever #10 PCLK=~PCLK;
	end

task initialize;
  begin
      PRESET_n=1'b1;
		spiswai_i=1'b0;
		cpol_i=1'b0;
		cpha_i=1'b0;
		ss_i=1'b1;
		spi_mode_i=2'b00;
		sppr_i=3'b000;
		spr_i=3'b000;
		#10;
	end
endtask
      		
task reset;
   begin
	  PRESET_n=1'b0;
	  #25;
     PRESET_n=1'b1;
   end
endtask

task modes(input [1:0]i, input j,k);
   begin
      spi_mode_i=i;
      spiswai_i=j;
      ss_i=k;
   end
endtask	

task inputs(input [2:0]m,n, input o,p);
   begin
	   sppr_i=m;
		spr_i=n;
		cpol_i=o;
		cpha_i=p;
	end
endtask

initial 
   begin
	  initialize;
	  reset;
	  modes(2'b00,1'b0,1'b0);
	  #10;
	  inputs(3'b000,3'b010,1'b0,1'b0);
	  #300;
	  inputs(3'b000,3'b010,1'b0,1'b01);
	  #300;
	  inputs(3'b000,3'b010,1'b1,1'b1);
	  #300;
	  inputs(3'b000,3'b010,1'b1,1'b0);
	 end
	 
endmodule
	  
