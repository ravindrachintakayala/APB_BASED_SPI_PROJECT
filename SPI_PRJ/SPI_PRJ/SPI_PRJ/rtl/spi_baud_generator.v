module spi_baud_generator(
	input PCLK,PRESET_n,spiswai_i,cpol_i,cpha_i,ss_i,
        input [1:0]spi_mode_i,
        input [2:0]sppr_i,spr_i,
       output reg sclk_o,
		 output reg miso_receive_sclk_o,miso_receive_sclk0_o,mosi_send_sclk_o,mosi_send_sclk0_o,
       output [11:0]BaudRateDivisor_o);

wire pre_sclk_s;
reg [11:0]count_s;


//Computing Baud Rate Divisor

assign BaudRateDivisor_o = (sppr_i+1)*(2**(spr_i+1));


//Generating initial SCLK polarity

assign pre_sclk_s=cpol_i ? 1'b1 : 1'b0;


//Generating SPI Clock
    
always@(posedge PCLK or negedge PRESET_n)
     begin
	     if(!PRESET_n)
	           begin
		     count_s<=0;
		     sclk_o<=pre_sclk_s;
	           end
	     else if((!ss_i) && (!spiswai_i) && (spi_mode_i==2'b00 || spi_mode_i== 2'b01))
	          begin
			  if(count_s==((BaudRateDivisor_o/2)-1))
			  begin
				  sclk_o<=~sclk_o;
				  count_s<=0;
			 end
			 else
				 count_s<=count_s+1'b1;
		   end
	    else
	          begin
		         sclk_o<=sclk_o;
	                 count_s<=0;
		  end
     end



//Generating MISO sample flags

always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		begin
		miso_receive_sclk0_o<=0;
		miso_receive_sclk_o<=0;
		end
	else if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
	begin
		if(sclk_o == 1)
		begin
		        if(count_s == ((BaudRateDivisor_o/2)-1))	//half period is over
	          
		                miso_receive_sclk0_o<=1'b1;
			             
		        else 
                         	miso_receive_sclk0_o<=1'b0;
		end
		else
			miso_receive_sclk0_o<=1'b0;
	end

	else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
	begin
		if(sclk_o ==0)
		begin
			if(count_s == ((BaudRateDivisor_o/2)-1)) //half period is over
			
				       miso_receive_sclk_o<=1'b1;
			else
				miso_receive_sclk_o<=1'b0;
		end
		else
			miso_receive_sclk_o<=1'b0;
	end
end


//Generating MOSI sample flags


always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
	begin
		mosi_send_sclk0_o<=0;
		mosi_send_sclk_o<=0;
	end
	else if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
	begin
		if(sclk_o == 1)
		begin
		        if(count_s == ((BaudRateDivisor_o/2)-2))	//half period is over
		                 
							  mosi_send_sclk0_o<=1'b1;
			               
		        else 
                         	mosi_send_sclk0_o<=1'b0;
		end
		else
			mosi_send_sclk0_o<=1'b0;
	end

	else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
	begin
		if(sclk_o ==0)
		begin
			if(count_s == ((BaudRateDivisor_o/2)-2)) //half period is over
			
				mosi_send_sclk_o<=1'b1;
			
			else
				mosi_send_sclk_o<=1'b0;
		end
		else
			mosi_send_sclk_o<=1'b0;
	end

end
endmodule 
