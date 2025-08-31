module spi_slave_select_tb();

reg PCLK,PRESET_n,mstr_i;
reg spiswai_i,send_data_i;
reg [11:0]BaudRateDivisor_i;
reg [1:0]spi_mode_i;

wire receive_data_o;
wire ss_o;
wire tip_o;

spi_slave_select DUT(.PCLK(PCLK), .PRESET_n(PRESET_n), .mstr_i(mstr_i), . spiswai_i(spiswai_i),
       .send_data_i(send_data_i), .BaudRateDivisor_i(BaudRateDivisor_i), .spi_mode_i(spi_mode_i),
		 .receive_data_o(receive_data_o), .ss_o(ss_o), .tip_o(tip_o));
		 
initial 
begin
  PCLK=1'b0;
  forever #10 PCLK= ~PCLK;
end

task initialize;
begin
  {spiswai_i,send_data_i,BaudRateDivisor_i,spi_mode_i}=0;
  end
endtask
   

task reset;
   begin
	  PRESET_n = 1'b0;
	  #25;
	  PRESET_n = 1'b1;
	 end
endtask

task inputs(input i, input j,input k,input [11:0]l, input [1:0]m);
begin
    mstr_i=i;
   spiswai_i=j;
	send_data_i=k;
	BaudRateDivisor_i=l;
     spi_mode_i=m;
	end
endtask


initial
   begin
	initialize;
	reset;
	inputs(1'b1,1'b0,1'b1,12'd4,2'd00);
	#50;
	inputs(1'b1,1'b0,1'b0,12'd4,2'd00);
	end
	
endmodule
	
   
