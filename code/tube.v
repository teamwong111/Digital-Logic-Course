`timescale 1ns / 1ps
module tube(clk,reset,stop,data,select);
input clk;
input reset;
input stop;

output [7:0] data;//数码管段选数据
output [7:0] select;//数码管位选     

wire [1:0] hour_h;
wire [3:0] hour_l;
wire [2:0] minute_h;
wire [3:0] minute_l;
wire [2:0] second_h;
wire [3:0] second_l;  
               
clock A1(clk,reset,stop,hour_h,hour_l,minute_h,minute_l,second_h,second_l);
                      
display A2(clk,reset,hour_h,hour_l,minute_h,minute_l,second_h,second_l,data,select);      
           
endmodule

module display(clk,reset, hour_h, hour_l, minute_h,minute_l,second_h,second_l,data,select);
input clk;
input reset;
input [1:0] hour_h;
input [3:0] hour_l;
input [2:0] minute_h;
input [3:0] minute_l;
input [2:0] second_h;
input [3:0] second_l;

output [7:0] data;
output [7:0] select;

parameter period= 100000;   

//建立从0-9与数码管的映射关系
reg [6:0] Y_r;
reg [7:0] DIG_r;
reg [7:0] reg_a[9:0];
assign data ={1'b1,(~Y_r[6:0])};
assign select =~DIG_r;   
initial
begin
    reg_a[0] <= 7'b0111111;
    reg_a[1] <= 7'b0000110;
    reg_a[2] <= 7'b1011011;
    reg_a[3] <= 7'b1001111;
    reg_a[4] <= 7'b1100110;
    reg_a[5] <= 7'b1101101;
    reg_a[6] <= 7'b1111101;
    reg_a[7] <= 7'b0100111;
    reg_a[8] <= 7'b1111111;  
    reg_a[9] <= 7'b1100111;
end
 
//分频
reg [31:0]cnt;
reg clkout;    
always @( posedge clk or negedge reset)      
begin 
    if (!reset)
        cnt <= 0 ;
    else  
    begin  
        cnt<= cnt+1; 
        if (cnt == (period >> 1) - 1)               
            clkout <= 1'b1;
        else if (cnt == period - 1)                    
        begin 
            clkout <= 1'b0;
            cnt <= 1'b0;      
        end
    end
end

//数码管每一位扫描
reg [2:0]scan_cnt=0 ;    
always @(posedge clkout or negedge reset)          
begin 
    if (!reset)
        scan_cnt <= 0;
    else  
    begin
        scan_cnt <= scan_cnt + 1;    
        if(scan_cnt==3'd5)  
            scan_cnt <= 0;
    end 
end

//数码管选择
reg [3:0]N1,N2,N3,N4,N5,N6;
always @(scan_cnt)         
begin 
    N1<=second_l;
    N2<=second_h;
    N3<=minute_l;
    N4<=minute_h;
    N5<=hour_l;
    N6<=hour_h;
    case (scan_cnt)
        3'b000 : DIG_r <= 8'b0000_0001;    
        3'b001 : DIG_r <= 8'b0000_0010;    
        3'b010 : DIG_r <= 8'b0000_0100;    
        3'b011 : DIG_r <= 8'b0000_1000;    
        3'b100 : DIG_r <= 8'b0001_0000;    
        3'b101 : DIG_r <= 8'b0010_0000;    
        default :DIG_r <= 8'b0000_0000;    
    endcase
end

//译码
always @ (scan_cnt) 
begin 
    case (scan_cnt)
        3'b000: Y_r = reg_a[N1]; 
        3'b001: Y_r = reg_a[N2];
        3'b010: Y_r = reg_a[N3]; 
        3'b011: Y_r = reg_a[N4]; 
        3'b100: Y_r = reg_a[N5]; 
        3'b101: Y_r = reg_a[N6];
        default: Y_r = 7'b0111111;
    endcase
end

endmodule

module clock(clk, reset,stop,hour_h,hour_l,minute_h,minute_l,second_h,second_l);
input clk; 
input reset;
input stop;

output [1:0]hour_h; 
output [3:0]hour_l;     
output [2:0]minute_h;   
output [3:0]minute_l;   
output [2:0]second_h;
output [3:0]second_l;

parameter  S=100000000;
parameter  M=60;
/*********************************************************/
//1秒计数器
reg [31:0] cnt;
always @(posedge clk or negedge reset)
begin
    if(!reset) 
        cnt <= 15'd0;
    else if((cnt == S)) 
            cnt <= 15'd0;
        else
            cnt <= cnt + 1'b1; 
 end   
            
//开始跑                       
reg [1:0] reg1;
reg [3:0] reg2;
reg [2:0] reg3;
reg [3:0] reg4;
reg [2:0] reg5;
reg [3:0] reg6;
always @(posedge clk or negedge reset or posedge stop)
begin
if (!reset)
begin
    reg1 <= 2'd0;
    reg2 <= 4'd0; 
    reg3 <= 3'd0; 
    reg4 <= 4'd0; 
    reg5 <= 3'd0; 
    reg6 <= 4'd0; 
end
else if(stop)
begin
    reg1 <= reg1;
    reg2 <= reg2;
    reg3 <= reg3;
    reg4 <= reg4;
    reg5 <= reg5;
    reg6 <= reg6;
end
else //时钟正常开始跑  
begin
    if (cnt == S)  //一秒到了
    begin
        reg6 <= reg6 + 1'b1;    
        if (reg6 == 4'd9)        
        begin
            reg6 <= 4'd0;
            reg5 <= reg5 + 1'b1;
            if (reg5 == 3'd5)
            begin
                reg5 <= 3'd0;           
                reg4 <= reg4 + 1'b1;    
                if (reg4 == 4'd9)        
                begin
                    reg4 <= 4'd0;
                    reg3 <= reg3 + 1'b1;
                    if (reg3 == 3'd5)    
                    begin
                        reg3 <= 3'd0;        
                        if (reg1 == 2'd2)    
                        begin
                            reg2 <= reg2 + 1'b1;
                            if (reg2 == 4'd3)
                            begin
                                reg2 <= 4'd0;                
                                reg1 <= 2'd0;                            
                            end
                        end
                        else
                        begin
                            reg2 <= reg2 + 1'b1;
                            if (reg2 == 4'd9)
                            begin
                                reg2 <= 4'd0;
                                reg1 <= reg1 + 1'b1;
                            end
                        end
                    end
                end
            end
        end
    end
end
end  

//赋值给每一位
assign hour_h = reg1;
assign hour_l = reg2;
assign minute_h = reg3;
assign minute_l = reg4;
assign second_h = reg5;
assign second_l = reg6;

endmodule
