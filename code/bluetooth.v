module bluetooth(clk,reset,data_rx,flag,data_tx);      
input clk;
input reset;
input data_rx;

output reg flag;
output [7:0] data_tx;
                                    
parameter T = 15'd10414; //����1bit�������ֵ��Ӧ9600������                          

//������Ӧ9600������
reg start;
reg [14:0]cnt;
always @(posedge clk or posedge reset)
begin
   if(reset) 
      cnt <= 15'd0;
   else if(cnt == T) 
      cnt <= 15'd0;
   else if(start) 
      cnt <= cnt + 1'b1;
   else 
      cnt <= 1'b0;
end

//���ɼ����ݵ�ʱ�̷��ڲ����ʼ�����ÿ��ѭ���������м�λ��
wire collect;
assign collect = (cnt ==  15'd5208) ? 1'b1 : 1'b0; 

//�õ����ݱ�����½���
reg	[1:0] down;
always @(posedge clk or	posedge	reset)
begin
    if(reset)	
        down <= 2'b11;
    else	
    begin
        down[0]<=data_rx;
        down[1]<=down[0];
    end
end

//����½���
wire nege_edge;
assign nege_edge= down[1]& ~down[0];

//UARTЭ��
reg	[3:0]num;
reg rx_on;//�����ֽ�ʱ״̬Ϊ1   
always @(posedge clk or posedge reset)
begin
    if(reset)	
    begin	
        start <= 1'b0;	
        rx_on <= 1'b0;
    end
    else if(nege_edge)
    begin
        start <= 1'b1;
        rx_on <= 1'b1;
    end
    else if(num == 4'd10)
    begin
        start <= 1'b0;	
        rx_on <= 1'b0;
    end
end

//������
reg	[7:0]rx_data_temp_r;//��ǰ���ݽ��ռĴ���
reg	[7:0]rx_data_r;//������������
always @(posedge clk or posedge reset)
begin
    if(reset)	
    begin	
        rx_data_r<= 8'd0;
        rx_data_temp_r<= 8'd0;
        num <= 4'd0;
    end
    else if(rx_on) 
    begin
        if(collect) 
        begin
            num <= num + 1'b1;
            case(num)
                4'd1: rx_data_temp_r[0] <= data_rx;
                4'd2: rx_data_temp_r[1] <= data_rx;	
                4'd3: rx_data_temp_r[2] <= data_rx;	
                4'd4: rx_data_temp_r[3] <= data_rx;	
                4'd5: rx_data_temp_r[4] <= data_rx;
                4'd6: rx_data_temp_r[5] <= data_rx;	
                4'd7: rx_data_temp_r[6] <= data_rx;	
                4'd8: rx_data_temp_r[7] <= data_rx;	
                default: ;
            endcase
        end
        else if(num == 4'd10)
        begin
            rx_data_r <= rx_data_temp_r;
            num <= 4'd0;
        end
    end
end

//���ݴ������
assign data_tx = rx_data_r;

//���ܷ�0������flag=1
always @ (*)
begin
   if(data_tx!=8'b0011_0000&&data_tx!=8'b0)
   begin
       flag<=1;
   end
   else
   begin
       flag<=0;
   end
end    

endmodule