module spi_slave_select(
	input PCLK,PRESET_n,mstr_i,
	input spiswai_i,send_data_i,
	input [11:0]BaudRateDivisor_i,
	input [1:0]spi_mode_i,

	output reg receive_data_o,
	output  reg ss_o,
	output tip_o);

reg [15:0]count_s;                 //tracks baud-based timing
wire [15:0]target_s;               //store baud-based count value
reg rcv_s;                       //internal reg to trigger receive_data_o


//continuous assignments

assign target_s=((BaudRateDivisor_i/2) * 16);
assign tip_o=~ss_o;


//for receive_data

always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		receive_data_o<=1'b0;
	else
		receive_data_o<=rcv_s;
end




//for rcv_s


always@(posedge PCLK or negedge PRESET_n)
begin
	if(!PRESET_n)
		rcv_s <= 1'b0;
	else if(mstr_i && (spi_mode_i==2'b01 || (!spiswai_i && (spi_mode_i == 2'b00))))
		begin
			if(send_data_i == 1) /////////////
				begin
					rcv_s <= rcv_s;
				end
				
				else if(count_s <= target_s-1'b1)
				begin
					if(count_s == target_s-1'b1)
						rcv_s <=1'b1;
					//else
						//rcv_s <= 1'b0;
				end
				else 
					rcv_s <= 1'b0;
		//	end
			//else
				//rcv_s <= 1'b0;
		//end
		//else
			//rcv_s <= 1'b0;
	end
end




//for ss_o


always@(posedge PCLK or negedge PRESET_n)
begin   
        if(!PRESET_n)
                ss_o <= 1'b1;
        else if(mstr_i && (spi_mode_i==2'b01 || (!spiswai_i && (spi_mode_i == 2'b00))))
                begin
                        if(!send_data_i)
                        begin
                                if(count_s <= target_s-1'b1)
												ss_o <=1'b0;
                                else
                                        ss_o <= 1'b1;
                        end
                        else
                                ss_o <= 1'b0;
                end
                else
                        ss_o <= 1'b1;
        //end
end




//for count_s


always@(posedge PCLK or negedge PRESET_n)
begin   
        if(!PRESET_n)
                count_s <= 16'hffff;
        else if(mstr_i && ((spi_mode_i==2'b00) || (!spiswai_i && (spi_mode_i == 2'b01))))
                begin
                        if(!send_data_i)
                        begin
                                if(count_s <= target_s-1'b1)
												count_s <= count_s + 1'b1;
                                else
                                        count_s <= 16'hffff;
                        end
                        else
                               count_s <= 16'b0;
                end
                else
                        count_s <= 16'hffff;
        //end
end



endmodule
