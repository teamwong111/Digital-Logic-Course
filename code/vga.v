module vga(clk,reset,hsync,vsync,hc,vc,effect);
input clk;
input reset;

output hsync; 
output vsync; 
output [9:0]hc ,vc;
output effect;

parameter 
hsync_end = 10'd95, 
hdat_begin = 10'd143,
hdat_end = 10'd783,
hpixel_end = 10'd799,
vsync_end = 10'd1,
vdat_begin = 10'd34,
vdat_end = 10'd514,
vline_end = 10'd524;

//分频为25MHz
reg cnt_clk=0;
reg vga_clk=0;
always @(posedge clk)
begin
    if(cnt_clk == 1)
    begin
        vga_clk <= ~vga_clk;
        cnt_clk <= 0;
    end
    else
        cnt_clk <= 1;
end

//vga扫描
reg [12:0] hcount; //行扫描计数器
reg [12:0] vcount; //场扫描计数器
always @(posedge vga_clk)//行扫描
begin
if (hcount==hpixel_end)
    hcount <= 12'd0;
else
    hcount <= hcount + 12'd1;
end

assign hsync=(hcount<=hsync_end)?1'b0:1'b1;

always @(posedge vga_clk)//场扫描
begin
if(vcount==vline_end)
    vcount<=1'b0;
else if(hcount==hpixel_end)
    vcount<=vcount+1;
end

assign vsync=(vcount<=vsync_end)?1'b0:1'b1;

//信号有效
assign effect = ((hcount >= hdat_begin) && (hcount < hdat_end))&& ((vcount >= vdat_begin) && (vcount < vdat_end));

//计数器转成640 x 480
assign hc = hcount - hdat_begin;
assign vc = vcount - vdat_begin;

endmodule

