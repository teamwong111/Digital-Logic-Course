module key(clk,reset,up,up_key,down_key);
input clk;
input reset;
input up;  

output reg up_key;
output reg down_key;

parameter T = 30'd1000_000;  //控制方块在y方向速度

//向上或者向下
reg [30:0] count1;
reg [30:0] count2;
always@(posedge clk or negedge reset)
begin
    if(!reset)
    begin
        count1 <= 0;
        count2 <= 0;
        up_key <= 0;
        down_key <= 0;
    end
    else
    begin
        if(up)
        begin
            if(count1 <= T)
            begin
                count1 = count1 + 1'b1;
                up_key <= 0;
            end
            else
            begin
                count1 <= 0;
                up_key <= 1;
            end
        end
        else  //下降
        begin
            if(count2 <= T)
            begin
                count2 = count2 +  1'b1;
                down_key <= 0;
            end
            else
            begin
                count2 <= 0;
                down_key <= 1;
            end
        end
    end
end

endmodule

