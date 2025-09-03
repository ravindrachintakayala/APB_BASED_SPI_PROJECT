module spi_baud_generator(
input PCLK,PRESET_n,
input [1:0]spi_mode_i,
input spiswai_i,
input [2:0] sppr_i,spr_i,
input cpol_i,cpha_i,ss_i,
output  reg sclk_o,
output reg miso_receive_sclk_o,miso_receive_sclk0_o,
mosi_send_sclk_o,mosi_send_sclk0_o,
output  [11:0] BaudRateDivisor_o );

//Declare Internal Signals
wire pre_sclk_s;
reg [11:0]count_s;

//Compute Baud Rate Divisor
assign BaudRateDivisor_o =(sppr_i + 1)*(2**(spr_i+1));

//Generate Initial SCLK Polarity
assign pre_sclk_s = cpol_i?1:0;


//Generate SPI Clock (SCLK)
always@(posedge PCLK or negedge PRESET_n)

begin

if(!PRESET_n)
begin
	count_s <= 0;
   sclk_o<= pre_sclk_s ;
end

else if ((!ss_i) && (!spiswai_i )&& ((spi_mode_i==2'b00) ||( spi_mode_i==2'b01)))

	if(count_s== ((BaudRateDivisor_o/2)-1) )
	begin
		sclk_o <=~sclk_o;
		count_s <= 0;
	end
	else
	count_s <= count_s +1;

else
	begin
	count_s <= 0;	
   sclk_o <= pre_sclk_s;
   end
 
end

     //Generate MISO Sample Flags
	  
always @(posedge PCLK or negedge PRESET_n)
	begin
        // Default clear
        ///miso_receive_sclk_o  <= 1'b0;
        //miso_receive_sclk0_o <= 1'b0;

        if (!PRESET_n)
       	begin
            miso_receive_sclk_o  <= 1'b0;
            miso_receive_sclk0_o <= 1'b0;
         end 
			
			// Falling Edge Sampling Conditions
		  else if ((!cpha_i && cpol_i) || (cpha_i && !cpol_i)) 
					begin
						if (sclk_o == 1'b1 )
					begin
				  
						if(count_s == ((BaudRateDivisor_o/2)-1))
					 begin
                        miso_receive_sclk0_o <= 1'b1;
					 end
					 else
							   miso_receive_sclk0_o <= 1'b0;
								
					 end
				  else
				  
                 miso_receive_sclk0_o <= 1'b0;
           
            
				// Rising Edge Sampling Conditions
				
				end
            else if ((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
              if (sclk_o == 1'b0)
				  begin
					 if(count_s == ((BaudRateDivisor_o/2) - 1)) 
					  begin
                    miso_receive_sclk_o <= 1'b1;
                 end
					 else 
					    miso_receive_sclk_o <= 1'b0;
					end
					else
						miso_receive_sclk_o <= 1'b0;
					     
            end
       
	 
	 //Generate MOSI Sample Flags
	 
always @(posedge PCLK or negedge PRESET_n)
	begin
        // Default clear
       // mosi_send_sclk_o  <= 1'b0;
        //mosi_send_sclk0_o <= 1'b0;

        if (!PRESET_n)
       	begin
            mosi_send_sclk_o  <= 1'b0;
            mosi_send_sclk0_o <= 1'b0;
         end 
			
		  else 
            
				// Falling Edge Sampling Conditions
            if ((!cpha_i && cpol_i) || (cpha_i && !cpol_i)) 
				begin
                if (sclk_o == 1'b1 )
					 begin
					 if(count_s == ((BaudRateDivisor_o/2)-2)) 
					 
					 begin
                        mosi_send_sclk0_o <= 1'b1;
					 end
					 else
							   mosi_send_sclk0_o <= 1'b0;
					 end
					 else
							   mosi_send_sclk0_o <= 1'b0;
							   
                
            end
            
				// Rising Edge Sampling Conditions
            else if ((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
				
                if (sclk_o == 1'b0) 
					 begin
					 if(count_s == ((BaudRateDivisor_o/2)-2))
					 
					 begin
                    mosi_send_sclk_o <= 1'b1;
                end
					 else 
					     mosi_send_sclk_o <= 1'b0;
					end
					else 
					     mosi_send_sclk_o <= 1'b0;
						  
					     
            end
        
    
	 
	 
endmodule
