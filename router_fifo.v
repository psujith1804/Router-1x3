module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,ifb_state,data_in,empty,full,data_out);
	
	input clock,resetn,write_enb,soft_reset,read_enb,ifb_state;
	input [7:0] data_in;
	
	output reg empty,full;
	output reg [7:0] data_out;

	reg [8:0] mem [15:0];

	reg [3:0] i,j,read_incr,write_incr;

	reg [5:0] payload_size;

	integer itr;

	
	//full or empty
	always@(write_incr)
	begin 
		if(write_incr == 4'b1111)
			full = 1'b1;
		else 
			full = 1'b0;

		if(write_incr == 4'b0)
			empty = 1'b1;
		else
			empty = 1'b0;
	end

//write
	always@(posedge clock)
	begin
		if(!resetn || soft_reset)
			begin

			for(itr=0;itr<16;itr=itr+1)
			mem[itr]<=0; 
			end
		
		else if(write_enb && !full)

				mem[i] <= {ifb_state,data_in}; 
	
	end

always@(posedge clock)
	begin
		if(!resetn)
			data_out <= 8'd0;

		else if(soft_reset)
			data_out <= 8'bzz;
		
		else
			begin 

				if(read_enb && !empty)
					data_out <= mem[j];

				if(read_incr == 0)
					data_out<=8'bz;
			end
	end

	always@(posedge clock)
	begin

		if(!resetn || soft_reset)
		begin
			i <= 4'b0;
			j <= 4'b0;
		end

		else
			begin
				if(write_enb & !full)
					i <= i+1'b1;
				if(read_enb & !empty)
					j <= j+1'b1;
			end
	end

always@(posedge clock)
	begin
		if(!resetn)
		begin
			read_incr <= 6'b0; 
		end

		//else if(soft_reset)

		else 

		begin
			if(read_enb && !empty)
			begin
			if(mem[j[3:0]][8])                       
            read_incr <= mem[j[3:0]][7:2] + 1'b1;

			else if(read_incr != 6'b0)
			read_incr <= read_incr - 1'b1;
				
		end
	end
	end


always @(posedge clock )
begin
   if( !resetn )
       write_incr <= 0;

   //simultaneous read write
   else if( (!full && write_enb) && ( !empty && read_enb ) )
          write_incr <= write_incr;
   //write
   else if( !full && write_enb )
          write_incr <=    write_incr + 1;					
   //read 
   else if( !empty && read_enb )									
          write_incr <=    write_incr - 1;
   // else
   //       write_incr <=    increment;
end

endmodule