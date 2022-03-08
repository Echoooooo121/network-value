 function [ Satisfaction,Bandwidth_Enterprise,Bandwidth_Home,Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop ] = IPACT( T,N,Rm,Load )
	%tic�������ʱ�䣬������T
	tic
	%��������
	% T: ����ʱ��
	% N: ONU������
	% Rm: ��ONUû��֡����ʱ��С��ռ�ô���
	Time = 0;
    %Sim_FlagΪ������б�־λ��Ϊ1�����������У�Ϊ0�����
	Sim_Flag = true;
    %ONU֮֡��ı���ʱ϶
	Guard_Time = 5 * 10^-6; %seconds
    %֡ͷ��С
	BWmap_Size = 8*N;
	%����֡�Ĵ�С
	Report_msg_Size = 64; %Bytes
    Frames_delays=[];
	%Event_ListΪ�¼���ÿ����һ��������������¼��������һ���¼�
	Event_List = zeros(5,0);%Event_List��ʼΪ�ա�����һ��5*0�Ŀվ���
	
    %���¼��б��ʼ����OLT���������ÿ��ONU�����ݰ�
    %��һ��Ϊ1���ʾ��ONU�������д���Ϊ2���ʾONU�������ݰ���Ϊ3���ʾONU�ϴ����ݣ�Ϊ4�򱨸��������Ϊ5���������
    %�ڶ��д���ʱ��
    %�����������¼��������ȼ�
    %�����д���ONU_ID��Ϣ
% 	for i=1:N
% 		Event_List(1,end+1) = 1;%end+1������չEvent_List�Ŀռ䡣
% 		Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
% 		Event_List(3,end) = 2;%���ȼ�������ԽС�����ȼ�Խ�ߣ� 
% 		Event_List(4,end) = i;%ONU_ID
% 	end
	
    %ONU���������OLT�����ݰ�
	for i=1:N
		Event_List(1,end+1) = 1;
		Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
		Event_List(3,end) = 2;%���ȼ�
		Event_List(4,end) = i;%ONU_ID
    end
	

    Event_List(1,end+1) = 2;
    Event_List(2,end) = Time + 500*10^-6;
    Event_List(3,end) = 1; %���ȼ�
    Event_List(4,end) = 1; %ONU_ID
        
	%Event 5 end Simulation after T seconds
    %����¼�5���жϷ����Ƿ������TΪ����Ľ�ֹʱ��
	Event_List(1,end+1) = 4;
	Event_List(2,end) = T;
	Event_List(3,end) = 4;
	%��¼ÿ��ONU�Լ�OLT�Ļ�����ֵ
	Buffer_Size = zeros(N+1,1);
	%���Ļ����С
	Max_Buffer_Size = 10*10^3; %Bytes
	%ONU֡������ 
	%��һ��Ϊʱ�䣬�ڶ���Ϊ����С�������б�����ĸ�ONU���������ݰ��������б�Ǹð��Ƿ��Ѿ�������
	ONU_Buffer_Occupancy = zeros(0,4);
	%���ONU�Ƿ������ݰ�Ҫ����
	Bytes_ONU_Asks = zeros(N,1);
	%ONU���ݰ����ͽ�ֹʱ��
	Ending_Times_of_Transmissions = zeros(1,N);
	%����ONU��OLT���������
% 	Distance = zeros(1,N);
% 	for i = 1:N
% 		%Distance(1,i) = randi([1,10],1) * 10^3; %metres
%         Distance(1,i) = 5 * 10^3; %metres
%     end
% 	V_transmit = 3*10^8; %metres/seconds
    %����OLT��ONU������ʱ��
	RTT_2 = zeros(1,N);
	for i = 1:N
		%RTT_2(1,i) = Distance(1,i) / V_transmit;
        RTT_2(1,i) = 100 * 10^(-6);
	end

	%����ͳ����
    %ͳ����������С
	Throughput = 0;
    %ͳ���ܹ�������ֽ���
	Total_Bytes_Sent = 0;
    %ͳ���˷ѵĴ���
	Total_Waiting_Time = 0;
    %ͳ��ƽ��֡ʱ��
	Mean_Frame_Delay = 0;
    %ͳ��ʱ�Ӷ���
    Delay_Jitter = 0;
    %ͳ���ܹ�������֡������
    Total_Frames_Generated = 0;
    %ͳ���ܹ����͵�֡������
	Total_Frames_Sent = 0;
    %ͳ�ƶ�ʧ�İ�������
    Frames_Drop = 0;
    %ͳ��Ϊ��ҵ�û�����Ĵ�������
    Bandwidth_Enterprise = 0;
    %ͳ��Ϊ��ͥ�û�����Ĵ�������
    Bandwidth_Home = 0;
    %ͳ�ƴ���������
    Satisfaction = 0;    

	while Sim_Flag
            
            %Event��ȡ��һ��Ҫ������¼�
			Event = Event_List(1,1);
			Time = Event_List(2,1);   

            %TimeΪ�¼�����ʱ�䣬Event_ListΪ�¼��б�Buffer_SizeΪ����ÿ��ONU��OLT����������С��Max_Buffer_SizeΪ���Ļ�����
            %��һ��Ϊ1���ʾ��ONU�������д���Ϊ2���ʾONU�������ݰ���Ϊ3���ʾONU�ϴ����ݣ�Ϊ4�򱨸��������Ϊ5���������
			if Event == 1
				[ Event_List, Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop ] = Event1 ( Time, Event_List, Buffer_Size, Max_Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop, Load);
			elseif Event == 2
				[ Event_List, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home ] = Event2 ( Time, Event_List, Bytes_ONU_Asks, N, ONU_Buffer_Occupancy, RTT_2, BWmap_Size, Rm, Guard_Time, Report_msg_Size, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home );
			elseif Event == 3
                [ Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays ] = Event3 ( Time, Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays);
			elseif Event == 4
				[ Sim_Flag, Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home, Satisfaction] = Event4 ( Time, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Total_Frames_Generated, Frames_delays, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home );
            end

            %���¼�����󣬽��¼��б�������¼�ȥ��
			Event_List(:,1)=[];%ɾ������ĵ�1��
            %���¼������ȼ���������
			Event_List=(sortrows(Event_List',[2,3]))';
			
	end
end

%Event1: ONU�������ݰ�  
function [ Event_List, Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop ] = Event1 ( Time, Event_List, Buffer_Size, Max_Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop, Load)

    ONU_ID = Event_List(4,1);
%     if (ONU_ID == 1 || ONU_ID == 4 || ONU_ID == 7 || ONU_ID == 10 || ONU_ID == 13)
%         Frame_Size = randi([1000,1518],1);
%     else    
%         Frame_Size = randi([64,800],1);
%     end
    Frame_Size = randi([64,1518],1);
    Total_Frames_Generated = Total_Frames_Generated + 1;
	%sprintf('Event2 at Time %d -//- Ethernet Frame size %d bytes -//- Transmitter ONU %d', Time, Frame_Size, ONU_ID)
    %ONU����������пռ�������ݰ����ȥ
    if (Buffer_Size(ONU_ID,1) + Frame_Size) <= Max_Buffer_Size
        Buffer_Size(ONU_ID,1) = Buffer_Size(ONU_ID,1) + Frame_Size;
        %��һ��Ϊʱ�䣬�ڶ���Ϊ����С�������б�����ĸ�ONU���������ݰ��������б�Ǹð��Ƿ��Ѿ�������
        ONU_Buffer_Occupancy(end+1,1) = Time; 
        ONU_Buffer_Occupancy(end,2) = Frame_Size; 
        ONU_Buffer_Occupancy(end,3) = ONU_ID;
        sprintf('%d bytes are added to %d ONU Buffer_Size',Frame_Size,ONU_ID)
    else
        Frames_Drop = Frames_Drop + 1;
        disp('Maximum buffer Size.Frame dropped!')
    end
    
    %�������¼���ÿ��һ��ʱ��������ݰ�
    Event_List(1,end+1) = 1;
    Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
    Event_List(3,end) = 2;%Second priority 
    Event_List(4,end) = ONU_ID;%ONU_ID
end
%Event2: Ϊÿ��ONU�������
%��ONUû�а�Ҫ����ʱ��������С�Ĵ���Rm 
function [ Event_List, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home ] = Event2 ( Time, Event_List, Bytes_ONU_Asks, N, ONU_Buffer_Occupancy, RTT_2, BWmap_Size, Rm, Guard_Time, Report_msg_Size, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home )

    sprintf('Event3: OLT start Distributing Bandwidth at Time: %d', Time)        
    ONU_ID = Event_List(4,1);
    Bytes_to_Send = 0;
    %���²���ΪONU�������
    Pre_Allot_Bandwidth = 10^6/8;%����ת��Ϊ�ֽڣ�1Mbit?
    Remaining_Bandwidth = Pre_Allot_Bandwidth/N-Guard_Time*10^9/8;%Bytes
    Bandwidth_Distribution = 0;
    %Bytes_ONU_Asks���ONU�Ƿ������ݰ�Ҫ���ͣ�0��û�У�����>0
    if Bytes_ONU_Asks(ONU_ID,1) == 0 
        %Flag_Only_Report��ʾONU�����ݰ�����
        Flag_Only_Report = 1;
        %�����ݰ�����ʱΪ�䷢����С�Ĵ���
        %Bandwidth_Distribution = Rm;
        Bandwidth_Distribution = 0;
        %��������ʣ��������
        %Remaining_Bandwidth = Remaining_Bandwidth - Rm; %Bytes

    else %���ONU�����ݰ�Ҫ����
        Flag_Only_Report = 0;
        %Count Report message size 64Bytes
        Remaining_Bandwidth = Remaining_Bandwidth - Report_msg_Size;
        for frames = 1:size(ONU_Buffer_Occupancy,1)
            %�ڻ��������ҵ�ONU��Ӧ�����ݰ�
             %ONU_Buffer_Occupancy��һ��Ϊʱ�䣬�ڶ���Ϊ����С�������б�����ĸ�ONU���������ݰ��������б�Ǹð��Ƿ��Ѿ�������
            if ONU_Buffer_Occupancy(frames,3) == ONU_ID
                if Bytes_ONU_Asks(ONU_ID,1) > 0
                    %�ж�ʣ������Ƿ���
                    if Bandwidth_Distribution + ONU_Buffer_Occupancy(frames,2) <= Remaining_Bandwidth
                        %����Ĵ�������
                        Bandwidth_Distribution = Bandwidth_Distribution + ONU_Buffer_Occupancy(frames,2);
                        Bytes_ONU_Asks(ONU_ID,1) = Bytes_ONU_Asks(ONU_ID,1) - ONU_Buffer_Occupancy(frames,2);
                        %�����µ�ʣ�����
                        Remaining_Bandwidth = Remaining_Bandwidth - ONU_Buffer_Occupancy(frames,2);
                    else
%                         Bandwidth_Distribution =Bandwidth_Distribution + Rm;
%                         Bytes_ONU_Asks(ONU_ID,1) = Bytes_ONU_Asks(ONU_ID,1) - Rm;
%                         Remaining_Bandwidth = Remaining_Bandwidth - Rm;
                        break;
                    end
                else
                    break;
                end
            end
        end 
    end

    %ONU��ʼ������Ϣ��ʱ��Ϊ:OLT��GRANT֡�������˴���ONU��ʱ�䣬��������֡�ڴ���ʱ���Զ������ӳ�
    start_transmission_time = Time;  
    Ending_Times_of_Transmissions(1,ONU_ID) = start_transmission_time + Bandwidth_Distribution*8/(1*10^9);%10^9��ʾGb/S,���ﰴ�ֽ���

    %��������ONU��Ҫ�ϴ����ݰ���Ҳ����Event3������			
    Event_List(1,end+1) = 3; 
    Event_List(2,end) = start_transmission_time; %seconds
    Event_List(3,end) = 3;%���ȼ�
    Event_List(4,end) = ONU_ID;%ONU_ID 
    
    Event_List(5,end) = Bandwidth_Distribution;
    
    if (ONU_ID == 1 || ONU_ID == 4 || ONU_ID == 7 || ONU_ID == 10 || ONU_ID == 13)
        Bandwidth_Home = Bandwidth_Home + Event_List(5,end);%byte              
    else
        Bandwidth_Enterprise = Bandwidth_Enterprise + Event_List(5,end);%byte
    end
end    
    
    

%Event 3:ONU�ϴ����ݰ�
function [ Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays ] = Event3 ( Time, Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays)
   T = Time;
   ONU_ID = Event_List(4,1);
   total_bytes_to_send = 0;
   Total_Bytes = Event_List(5,1);
   sprintf('Event4: ONU %d read BWmap at Time %d -//- Distribution Bandwidth: %d -//- Start transmission', ONU_ID, Time, Total_Bytes)

   %Frames_Sendedͳ���ϴ��İ�������
   Frames_Sended = zeros(0,1);
   %ONU_Buffer_Occupancy��һ��Ϊʱ�䣬�ڶ���Ϊ����С�������б�����ĸ�ONU���������ݰ��������б�Ǹð��Ƿ��Ѿ�������
   for frames = 1:size(ONU_Buffer_Occupancy,1)
        if ONU_Buffer_Occupancy(frames,3) == ONU_ID
            if Total_Bytes > 0
                %���ݰ�һ��һ���ϴ����ж��Ƿ��Ѿ��ﵽ�������ֵ
                if (total_bytes_to_send + ONU_Buffer_Occupancy(frames,2)) <= Total_Bytes && ONU_Buffer_Occupancy(frames,4) == 0
                    total_bytes_to_send = total_bytes_to_send + ONU_Buffer_Occupancy(frames,2);
                    Frames_Sended(end+1,1) = frames;
					%���ͱ�־λ��1
                    ONU_Buffer_Occupancy(frames,4) = 1;
                    %�������ݰ���ʱ��
                    Frames_delays(end+1) = T - ONU_Buffer_Occupancy(frames,1); 
                    Total_Waiting_Time = Total_Waiting_Time + (T - ONU_Buffer_Occupancy(frames,1));
                    T = T + ONU_Buffer_Occupancy(frames,2) / (10^9);
                    Total_Frames_Sent = Total_Frames_Sent + 1;
                else
                    break;
                end
            else
                break;
            end
       end
   end
   Total_Bytes_Sent = Total_Bytes_Sent + total_bytes_to_send;
   %�ӻ�������ɾ���Ѿ��ϴ������ݰ�
   ONU_Buffer_Occupancy(Frames_Sended,:) = [];
   Buffer_Size(ONU_ID,1) = Buffer_Size(ONU_ID,1) - total_bytes_to_send;
   
   %��ʼ��ONU�����ϴ���־λ
   Bytes_ONU_Asks(ONU_ID,1) = 0;
   %ͳ�ƻ�������ĳONU��Ȼ�����ڵ����ݰ� 
   for frames = 1:size(ONU_Buffer_Occupancy,1)
       if ONU_Buffer_Occupancy(frames,3) == ONU_ID
           Bytes_ONU_Asks(ONU_ID,1) = Bytes_ONU_Asks(ONU_ID,1) + ONU_Buffer_Occupancy(frames,2);
       end
   end
   Event_List(1,end+1) = 2;
   Event_List(2,end) =  max(Ending_Times_of_Transmissions) + 5*10^(-6);
   Event_List(3,end) = 1; %���ȼ�
   if ONU_ID < N
       Event_List(4,end) = ONU_ID+1;
   else
       Event_List(4,end) = 1;
   end
   
end

%Event4: �������
function [ Sim_Flag, Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home, Satisfaction] = Event4 ( Time, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Total_Frames_Generated, Frames_delays, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home )
    sprintf('Simulation end at Sim-Time %d', Time)
    toc
    Sim_Flag = false; 
    Bandwidth_Enterprise = 8* Bandwidth_Enterprise;
    Bandwidth_Home = 8* Bandwidth_Home;
    %�������������
    Satisfaction = Total_Frames_Sent/Total_Frames_Generated;
    %Satisfaction = Total_Frames_Generated-Total_Frames_Sent;
    %����ϵͳ�������� 
    Throughput = (( Total_Bytes_Sent *  8 )/ Time)/10^9; %Gbps
    sprintf('Network Throughput is: %.2f GBps',Throughput)
    %����ƽ��ʱ��
    Mean_Frame_Delay = (Total_Waiting_Time / Total_Frames_Sent);
    sprintf('Mean Frame Delay is: %f seconds',Mean_Frame_Delay) %seconds
    Delay_Jitter = var(Frames_delays)/(Mean_Frame_Delay^2);
    %Delay_Jitter = var(Frames_delays,1);
    Frames_Drop = Frames_Drop / Total_Frames_Generated;
%    sprintf('Delay Jitter is: %d seconds',Delay_Jitter)
    sprintf('Total Frames Generated is: %d',Total_Frames_Generated)
    sprintf('Total Frames Sent is: %d',Total_Frames_Sent)
    sprintf('Total Frames Drop is: %d',Frames_Drop)
end
