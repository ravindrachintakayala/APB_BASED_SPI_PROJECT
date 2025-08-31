module spi_apb_slave_interface( 
	input PCLK, PRESET_n, PWRITE_i, PSEL_i, PENABLE_i, ss_i, receive_data_i, tip_i, 
	input [2:0]PADDR_i, 
	input [7:0]PWDATA_i,miso_data_i, 
	
	output PREADY_o,PSLVERR_o,spi_interrupt_request_o,mstr_o,cpol_o,cpha_o,lsbfe_o,spiswai_o, 
	output reg send_data_o, 
	output reg  [7:0]PRDATA_o,mosi_data_o, 
	output reg [1:0] spi_mode_o, 
	output [2:0]spr_o,sppr_o);


reg [1:0]STATE, next_state, next_mode;
reg [7:0] SPI_CR_1, SPI_CR_2, SPI_BR, SPI_SR, SPI_DR;

wire spie,spif,sptef,modf,modfen,spe,ssoe,sptie;
wire [7:0]mask1,mask2;


assign mask1 = 8'b00011011;
assign mask2 = 8'b01110111;

wire wr_enb, rd_enb;


//APB FSM PARAMETER STATES
       localparam IDLE = 2'b00,
                 SETUP = 2'b01,
                 ENABLE = 2'b10;


	 
//SPI FSM PARAMETER STATES
       localparam spi_run = 2'b00,
                 spi_wait = 2'b01,
                 spi_stop = 2'b10;
       
	 
//APB FSM LOGIC


//Present state logic
always@( posedge PCLK or negedge PRESET_n ) 
begin
               if(!PRESET_n)
                       STATE <= IDLE;
               else
                       STATE <= next_state;
end


//next state logic for APB master

always@(*) 
begin
               case (STATE)
                       IDLE : begin
                               if(PSEL_i && !PENABLE_i)
                                       next_state = SETUP;
                               else
                                       next_state = IDLE;
                              end
                       SETUP : begin
                               if(PSEL_i && !PENABLE_i)
                                       next_state = SETUP;
                               else if(PSEL_i && PENABLE_i)
                                       next_state = ENABLE;
                               else
                                       next_state = IDLE;
                               end
                       ENABLE : begin
                               if(PSEL_i)
                                       next_state = SETUP;
                               else
                                       next_state = IDLE;
                                end
                       default: next_state = IDLE;
               endcase
end




//SPI FSM LOGIC

//PRESENT STATE LOGIC
     
always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n)
                       spi_mode_o <= spi_run;
               else
                       spi_mode_o <= next_mode;
end


//NEXT STATE LOGIC FOR SPI CONTROLLER
     
always@(*) 
begin
               case(spi_mode_o)
                       spi_run : begin
                               if(!spe)
                                       next_mode = spi_wait;
                               else
                                       next_mode = spi_run;
                                end
                       spi_wait : begin
                               if(spe)
                                       next_mode = spi_run;
                               else if(spiswai_o)
                                       next_mode = spi_stop;
                               else
                                       next_mode = spi_wait;
                               end
                       spi_stop : begin
                               if(spe)
                                       next_mode = spi_run;
                               else if(!spiswai_o)
                                       next_mode = spi_wait;
                               else
                                       next_mode = spi_stop;
                               end
                       default: next_mode = spi_run;
               endcase
end





assign PREADY_o = (STATE == ENABLE)? 1'b1 : 1'b0;

assign PSLVERR_o = ((STATE == ENABLE) && tip_i) ? 1'b1 :1'b0;

assign wr_enb = (STATE == ENABLE) && PWRITE_i;

assign rd_enb = (STATE == ENABLE) && !PWRITE_i;
  


//write operation on registers
  
always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n) 
	            begin
                       SPI_CR_1 <= 8'b00000100;
                       SPI_CR_2 <= 8'b00000000;
                       SPI_BR   <= 8'b00000000;
               end
               else 
	            begin

                       if(wr_enb) 
		                 begin
                               case(PADDR_i)
                                       3'b000 : SPI_CR_1 <= PWDATA_i;
                                       3'b001 : SPI_CR_2 <= PWDATA_i & mask1;
                                       3'b010 : SPI_BR   <= PWDATA_i & mask2;
                                       default : 
				           begin
                       end
                               endcase
                       end
                       else 
		                 begin
                               SPI_CR_1 <= SPI_CR_1;
                               SPI_CR_2 <= SPI_CR_2;
                               SPI_BR <= SPI_BR;

                       end
               end
       end



//Reading

always@(*) 
begin
               PRDATA_o = 8'd0;
               if(rd_enb) 
	            begin
                       case(PADDR_i)
                               3'b000 : PRDATA_o = SPI_CR_1;
                               3'b001 : PRDATA_o = SPI_CR_2;
                               3'b010 : PRDATA_o = SPI_BR;
                               3'b011 : PRDATA_o = SPI_SR;
                               3'b101 : PRDATA_o = SPI_DR;
                               default : PRDATA_o = 8'd0;
                       endcase
               end
               else
                       PRDATA_o = 8'd0;
       end



//CONTROL AND BAUD REGISTER FIELDS

assign mstr_o = SPI_CR_1[4];

assign cpol_o = SPI_CR_1[3];

assign cpha_o = SPI_CR_1[2];

assign lsbfe_o = SPI_CR_1[0];

assign spie = SPI_CR_1[7];

assign spe = SPI_CR_1[6];

assign ssoe = SPI_CR_1[1];

assign sptie = SPI_CR_1[5];

assign spiswai_o = SPI_CR_2[1];

assign modfen = SPI_CR_2[4];

assign sppr_o = SPI_BR[6:4];

assign spr_o = SPI_BR[2:0];


//Mode Fault that goes high only active

assign modf = (~ss_i) & mstr_o & modfen & (~ssoe);



//Interrupt detection based on control flags and status flags

assign spi_interrupt_request_o = (!spie && !sptie)? 1'b0:(spie && !sptie)? (spif | modf):(!spie && sptie)? sptef : (spif | modf | sptef) ;
      



//SPI STATUS REGISTER

assign spif = ( SPI_DR != 8'd0) ? 1'b1 : 1'b0;

assign sptef = ( SPI_DR == 8'd0) ? 1'b1 : 1'b0;



always@(*) 
begin
               if(!PRESET_n)
	            begin
                       SPI_SR = 8'b00100000;
               end
               else
	            begin
                       SPI_SR[4] = modf;
                       SPI_SR[5] = sptef;
                       SPI_SR[7] = spif;
                       SPI_SR[6] = 0;
                       SPI_SR[3:0] = 4'b0000;
               end
       end



//sequenatial block for send_data signal

always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n)
                       send_data_o <= 1'b0;
               else if(wr_enb)
                       send_data_o <= send_data_o ;
               else 
	            begin
                       if((SPI_DR == PWDATA_i) &&( SPI_DR != miso_data_i) && ((spi_mode_o == spi_run) ||( spi_mode_o == spi_wait))) 
		                 begin
                               send_data_o <= 1'b1;
                       end
                       else if(((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)) && receive_data_i)
                               send_data_o <= 1'b1;
                       else
                               send_data_o <= 1'b0;
               end
       end


//modi_data_o logic  

always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n)
                       mosi_data_o <= 8'd0;
               else if(!wr_enb) 
					begin
                if((SPI_DR == PWDATA_i) && ( SPI_DR != miso_data_i) &&((spi_mode_o == spi_run) || (spi_mode_o == spi_wait))) 
		       
                               mosi_data_o <= SPI_DR ;  
			end		
end					 
       
/*always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n)
                       mosi_data_o <= 8'd0;
               else if(wr_enb) 
	       begin
                       if((SPI_DR == PWDATA_i) && ( SPI_DR != miso_data_i) &&((spi_mode_o == spi_run) || (spi_mode_o == spi_wait))) 
		       begin
                               mosi_data_o <= SPI_DR ;
                       end
                       else
                               mosi_data_o <= mosi_data_o;
               end
               else
                       mosi_data_o <= mosi_data_o;
       end
*/


//spip_dr logic

always@(posedge PCLK or negedge PRESET_n) 
begin
               if(!PRESET_n)
                       SPI_DR <= 8'b00000000;
               else if(wr_enb) 
						begin
                       if(PADDR_i == 3'b101)
                               SPI_DR <= PWDATA_i;
                       else
                               SPI_DR <= SPI_DR;
               end
               else if((SPI_DR == PWDATA_i) && ( SPI_DR != miso_data_i) &&((spi_mode_o == spi_run) || (spi_mode_o == spi_wait))) 
							begin
                               SPI_DR <= 8'd0;
                       end
               else if(((spi_mode_o == spi_run) || (spi_mode_o == spi_wait)) && receive_data_i)
                               SPI_DR <= miso_data_i;
                 else
                               SPI_DR <= SPI_DR;
             //  end
       end
endmodule

