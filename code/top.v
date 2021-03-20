module top(clk,reset,data_rx,data_sound,hsync,vsync,red1,green1,blue1,data_tube,select_tube);
input clk;//ʱ��
input reset;//�������㣨���ã�
input data_rx;//��������
input data_sound;//��������

output hsync; //VGA ��ͬ���ź�
output vsync; //VGA ��ͬ���ź�
output [3:0]red1;
output [3:0]green1;
output [3:0]blue1; 
output [7:0] data_tube;//����ܶ�ѡ����
output [7:0] select_tube;//�����λѡ  

wire effect;//vga�ź���Ч
wire up_key;//��������
wire down_key;//����
wire [9:0]hc,vc;//640 480
wire [7:0] data_tx;//�������
wire flag_bt;//�������ڹ���
wire stop;//��Ϸֹͣ
wire up;//�������

key U1(clk,flag_bt,up,up_key,down_key);//����

game U2(data_tx,clk,flag_bt,effect,hc,vc,up_key,down_key,({red1,green1,blue1}),stop);//��Ϸ

vga U3(clk,flag_bt,hsync,vsync,hc,vc,effect);//��ʾ

bluetooth U4(clk,reset,data_rx,flag_bt,data_tx);//����

tube U5(clk,flag_bt,stop,data_tube,select_tube);//�����

sound U6(clk,data_sound,up);//����

endmodule
