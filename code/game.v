module game(data_tx,clk,reset,dat_act,hc,vc,up_key_press,down_key_press,disp_RGB,stop);  
input [7:0]data_tx;
input clk;
input reset;
input dat_act;
input [9:0]hc,vc;
input up_key_press;
input down_key_press;

output [11:0]disp_RGB;   
output reg stop;

//ȡ��������ĺ�4λ
wire [4:0]tx;
assign tx=data_tx[3:0];        
     
//��Ƶ25MHz
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
        cnt_clk <= cnt_clk +1;
end

//��ʼ����
reg [18:0] addr = 0;
wire [11:0] rom_data;
reg [11:0]disp;

//ip�˵���
big_rom me(.clka(cnt_clk), .addra(addr), .douta(rom_data));

//��ʾͼƬ
always @ (posedge cnt_clk)
begin
    if (dat_act == 1)
    begin
        if (vc < 360 && vc > 120 && hc < 480 && hc > 160)
        begin                 
            addr <= (vc-120-1) * 320 + (hc-160) - 1;//ͨ��vc��hc�������ַ����ȡͼƬ��Ӧλ��RGB
            disp[11:8] <= rom_data[11:8];
            disp[7:4] <= rom_data[7:4];
            disp[3:0] <= rom_data[3:0];
        end
        else
        begin
            disp[11:8] <= 4'b1111;
            disp[7:4] <= 4'b1111;
            disp[3:0] <= 4'b1111;
        end
    end
    else
    begin
        disp[11:8] <= 0;
        disp[7:4] <= 0;
        disp[3:0] <= 0;
    end
end

//��������
reg [18:0] addr_over = 0;
wire [11:0] rom_data_over;
reg [11:0]disp_over;
//ip�˵���
rom_over you(.clka(cnt_clk), .addra(addr_over), .douta(rom_data_over));

//��ʾͼƬ
always @ (posedge cnt_clk)
begin
    if (dat_act == 1)
    begin
        if (vc < 360 && vc > 120 && hc < 480 && hc > 160)
        begin            
            addr_over <= (vc-120-1) * 320 + (hc-160) - 1;//ͨ��vc��hc�������ַ����ȡͼƬ��Ӧλ��RGB     
            disp_over[11:8] <= rom_data_over[11:8];
            disp_over[7:4] <= rom_data_over[7:4];
            disp_over[3:0] <= rom_data_over[3:0];
        end
        else
        begin
            disp_over[11:8] <= 4'b1111;
            disp_over[7:4] <= 4'b1111;
            disp_over[3:0] <= 4'b1111;
        end
    end
    else
    begin
        disp_over[11:8] <= 0;
        disp_over[7:4] <= 0;
        disp_over[3:0] <= 0;
    end
end

//��������
reg [18:0] addr_bird = 0;
wire [11:0] rom_data_bird;
reg [11:0]data;
//ip�˵���
bird they(.clka(cnt_clk), .addra(addr_bird), .douta(rom_data_bird));

parameter border = 40;//����������С��ı߳�
parameter ban = 20;//���嵲��Ŀ��
parameter long = 200;//���嵲��ĳ���
parameter magin = 160;//���嵲��ļ��
reg [10:0] push,push1,push2,push3;//VGAɨ�裬��������ͷ��飬�����õ����ƶ����ƶ�����push
parameter move_x = 50; //����ĳ�ʼλ��
    
//�����
reg [7:0] rand_num;
parameter seed = 8'b1111_1111;
always@(posedge clk or negedge reset)
begin
    if(!reset)
        rand_num <= seed;
    else
    begin
        rand_num[0] <= rand_num[1] ;
        rand_num[1] <= rand_num[2] + rand_num[7];
        rand_num[2] <= rand_num[3] + rand_num[7];
        rand_num[3] <= rand_num[4] ;
        rand_num[4] <= rand_num[5] + rand_num[7];
        rand_num[5] <= rand_num[6] + rand_num[7];
        rand_num[6] <= rand_num[7] ;
        rand_num[7] <= rand_num[0] + rand_num[7];     
    end
end

//�����
wire [2:0]choose;
reg [8:0]type1;
assign choose = {rand_num[3],rand_num[6],rand_num[2]};

//�����
always@(posedge clk )
begin
    case(choose) 
        0:type1 = 0;
        1:type1 = 40;
        2:type1 = 80;
        3:type1 = 120;
        4:type1 = 160;
        5:type1 = 200;
        6:type1 = 240;
        7:type1 = 280;
        default: type1 = 280;
    endcase
end

//����ƶ��ٶȿ���
reg move;
reg [32:0]counter;
reg [30:0]T_move;
always@(posedge clk or negedge reset)
begin
if(!reset)
begin
    T_move = 30'd10_000_00;
    counter <= 0;
    move <=0;
end
else
begin
    if(counter >= T_move)
    begin
        move = 1;
        if(T_move == 30'd100_000)
            T_move <=T_move;
        else
            T_move = T_move-10;
        counter = 0;
    end
    else 
    begin
        move = 0;
        if(!stop)
            counter= counter + 1;
        else
            counter = 0;
    end
end
end

//���λ��
reg [8:0] rand0,rand1,rand2,rand3;
always@(posedge clk or negedge reset)
begin
if (!reset)
begin
    push<=640;  //��ʼλ���趨
    push1 <= 640+ magin;
    push2 <= 640 + magin + magin;
    push3 <= 640 + magin + magin + magin;
end
else if (move)
begin
    if(push == 0)
    begin
        push <= 640;
        rand0 <=type1; //��һ����ӵ�λ���趨
    end
    else
    begin                        
        push <= push-tx;                                     
    end
    if(push1 == 0)
    begin
        push1 <= 640;
        rand1 <=type1; //�ڶ�����ӵ�λ���趨
    end
    else
    begin                        
        push1 <= push1-tx;                                     
    end
    if(push2 == 0)
    begin
         push2 <= 640;
         rand2 <=type1; //��������ӵ�λ���趨
    end
    else
    begin                        
        push2<= push2-tx;                                     
    end
    if(push3 == 0)
    begin
         push3 <= 640;
         rand3 <=type1;//���Ŀ���ӵ�λ���趨       
    end
    else
    begin                        
        push3 <= push3-tx;                                     
    end        
end
else
begin
    push <= push;
    push1 <= push1;
    push2 <= push2;
    push3 <= push3;
end
end

//��Ϸʧ�ܶ��壬�����뵲��"��ײ" �������Ŀ鵲�壬�������
reg [9:0]move_y;     
wire die1,die2,die3,die4;
assign die1=((rand0<move_y + border)&&(move_y < rand0+long)&&(push < move_x+border) && (move_x < push + ban ));
assign die2=((rand1<move_y + border)&&(move_y < rand1+long)&&(push1 < move_x+border) && (move_x < push1 + ban ));
assign die3=((rand2<move_y + border)&&(move_y < rand2+long)&&(push2 < move_x+border) && (move_x < push2 + ban ));
assign die4=((rand3<move_y + border)&&(move_y < rand3+long)&&(push3 < move_x+border) && (move_x < push3 + ban ));

//��Ϸʧ��
wire false;
assign false = die1||die2||die3||die4;

//�����ƶ�����
always@(posedge clk or negedge reset)
begin
    if (!reset)
    begin
        move_y <= 240;
    end
    else if(stop)
    begin
        move_y<=move_y;
    end
    else if (up_key_press)
    begin
        if(move_y == 0)
        begin
            move_y <= move_y;
        end
        else
        begin                        
            move_y <= move_y-1'b1;                                          
        end
    end
    else if (down_key_press)
    begin
        if(move_y>440)
        begin
            move_y <= move_y;
        end
        else
        begin    
            move_y <= move_y+1'b1;    
        end
    end
else
    move_y<=move_y; 
end

//�����˶���"��ͼ"

always@(posedge vga_clk or negedge reset)
begin
if(!reset)
begin 
    data <= 0;
    stop <= 0;
end
else 
begin 
    if (hc>move_x &&(hc<(move_x+border)&&(vc>move_y)&&(vc<move_y+border))) //С����
    begin
        if(!false)
        begin
            addr_bird <= (vc-move_y-1) * 40 + (hc-move_x) - 1;//ͨ��vc��hc�������ַ����ȡͼƬ��Ӧλ��RGB      
            data[11:8] <= rom_data_bird[11:8];
            data[7:4] <= rom_data_bird[7:4];
            data[3:0] <= rom_data_bird[3:0];
        end
        else
        begin
            data <= 12'b1111_0000_0000; //��ɫ
            stop <=1;
        end
    end   
    else if ((hc>push) && (hc<=push+ban) && (vc>=rand0) && (vc<=rand0+long))
    begin
        data <= 12'b0000_0000_1111;  //��һ������
    end      
    else if ((hc>push1) && (hc<=push1+ban) && (vc>=rand1) && (vc<=rand1+long))
    begin
        data <= 12'b0000_0000_1111;  //�ڶ�������
    end 
    else if ((hc>push2) && (hc<=push2+ban) && (vc>=rand2) && (vc<=rand2+long))
    begin
        data <= 12'b0000_0000_1111;   //����������
    end 
    else if ((hc>push3) && (hc<=push3+ban) && (vc>=rand3) && (vc<=rand3+long))
    begin
        data <= 12'b0000_0000_1111;   //���ĸ�����
    end                                                       
else
    data <= 12'b1111_1111_1111;
end
end

//RGB��ʾѡ��
assign disp_RGB = reset ? (stop ? disp_over :(dat_act ? data:12'b000000000000)): disp;

endmodule

