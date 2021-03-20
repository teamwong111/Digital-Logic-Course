module top(clk,reset,data_rx,data_sound,hsync,vsync,red1,green1,blue1,data_tube,select_tube);
input clk;//时钟
input reset;//蓝牙清零（无用）
input data_rx;//蓝牙输入
input data_sound;//声音输入

output hsync; //VGA 行同步信号
output vsync; //VGA 场同步信号
output [3:0]red1;
output [3:0]green1;
output [3:0]blue1; 
output [7:0] data_tube;//数码管段选数据
output [7:0] select_tube;//数码管位选  

wire effect;//vga信号有效
wire up_key;//按键向上
wire down_key;//向下
wire [9:0]hc,vc;//640 480
wire [7:0] data_tx;//蓝牙输出
wire flag_bt;//蓝牙正在工作
wire stop;//游戏停止
wire up;//声音输出

key U1(clk,flag_bt,up,up_key,down_key);//按键

game U2(data_tx,clk,flag_bt,effect,hc,vc,up_key,down_key,({red1,green1,blue1}),stop);//游戏

vga U3(clk,flag_bt,hsync,vsync,hc,vc,effect);//显示

bluetooth U4(clk,reset,data_rx,flag_bt,data_tx);//蓝牙

tube U5(clk,flag_bt,stop,data_tube,select_tube);//数码管

sound U6(clk,data_sound,up);//声音

endmodule
