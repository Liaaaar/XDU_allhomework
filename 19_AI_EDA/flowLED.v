//author:fkw
//creat date:2021/10/30
//version: V1.0
module flow_fin
(
    input sys_clk, //系统时钟
    input sys_rst_n,//系统复位，低电平有效
    output reg [3:0] led //个led
);
//reg define
reg [25:0] counter; //计数器
reg flag;//标志灯是否亮
reg temp;//标志0.25s计时和0.5s计时，temp=0->0.25s  temp=1->0.5s
//可能要删除initial的几行
initial
begin
	flag=0;
	temp=0;
end
//计数器对系统时钟计数，0.25s于0.5s交替出现
always @(posedge sys_clk or negedge sys_rst_n) 
begin
    if (!sys_rst_n)
    begin
        counter<=26'd0;
        temp<=0;
        flag<=0;
    end
    else
    begin    
        if (temp==0&&counter<26'd1250_0000)
        begin
            counter<=counter+1'b1;
            flag<=0;
        end
        else if(temp==0&&counter==26'd1250_0000)
        begin
            flag<=1;
            counter<= 26'd0;
            temp<=1;
        end
        else if(temp==1&&counter<26'd2500_0000)
        begin    
            counter<=counter+1'b1;
            flag<=0;
        end
        else if(temp==1&&counter==26'd2500_0000)
        begin
            flag<=1;
            counter<= 26'd0;
            temp<=0;
        end
    end
end   

reg [7:0] out;//定义八种花型
localparam out0=0;
localparam out1=1;
localparam out2=2;
localparam out3=3;
localparam out4=4;
localparam out5=5;
localparam out6=6;
localparam out7=7;

reg [1:0] out0_in;     //4路同时亮灭
localparam   out0_in0=0;
localparam   out0_in1=1; 

reg [2:0] out1_in;     //正向每次亮1路
localparam   out1_in0=0;
localparam   out1_in1=1; 
localparam   out1_in2=2;
localparam   out1_in3=3; 


reg [2:0] out2_in;     //反向每次亮1路
localparam   out2_in0=0;
localparam   out2_in1=1; 
localparam   out2_in2=2;
localparam   out2_in3=3; 


reg [1:0] out3_in;     //亮灭相间
localparam   out3_in0=0;
localparam   out3_in1=1; 

reg [2:0] out4_in;     //正向依次亮
localparam   out4_in0=0;
localparam   out4_in1=1; 
localparam   out4_in2=2;
localparam   out4_in3=3; 

reg [2:0] out5_in;     //正向依次灭
localparam   out5_in0=0;
localparam   out5_in1=1; 
localparam   out5_in2=2;
localparam   out5_in3=3; 

reg [1:0] out6_in;     //两端向中间
localparam   out6_in0=0;
localparam   out6_in1=1; 
 

reg [2:0] out7_in;     //反向依次亮
localparam   out7_in0=0;
localparam   out7_in1=1; 
localparam   out7_in2=2;
localparam   out7_in3=3; 

reg [4:0] count=0;   //计数

always @(posedge sys_clk or negedge sys_rst_n)
begin
   if(!sys_rst_n)
	  begin
	    out<=0;
		out0_in<=0;
		out1_in<=0;
		out2_in<=0;
		out3_in<=0;
		out4_in<=0;
		out5_in<=0;
		out6_in<=0;
		out7_in<=0;
	  end
	else  
	    case(out)
		    out0://4路同时亮灭
			begin
				if(flag==1 && count==5) 
                begin
					out<=out1;
					count<=0;
				end	
                else if(flag==1) 
		        count<=count+1;						
	            case(out0_in)
			    out0_in0:
                begin
			        led<=4'b1111;
				    if(flag==1)
					    out0_in<=out0_in1;
			        else
				        out0_in<=out0_in0;
			    end
		        out0_in1:
                begin
				    led<=4'b0000;
				    if(flag==1)
					    out0_in<=out0_in0;
				    else
				        out0_in<=out0_in1;
				end
				default: ;
				endcase
			end
			  
			out1://正向每次亮1路
			begin
				if(flag==1&& count==4) 
                begin
					out<=out2;
					count<=0;
			    end	
				else if(flag==1)    
					count<=count+1;
				case(out1_in)
				out1_in0:
                begin
					led<=4'b1000;
					if(flag==1)
					    out1_in<=out1_in1;
					else
						out1_in<=out1_in0;
				end
				out1_in1:      
                begin
				    led<=4'b0100;
			        if(flag==1)
						out1_in<=out1_in2;
				else
					out1_in<=out1_in1;
				end
			    out1_in2:      
                begin
					led<=4'b0010;
					if(flag==1)
					    out1_in<=out1_in3;
					else
						out1_in<=out1_in2;
				end
				out1_in3:      
                begin
					led<=4'b0001;
					if(flag==1)
						out1_in<=out1_in0;
					else
						out1_in<=out1_in3;
				end                 
				default: ;
				endcase	
			end	  
			out2://反向每次亮1路
			begin
				if(flag==1&& count==4) 
                begin
					out<=out3;
					count<=0;
					end	
				else if(flag==1) 
					count<=count+1;
				case(out2_in)
					out2_in0:      
                    begin
						led<=4'b0001;
						if(flag==1)
							out2_in<=out2_in1;
						else
							out2_in<=out2_in0;
					end
					out2_in1 :      
                    begin
						led<=4'b0010;
						if(flag==1)
							out2_in<=out2_in2;
					else
							out2_in<=out2_in1;
					end
			        out2_in2:
                    begin
						led<=4'b0100;
						if(flag==1)
							out2_in<=out2_in3;
						else
							out2_in<=out2_in2;
					end
					out2_in3:      
                        begin
							led<=4'b1000;
							if(flag==1)
						        out2_in<=out2_in0;
				            else
								out2_in<=out2_in3;
						end      
						default: ;
				endcase	
			end
			  
			out3://亮灭相间
		    begin
			    if(flag==1&& count==5)
                begin
					out<=out4;
				    count<=0;
				end	
				else if(flag==1)
					count<=count+1;
				case(out3_in)
					out3_in0:
                    begin
						led<=4'b1010;
						if(flag==1)
							out3_in<=out3_in1;
						else
							out3_in<=out3_in0;
					end
					out3_in1  :     
                    begin
						led<=4'b0101;
					    if(flag==1)
							out3_in<=out3_in0;
						else
							out3_in<=out3_in1;
					end
				    default: ;
			    endcase
			end
			  
			  
			out4://正向依次亮
			begin
				if(flag==1 && count==4)
				begin
					out<=out5;
					count<=0;
				end	
				else if(flag==1) 	   
					count<=count+1;		
					case(out4_in)
					out4_in0 :
					begin
						led<=4'b1000;
						if(flag==1)
							out4_in<=out4_in1;
						else
							out4_in<=out4_in0;
					end
					out4_in1 :
					begin
						led<=4'b1100;
						if(flag==1)
							out4_in<=out4_in2;
						else
							out4_in<=out4_in1;
					end
			          out4_in2:      
					begin
						led<=4'b1110;
						if(flag==1)
							out4_in<=out4_in3;
						else
						    out4_in<=out4_in2;
					end
					out4_in3 :      
					begin
						led<=4'b1111;
						if(flag==1)
							out4_in<=out4_in0;
						else
							out4_in<=out4_in3;
					end          
					default     : ;
			endcase	
			end

			out5://正向依次灭
			begin
				if(flag==1&& count==4) 
				begin
					out<=out6;
					count<=0;
				end	
				else if(flag==1) 			   
					count<=count+1;		
					case(out5_in)
					out5_in0  : 
					begin
						led<=4'b0111;
						if(flag==1)
							out5_in<=out5_in1;
						else
							out5_in<=out5_in0;
					end
					out5_in1   :   
					begin
						led<=4'b0011;
						if(flag==1)
							out5_in<=out5_in2;
						else
							out5_in<=out5_in1;
						end
			        out5_in2   :     
					begin
						led<=4'b0001;
						if(flag==1)
							out5_in<=out5_in3;
						else
							out5_in<=out5_in2;
					end
					out5_in3   :      
					begin
						led<=4'b0000;
						if(flag==1)
							out5_in<=out5_in0;
						else
							out5_in<=out5_in3;
						end
			                     
					default  : ;
				endcase	
			end
			out6: //两端向中间
			begin
				if(flag==1&& count==5) 
				begin
					out<=out7;
					count<=0;
				end	
				else  if (flag==1)
					count<=count+1;
					case(out6_in)
					out6_in0   :     
					begin
						led<=4'b1001;
						if(flag==1)
							out6_in<=out6_in1;
						else
							out6_in<=out6_in0;
					end
					out6_in1   :      
					begin
						led<=4'b0110;
						if(flag==1)
							out6_in<=out6_in0;
						else
							out6_in<=out6_in1;
						end
						default    : ;
					endcase
				end
			  out7://反向依次亮
			       begin
				     if(flag==1&& count==4) 
					 	begin
							out<=out0;
							count<=0;
						end	
					else if(flag==1)
						count<=count+1;							
					case(out7_in)
					out7_in0   :      
					begin
						led<=4'b0001;
						if(flag==1)
							out7_in<=out7_in1;
						else
							out7_in<=out7_in0;
					end
					out7_in1   :      
					begin
						led<=4'b0011;
						if(flag==1)
							out7_in<=out7_in2;
						else
							out7_in<=out7_in1;
					end
			        out7_in2   :      
					begin
						led<=4'b0111;
						if(flag==1)
							out7_in<=out7_in3;
						else
							out7_in<=out7_in2;
					end
					out7_in3   :      
					begin
						led<=4'b1111;
						if(flag==1)
							out7_in<=out7_in0;
						else
							out7_in<=out7_in3;
					end        
					default     : ;
				endcase	
			end
		default      : ;
	endcase		
end
endmodule