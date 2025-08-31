module spi_shifter(
	input PCLK,PRESET_n,
	input ss_i,send_data_i,
	input lsbfe_i,cpha_i,cpol_i,
	input miso_receive_sclk_i,miso_receive_sclk0_i,
	input mosi_send_sclk_i,mosi_send_sclk0_i,
	input[7:0]data_mosi_i,
	input miso_i,
	input receive_data_i,

	output reg mosi_o,
	output reg [7:0]data_miso_o);

reg [7:0]shift_reg;
reg [7:0]temp_reg;
reg [2:0]count,count1,count2,count3;



//Transmitting data register logic

always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		shift_reg<=8'b0;
	else if(send_data_i)
		shift_reg<=data_mosi_i;
end



   // Output received data
    always @(posedge PCLK or negedge PRESET_n) 
	 begin
        if (!PRESET_n)
            data_miso_o <= 8'd0;
        else if (receive_data_i)
            data_miso_o <= temp_reg;
        else
            data_miso_o <= 8'd0;
    end 

//assign data_miso_o=receive_data_i ? temp_reg:8'b0;

//count,count1,mosi_sending

always@(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
	    begin
		 mosi_o  <= 1'b0;
		 count<=8'h00;
		 count1<=8'h07;
		 end
	 else
	    if(!ss_i)
		 begin
			  if((!cpha_i&&cpol_i) || (cpha_i&&!cpol_i))
			  begin
			     if(lsbfe_i)
				  begin
				     if(count<=3'd7)
					  begin
					     if(mosi_send_sclk0_i)
						  begin
						      mosi_o <= shift_reg[count];
						      count<=count+1'b1;
							end
						  else
						      count<=count;
						end
						else
						   count<=3'd0;
					end
					else
					   begin
						  if(count1>=3'd0)
					     begin
					        if(mosi_send_sclk0_i)
							  begin
							      mosi_o <= shift_reg[count1];
						         count1<=count1-1'b1;
								end
						     else
						         count1<=count1;
						  end
						  else
						     count1<=3'd7;
					    end 
					end
				else 
				begin
			     if(lsbfe_i)
				  begin
				     if(count<=3'd7)
					  begin
					     if(mosi_send_sclk_i)
						  begin
						      mosi_o <= shift_reg[count];
						      count<=count+1'b1;
							end
						  else
						      count<=count;
						end
						else
						   count<=3'd0;
					end
					else
					   begin
						  if(count1>=3'd0)
					     begin
					        if(mosi_send_sclk_i)
							  begin
							      mosi_o <= shift_reg[count1];							     
						         count1<=count1-1'b1;
								end
						     else
						         count1<=count1;
						  end
						  else
						     count1<=3'd7;
					    end 
					end
				
			end
		
end
		


//count2,count3,miso_receiving

always@(posedge PCLK or negedge PRESET_n)
begin
    if(!PRESET_n)
	    begin
		 temp_reg<=8'd0;
		 count2<=8'h00;
		 count3<=8'h07;
		 end
	 else
	    if(!ss_i)
		 begin
			  if((!cpha_i&&cpol_i) || (cpha_i&&!cpol_i))
			  begin
			     if(lsbfe_i)
				  begin
				     if(count2<=3'd7)
					  begin
					     if(miso_receive_sclk0_i)
						  begin 
						  temp_reg[count2]<=miso_i;
						      count2<=count2+1'b1;
							end
						  else
						      count2<=count2;
						end
						else
						   count2<=3'd0;
					end
					else
					   begin
						  if(count3>=3'd0)
					     begin
					        if(miso_receive_sclk0_i)
							  begin
							      temp_reg[count3]<=miso_i;
						         count3<=count3-1'b1;
								end
						     else
						         count3<=count1;
						  end
						  else
						     count3<=3'd7;
					    end 
					end
				else 
				begin
			     if(lsbfe_i)
				  begin
				     if(count2<=3'd7)
					  begin
					     if(miso_receive_sclk_i)
						  begin
						      temp_reg[count2]<=miso_i;
						      count2<=count2+1'b1;
							end
						  else
						      count2<=count2;
						end
						else
						   count2<=3'd0;
					end
					else
					   begin
						  if(count3>=3'd0)
					     begin
					        if(miso_receive_sclk_i)
							  begin
							      temp_reg[count3]<=miso_i;
						         count3<=count3-1'b1;
								end
						     else
						         count3<=count3;
						  end
						  else
						     count3<=3'd7;
					    end 
					end
				
			end

end

endmodule 
