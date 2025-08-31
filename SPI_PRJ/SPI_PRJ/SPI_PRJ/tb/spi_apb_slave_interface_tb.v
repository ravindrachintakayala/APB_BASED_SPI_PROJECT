module spi_apb_slave_interface_tb();


    
reg  PCLK;
reg  PRESET_n;
reg  PSEL_i;
reg  PENABLE_i;
reg  PWRITE_i;
reg  [2:0] PADDR_i;
reg  [7:0] PWDATA_i;
reg  tip_i;
reg  ss_i, receive_data_i;

wire  [7:0] PRDATA_o,mosi_data_o;
wire  PREADY_o;
wire  PSLVERR_o;
wire  spi_interrupt_request_o,mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o;
wire  [2:0]spr_o,sppr_o;
wire  [1:0] spi_mode_o;


spi_apb_slave_interface dut (.PCLK(PCLK),.PRESET_n(PRESET_n),.PSEL_i(PSEL_i),
        .PENABLE_i(PENABLE_i),.PWRITE_i(PWRITE_i),.PADDR_i(PADDR_i),
        .PWDATA_i(PWDATA_i), .tip_i(tip_i), .ss_i(ss_i), .receive_data_i(receive_data_i),
		  .PRDATA_o(PRDATA_o), .mosi_data_o(mosi_data_o), .PREADY_o(PREADY_o),.PSLVERR_o(PSLVERR_o), 
		  .spi_interrupt_request_o(spi_interrupt_request_o),
		  .mstr_o(mstr_o), .cpol_o(cpol_o), .cpha_o(cpha_o), .lsbfe_o(lsbfe_o),
		  .spiswai_o(spiswai_o), .spi_mode_o(spi_mode_o),.spr_o(spr_o), .sppr_o(sppr_o));

initial
begin
  PCLK=1'b0;
  forever #10 PCLK=~PCLK;
end  
	 
// APB write task
task apb_write(input [2:0] addr, input [7:0] data);
    begin
        @(posedge PCLK);
		  tip_i=1;
        PSEL_i    = 1;
        PWRITE_i  = 1;
        PENABLE_i = 0;
        PADDR_i   = addr;
        PWDATA_i  = data;
        @(posedge PCLK);
        PENABLE_i = 1;  
        @(posedge PCLK);
        PSEL_i    = 0;
        PENABLE_i = 0;
    end
endtask


// APB read task
task apb_read(input [2:0] addr);
    begin
        @(posedge PCLK);
        PSEL_i    = 1;
        PWRITE_i  = 0;
        PENABLE_i = 0;
        PADDR_i   = addr;
        @(posedge PCLK);
        PENABLE_i = 1;  
        @(posedge PCLK);
        PSEL_i    = 0;
        PENABLE_i = 0;
                  
	 end
endtask

    
// Test sequence
initial 
begin
        // Initializing
        PCLK      = 0;
        PRESET_n  = 0;
        PSEL_i    = 0;
        PENABLE_i = 0;
        PWRITE_i  = 0;
        PADDR_i   = 0;
        PWDATA_i  = 0;
		 

        // Reset release
        #20 PRESET_n = 1;

        // Write and Read Back
        apb_write(3'b000, 8'hAA);  
        apb_read(3'b000);          

        apb_write(3'b001, 8'hCC);  
        apb_read(3'b001);

        apb_write(3'b010, 8'hFF);  
        apb_read(3'b010);

        #20;
        $finish;
    end

endmodule 
