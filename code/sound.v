module sound(clk,data_in,up);
input clk;
input data_in;

output up;

//°ëÃë»º³å
reg [31:0]cnt=0;
reg sound;
always @(posedge clk)
begin
    if(data_in==1&&cnt==0)
    begin
        sound=1;
        cnt=cnt+1;
    end
    else if(cnt!=0)
    begin
        cnt=cnt+1;
        sound=0;
        if(cnt==50000000)
        begin
            cnt=0;
        end
    end
    else
    begin
        sound=0;
        cnt=cnt;
    end
end

//ÏòÉÏ
reg up=0;
always @(posedge sound)
    up<=~up;

endmodule