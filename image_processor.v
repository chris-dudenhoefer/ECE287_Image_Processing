module ye_project(clk, rst, rst1, data_r, data_g, data_b, hsync, vsync, clk_25M, filter, k_in, store, led_store, led_display, div);

input clk,rst;
input rst1;
input [2:0] filter; 		 //set filter enable inputs
   parameter ID=3'd0;   	//identity
   parameter INV=3'd1;     //invert 
   parameter BL=3'd2;      //brighten        
   parameter BR=3'd3;      //blur
   parameter CUST=3'd4;    //custom  

input [2:0]k_in;           //custom kernel inputs
input store;					//store values
input div;						//determine custom divide value
   
parameter    WIDTH  = 200;    // Image width
parameter    HEIGHT  = 200;   // Image height

output [7:0] data_r;
output [7:0] data_g;
output [7:0] data_b;
output reg [8:0] led_store;
output reg led_display;
reg[7:0] data_r;
reg[7:0] data_g;
reg[7:0] data_b;
output hsync;
output vsync;
reg hsync;
reg vsync;
output clk_25M;// vga clock, we are using 800*600 resolution and VGA_CLK=1056x628x60=39790080~40MHz;


reg [9:0] x_cnt;//horizontal counter
reg [9:0] y_cnt;//vertical counter


 frequency_divider_by2 my_fdb2(clk,rst,clk_25M); // generate VGA_clock


   parameter H_SYNC_END   = 96;     //h-sync end time
   parameter V_SYNC_END   = 2;      //V- sync end time
   parameter H_SYNC_TOTAL = 800;    //h-total
   parameter V_SYNC_TOTAL = 524;    //v-total

    
   //horizontal scan
   always@(posedge clk_25M or negedge rst)
   begin  
       if(!rst) begin x_cnt <= 10'd0;end
       else if (x_cnt == H_SYNC_TOTAL) begin x_cnt <= 10'd0;end
       else begin x_cnt <= x_cnt + 1'b1;end
   end
   
   //vertical scan
   always@(posedge clk_25M or negedge rst)
   begin    
       if(!rst) begin y_cnt <= 10'd0;end
       else if  (y_cnt == V_SYNC_TOTAL)begin y_cnt <= 10'd0;end
       else if (x_cnt == H_SYNC_TOTAL) begin y_cnt <= y_cnt + 1'b1;end
       else begin y_cnt <= y_cnt;end
   end
    
   //H_SYNC signal
   always@(posedge clk_25M or negedge rst)    
   begin
       if(!rst) begin hsync <= 1'd0;end
       else if (x_cnt == 10'd0)begin hsync <= 1'b0;end
       else if (x_cnt == H_SYNC_END)begin hsync <= 1'b1;end
       else  begin hsync <= hsync;end
   end
    
   //V_SYNC signal
   always@(posedge clk_25M or negedge rst)
   begin    
       if(!rst) begin vsync <= 1'd0;end
       else if (y_cnt == 10'd0) begin vsync <= 1'b0;end
       else if (y_cnt == V_SYNC_END) begin vsync <= 1'b1;end
       else  begin vsync <= vsync;   end
   end 
    
 


   
   
   parameter THRESHOLD= 5;

// addresses for all memories
    reg [15:0] addr;
     reg [15:0] addr1;
      reg [15:0] addr2;
       reg [15:0] addr3;
        reg [15:0] addr4;
         reg [15:0] addr5;
          reg [15:0] addr6;
           reg [15:0] addr7;
            reg [15:0] addr8;
// output for all memories
    wire[7:0] q;
    wire[7:0] q1;
    wire[7:0] q2;
    wire[7:0] q3;
    wire[7:0] q4;
    wire[7:0] q5;
    wire[7:0] q6;
    wire[7:0] q7;
    wire[7:0] q8;
    

    // memory
    MEM myPic(addr,clk_25M,q);
    MEM1 myPic1(addr1,clk_25M,q1);
    MEM2 myPic2(addr2,clk_25M,q2);
    MEM3 myPic3(addr3,clk_25M,q3);
    MEM4 myPic4(addr4,clk_25M,q4);
    MEM5 myPic5(addr5,clk_25M,q5);
    MEM6 myPic6(addr6,clk_25M,q6);
    MEM7 myPic7(addr7,clk_25M,q7);
    MEM8 myPic8(addr8,clk_25M,q8);
    


    
//////////////State machine///////////////
//new inputs:  add another bit to filter select (3-bit en)
//             custom (y/n)
//             3 bit kernel input (for custom)
//             blur control (y/n)
//                if(y)--->divide==sum of all kernel input bits
//                if(n)--->divide==1;
//             store custome kernel values (y/n)

parameter ST=4'd0;
parameter identity=4'd1;
parameter blur=4'd2;
parameter brighten=4'd3;
parameter invert=4'd4;                   //set states
parameter custom=4'd5;
	parameter input_value=4'd6;
   parameter store_value=4'd7;
	parameter check=4'd8;
	parameter i_increment=4'd9;
   parameter display_custom=4'd10; 

reg [3:0]S;
reg [3:0]NS;
reg [2:0]k[0:8];
reg [2:0]k_custom[0:8];                  //state machine control bits
reg [6:0]divide;
reg [3:0]i;

always@(posedge clk_25M or negedge rst)
begin 
      if (rst==1'b0) begin
         S<=ST; end
    else begin
         S<=NS; end
end

always@(*)
      case(S)
			ST: begin
				case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=custom;
            endcase
         end
			
			identity:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=custom;
            endcase
         end
			
         blur:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=custom;
            endcase
         end
			
         brighten:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=custom;
            endcase
         end
			
         invert:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=custom;
            endcase
         end
			
			custom:begin            
				case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST:	if(store==1) begin
				     	   NS=input_value; end
				          else begin
				        	NS=custom; end
            endcase
			end
			
			input_value: begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST:	if(store==0) begin
								NS=store_value; end
							else begin
								NS=input_value; end
            endcase			
			end
			
			store_value: begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
					CUST: NS=check;
            endcase
			end
				
			check:begin			
				case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
					CUST:	if(store==1) begin
								NS=i_increment; end
							else if(i>7) begin
								NS=display_custom;end
							else begin
								NS=check; end
				endcase
			end
			
			i_increment:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=input_value;  
				endcase
			end
				
         display_custom:begin
            case(filter)
					ID:  	NS=identity;
					INV:  NS=invert;
					BL:   NS=blur;
               BR:   NS=brighten;
               CUST: NS=display_custom;
            endcase
         end
      endcase

always@(posedge clk_25M or negedge rst)
begin
   if(rst==1'b0) begin
		k[0]=0;
		k[1]=0;
		k[2]=0;
		k[3]=0;
		k[4]=1;
		k[5]=0;
		k[6]=0;
		k[7]=0;
		k[8]=0;
		led_store[8:0]=0;
		led_display=0;
		divide=1; end
	else
	begin
		case(S)
			identity:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				led_store[8:0]=0;
				led_display=0;
				divide=1; end
				
			blur:begin
				k[0]=1;
				k[1]=2;
				k[2]=1;
				k[3]=2;
				k[4]=4;
				k[5]=2;
				k[6]=1;
				k[7]=2;
				k[8]=1; 
				led_store[8:0]=0;
				led_display=0;
				divide=16; end
				
			brighten:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=3;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				led_store[8:0]=0;
				led_display=0;
				divide=2; end
				
			custom:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				divide=1;
				i=0;
				k_custom[0]=0;
				k_custom[1]=0;
				k_custom[2]=0;
				k_custom[3]=0;
				k_custom[4]=0;
				k_custom[5]=0;
				k_custom[6]=0;
				k_custom[7]=0;		
				k_custom[8]=0;
				led_store[8:0]=0;
				led_display=0;end
				
			input_value:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				divide=1;end
				
			store_value:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				divide=1;
				k_custom[i]=k_in;
				led_store[i]=1;end
			
			check:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				divide=1;end
				
			i_increment:begin
				k[0]=0;
				k[1]=0;
				k[2]=0;
				k[3]=0;
				k[4]=1;
				k[5]=0;
				k[6]=0;
				k[7]=0;
				k[8]=0;
				divide=1;
				i=i+1;end
				
			display_custom:begin
				k[0]=k_custom[0];
				k[1]=k_custom[1];
				k[2]=k_custom[2];
				k[3]=k_custom[3];
				k[4]=k_custom[4];
				k[5]=k_custom[5];
				k[6]=k_custom[6];
				k[7]=k_custom[7];
				k[8]=k_custom[8];
				if(div==1)begin
					divide=k[0]+k[1]+k[2]+k[3]+k[4]+k[5]+k[6]+k[7]+k[8];end
				else begin
					divide=1;end
				led_display=1;end
		endcase
	end
end
    
always@(posedge clk_25M or negedge rst1)
begin
	if (!rst1) begin

             data_r=8'b00000000;
             data_g=8'b00000000;
             data_b=8'b00000000;
             addr = 0;
            
   end
                
	else if(350<=x_cnt&&x_cnt<550 && 150<=y_cnt&&y_cnt<350 ) begin 
	
		if(S==invert) begin 
			
			data_b[7:6]= 3-q[1:0];
			data_b[5:0]= 6'b111111;
	
			data_g[7:5]= 7-q[4:2];
			data_g[4:0]= 5'b11111;
			
			data_r[7:5]= 7-q[7:5];
			data_r[4:0]= 5'b11111;
			addr=(x_cnt-12)+(y_cnt+177)*10'd200;
			
		end 

		else begin 
		
			if(((k[0]*q[1:0]+k[1]*q1[1:0]+k[2]*q2[1:0]+k[3]*q3[1:0]+k[4]*q4[1:0]+k[5]*q5[1:0]+k[6]*q6[1:0]+k[7]*q7[1:0]+k[8]*q8[1:0])/divide)>3)	begin 
				data_b[7:6] = 2'd3;
				data_b[5:0]= 6'b111111;
				end 
		
			else begin 
				data_b[7:6]= ((k[0]*q[1:0]+k[1]*q1[1:0]+k[2]*q2[1:0]+k[3]*q3[1:0]+k[4]*q4[1:0]+k[5]*q5[1:0]+k[6]*q6[1:0]+k[7]*q7[1:0]+k[8]*q8[1:0])/divide);
				data_b[5:0]= 6'b111111;
				end 
	
			if((k[0]*q[4:2]+k[1]*q1[4:2]+k[2]*q2[4:2]+k[3]*q3[4:2]+k[4]*q4[4:2]+k[5]*q5[4:2]+k[6]*q6[4:2]+k[7]*q7[4:2]+k[8]*q8[4:2])/divide>7)	begin
				data_g[7:5]= 3'd7;
				data_g[4:0]= 5'b11111;
				end
			
			else begin
				data_g[7:5]= (k[0]*q[4:2]+k[1]*q1[4:2]+k[2]*q2[4:2]+k[3]*q3[4:2]+k[4]*q4[4:2]+k[5]*q5[4:2]+k[6]*q6[4:2]+k[7]*q7[4:2]+k[8]*q8[4:2])/divide;
				data_g[4:0]= 5'b11111;
				end
	
			if((k[0]*q[7:5]+k[1]*q1[7:5]+k[2]*q2[7:5]+k[3]*q3[7:5]+k[4]*q4[7:5]+k[5]*q5[7:5]+k[6]*q6[7:5]+k[7]*q7[7:5]+k[8]*q8[7:5])/divide>7)	begin
				data_r[7:5]= 3'd7;
				data_r[4:0]= 5'b11111;
				end
				
			else begin
				data_r[7:5]= (k[0]*q[7:5]+k[1]*q1[7:5]+k[2]*q2[7:5]+k[3]*q3[7:5]+k[4]*q4[7:5]+k[5]*q5[7:5]+k[6]*q6[7:5]+k[7]*q7[7:5]+k[8]*q8[7:5])/divide;
				data_r[4:0]= 5'b11111;
				end
  
			addr=(x_cnt-12)+(y_cnt+177)*10'd200-WIDTH-1;
			addr1=(x_cnt-12)+(y_cnt+177)*10'd200-WIDTH;
			addr2=(x_cnt-12)+(y_cnt+177)*10'd200-WIDTH+1;
			addr3=(x_cnt-12)+(y_cnt+177)*10'd200-1;
			addr4=(x_cnt-12)+(y_cnt+177)*10'd200;
			addr5=(x_cnt-12)+(y_cnt+177)*10'd200+1;
			addr6=(x_cnt-12)+(y_cnt+177)*10'd200+WIDTH-1;
			addr7=(x_cnt-12)+(y_cnt+177)*10'd200+WIDTH;
			addr8=(x_cnt-12)+(y_cnt+177)*10'd200+WIDTH+1;
	
		end 

	end

	else begin
  
             data_r=8'b00000000;

             data_g=8'b00000000;

             data_b=8'b00000000;
               
   end 
	
end 
    
    
endmodule