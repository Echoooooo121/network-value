 function [ Satisfaction,Bandwidth_Enterprise,Bandwidth_Home,Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop ] = IPACT( T,N,Rm,Load )
	%tic用来检测时间，不超出T
	tic
	%参数含义
	% T: 仿真时间
	% N: ONU的数量
	% Rm: 当ONU没有帧发送时最小的占用带宽
	Time = 0;
    %Sim_Flag为仿真进行标志位，为1则仿真持续进行，为0则结束
	Sim_Flag = true;
    %ONU帧之间的保护时隙
	Guard_Time = 5 * 10^-6; %seconds
    %帧头大小
	BWmap_Size = 8*N;
	%报告帧的大小
	Report_msg_Size = 64; %Bytes
    Frames_delays=[];
	%Event_List为事件表，每处理一个带宽请求就向事件表里添加一个事件
	Event_List = zeros(5,0);%Event_List初始为空。创建一个5*0的空矩阵
	
    %将事件列表初始化，OLT产生传输给每个ONU的数据包
    %第一行为1则表示给ONU分配上行带宽，为2则表示ONU产生数据包，为3则表示ONU上传数据，为4则报告带宽请求，为5则结束上行
    %第二行储存时间
    %第三行设置事件处理优先级
    %第四行储存ONU_ID信息
% 	for i=1:N
% 		Event_List(1,end+1) = 1;%end+1用来扩展Event_List的空间。
% 		Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
% 		Event_List(3,end) = 2;%优先级（数字越小，优先级越高） 
% 		Event_List(4,end) = i;%ONU_ID
% 	end
	
    %ONU产生传输给OLT的数据包
	for i=1:N
		Event_List(1,end+1) = 1;
		Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
		Event_List(3,end) = 2;%优先级
		Event_List(4,end) = i;%ONU_ID
    end
	

    Event_List(1,end+1) = 2;
    Event_List(2,end) = Time + 500*10^-6;
    Event_List(3,end) = 1; %优先级
    Event_List(4,end) = 1; %ONU_ID
        
	%Event 5 end Simulation after T seconds
    %添加事件5来判断仿真是否结束，T为仿真的截止时间
	Event_List(1,end+1) = 4;
	Event_List(2,end) = T;
	Event_List(3,end) = 4;
	%记录每个ONU以及OLT的缓存总值
	Buffer_Size = zeros(N+1,1);
	%最大的缓存大小
	Max_Buffer_Size = 10*10^3; %Bytes
	%ONU帧储存器 
	%第一行为时间，第二行为包大小，第三行标记是哪个ONU产生的数据包，第四行标记该包是否已经被传送
	ONU_Buffer_Occupancy = zeros(0,4);
	%标记ONU是否有数据包要发送
	Bytes_ONU_Asks = zeros(N,1);
	%ONU数据包传送截止时间
	Ending_Times_of_Transmissions = zeros(1,N);
	%产生ONU到OLT的随机距离
% 	Distance = zeros(1,N);
% 	for i = 1:N
% 		%Distance(1,i) = randi([1,10],1) * 10^3; %metres
%         Distance(1,i) = 5 * 10^3; %metres
%     end
% 	V_transmit = 3*10^8; %metres/seconds
    %计算OLT到ONU的往返时间
	RTT_2 = zeros(1,N);
	for i = 1:N
		%RTT_2(1,i) = Distance(1,i) / V_transmit;
        RTT_2(1,i) = 100 * 10^(-6);
	end

	%各个统计量
    %统计吞吐量大小
	Throughput = 0;
    %统计总共传输的字节数
	Total_Bytes_Sent = 0;
    %统计浪费的带宽
	Total_Waiting_Time = 0;
    %统计平均帧时延
	Mean_Frame_Delay = 0;
    %统计时延抖动
    Delay_Jitter = 0;
    %统计总共产生的帧的数量
    Total_Frames_Generated = 0;
    %统计总共发送的帧的数量
	Total_Frames_Sent = 0;
    %统计丢失的包的数量
    Frames_Drop = 0;
    %统计为企业用户分配的带宽总量
    Bandwidth_Enterprise = 0;
    %统计为家庭用户分配的带宽总量
    Bandwidth_Home = 0;
    %统计带宽满足率
    Satisfaction = 0;    

	while Sim_Flag
            
            %Event提取第一个要处理的事件
			Event = Event_List(1,1);
			Time = Event_List(2,1);   

            %Time为事件发生时间，Event_List为事件列表，Buffer_Size为储存每个ONU和OLT的数据量大小，Max_Buffer_Size为最大的缓存量
            %第一行为1则表示给ONU分配上行带宽，为2则表示ONU产生数据包，为3则表示ONU上传数据，为4则报告带宽请求，为5则结束上行
			if Event == 1
				[ Event_List, Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop ] = Event1 ( Time, Event_List, Buffer_Size, Max_Buffer_Size, ONU_Buffer_Occupancy, Total_Frames_Generated, Frames_Drop, Load);
			elseif Event == 2
				[ Event_List, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home ] = Event2 ( Time, Event_List, Bytes_ONU_Asks, N, ONU_Buffer_Occupancy, RTT_2, BWmap_Size, Rm, Guard_Time, Report_msg_Size, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home );
			elseif Event == 3
                [ Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays ] = Event3 ( Time, Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays);
			elseif Event == 4
				[ Sim_Flag, Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home, Satisfaction] = Event4 ( Time, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Total_Frames_Generated, Frames_delays, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home );
            end

            %当事件处理后，将事件列表里这个事件去掉
			Event_List(:,1)=[];%删除矩阵的第1列
            %对事件的优先级进行排序
			Event_List=(sortrows(Event_List',[2,3]))';
			
	end
end

%Event1: ONU产生数据包  
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
    %ONU缓存器如果有空间则把数据包存进去
    if (Buffer_Size(ONU_ID,1) + Frame_Size) <= Max_Buffer_Size
        Buffer_Size(ONU_ID,1) = Buffer_Size(ONU_ID,1) + Frame_Size;
        %第一列为时间，第二列为包大小，第三列标记是哪个ONU产生的数据包，第四列标记该包是否已经被传送
        ONU_Buffer_Occupancy(end+1,1) = Time; 
        ONU_Buffer_Occupancy(end,2) = Frame_Size; 
        ONU_Buffer_Occupancy(end,3) = ONU_ID;
        sprintf('%d bytes are added to %d ONU Buffer_Size',Frame_Size,ONU_ID)
    else
        Frames_Drop = Frames_Drop + 1;
        disp('Maximum buffer Size.Frame dropped!')
    end
    
    %产生新事件，每过一段时间产生数据包
    Event_List(1,end+1) = 1;
    Event_List(2,end) = Time + poissrnd(10,1,1) * 10^-5/Load; %seconds
    Event_List(3,end) = 2;%Second priority 
    Event_List(4,end) = ONU_ID;%ONU_ID
end
%Event2: 为每个ONU分配带宽
%当ONU没有包要传送时，分配最小的带宽Rm 
function [ Event_List, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home ] = Event2 ( Time, Event_List, Bytes_ONU_Asks, N, ONU_Buffer_Occupancy, RTT_2, BWmap_Size, Rm, Guard_Time, Report_msg_Size, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Bandwidth_Enterprise, Bandwidth_Home )

    sprintf('Event3: OLT start Distributing Bandwidth at Time: %d', Time)        
    ONU_ID = Event_List(4,1);
    Bytes_to_Send = 0;
    %以下部分为ONU分配带宽
    Pre_Allot_Bandwidth = 10^6/8;%比特转化为字节？1Mbit?
    Remaining_Bandwidth = Pre_Allot_Bandwidth/N-Guard_Time*10^9/8;%Bytes
    Bandwidth_Distribution = 0;
    %Bytes_ONU_Asks标记ONU是否有数据包要发送，0则没有，否则>0
    if Bytes_ONU_Asks(ONU_ID,1) == 0 
        %Flag_Only_Report表示ONU无数据包发送
        Flag_Only_Report = 1;
        %无数据包发送时为其发送最小的带宽
        %Bandwidth_Distribution = Rm;
        Bandwidth_Distribution = 0;
        %分配带宽后，剩余带宽减少
        %Remaining_Bandwidth = Remaining_Bandwidth - Rm; %Bytes

    else %如果ONU有数据包要发送
        Flag_Only_Report = 0;
        %Count Report message size 64Bytes
        Remaining_Bandwidth = Remaining_Bandwidth - Report_msg_Size;
        for frames = 1:size(ONU_Buffer_Occupancy,1)
            %在缓存器里找到ONU对应的数据包
             %ONU_Buffer_Occupancy第一列为时间，第二列为包大小，第三列标记是哪个ONU产生的数据包，第四列标记该包是否已经被传送
            if ONU_Buffer_Occupancy(frames,3) == ONU_ID
                if Bytes_ONU_Asks(ONU_ID,1) > 0
                    %判断剩余带宽是否够用
                    if Bandwidth_Distribution + ONU_Buffer_Occupancy(frames,2) <= Remaining_Bandwidth
                        %分配的带宽增加
                        Bandwidth_Distribution = Bandwidth_Distribution + ONU_Buffer_Occupancy(frames,2);
                        Bytes_ONU_Asks(ONU_ID,1) = Bytes_ONU_Asks(ONU_ID,1) - ONU_Buffer_Occupancy(frames,2);
                        %计算新的剩余带宽
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

    %ONU开始传输信息的时间为:OLT的GRANT帧经过光纤传到ONU的时间，当有其他帧在传输时，自动往后延迟
    start_transmission_time = Time;  
    Ending_Times_of_Transmissions(1,ONU_ID) = start_transmission_time + Bandwidth_Distribution*8/(1*10^9);%10^9表示Gb/S,这里按字节算

    %分配带宽后，ONU需要上传数据包，也就是Event3的任务			
    Event_List(1,end+1) = 3; 
    Event_List(2,end) = start_transmission_time; %seconds
    Event_List(3,end) = 3;%优先级
    Event_List(4,end) = ONU_ID;%ONU_ID 
    
    Event_List(5,end) = Bandwidth_Distribution;
    
    if (ONU_ID == 1 || ONU_ID == 4 || ONU_ID == 7 || ONU_ID == 10 || ONU_ID == 13)
        Bandwidth_Home = Bandwidth_Home + Event_List(5,end);%byte              
    else
        Bandwidth_Enterprise = Bandwidth_Enterprise + Event_List(5,end);%byte
    end
end    
    
    

%Event 3:ONU上传数据包
function [ Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays ] = Event3 ( Time, Event_List, ONU_Buffer_Occupancy, Bytes_ONU_Asks, N, Ending_Times_of_Transmissions, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Buffer_Size, Frames_delays)
   T = Time;
   ONU_ID = Event_List(4,1);
   total_bytes_to_send = 0;
   Total_Bytes = Event_List(5,1);
   sprintf('Event4: ONU %d read BWmap at Time %d -//- Distribution Bandwidth: %d -//- Start transmission', ONU_ID, Time, Total_Bytes)

   %Frames_Sended统计上传的包的数量
   Frames_Sended = zeros(0,1);
   %ONU_Buffer_Occupancy第一列为时间，第二列为包大小，第三列标记是哪个ONU产生的数据包，第四列标记该包是否已经被传送
   for frames = 1:size(ONU_Buffer_Occupancy,1)
        if ONU_Buffer_Occupancy(frames,3) == ONU_ID
            if Total_Bytes > 0
                %数据包一个一个上传，判断是否已经达到带宽分配值
                if (total_bytes_to_send + ONU_Buffer_Occupancy(frames,2)) <= Total_Bytes && ONU_Buffer_Occupancy(frames,4) == 0
                    total_bytes_to_send = total_bytes_to_send + ONU_Buffer_Occupancy(frames,2);
                    Frames_Sended(end+1,1) = frames;
					%传送标志位置1
                    ONU_Buffer_Occupancy(frames,4) = 1;
                    %计算数据包的时延
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
   %从缓存器中删除已经上传的数据包
   ONU_Buffer_Occupancy(Frames_Sended,:) = [];
   Buffer_Size(ONU_ID,1) = Buffer_Size(ONU_ID,1) - total_bytes_to_send;
   
   %初始化ONU请求上传标志位
   Bytes_ONU_Asks(ONU_ID,1) = 0;
   %统计缓存器中某ONU仍然还存在的数据包 
   for frames = 1:size(ONU_Buffer_Occupancy,1)
       if ONU_Buffer_Occupancy(frames,3) == ONU_ID
           Bytes_ONU_Asks(ONU_ID,1) = Bytes_ONU_Asks(ONU_ID,1) + ONU_Buffer_Occupancy(frames,2);
       end
   end
   Event_List(1,end+1) = 2;
   Event_List(2,end) =  max(Ending_Times_of_Transmissions) + 5*10^(-6);
   Event_List(3,end) = 1; %优先级
   if ONU_ID < N
       Event_List(4,end) = ONU_ID+1;
   else
       Event_List(4,end) = 1;
   end
   
end

%Event4: 仿真结束
function [ Sim_Flag, Throughput, Mean_Frame_Delay,Delay_Jitter, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home, Satisfaction] = Event4 ( Time, Total_Bytes_Sent, Total_Waiting_Time, Total_Frames_Sent, Total_Frames_Generated, Frames_delays, Frames_Drop, Bandwidth_Enterprise, Bandwidth_Home )
    sprintf('Simulation end at Sim-Time %d', Time)
    toc
    Sim_Flag = false; 
    Bandwidth_Enterprise = 8* Bandwidth_Enterprise;
    Bandwidth_Home = 8* Bandwidth_Home;
    %计算带宽满足率
    Satisfaction = Total_Frames_Sent/Total_Frames_Generated;
    %Satisfaction = Total_Frames_Generated-Total_Frames_Sent;
    %计算系统的吞吐量 
    Throughput = (( Total_Bytes_Sent *  8 )/ Time)/10^9; %Gbps
    sprintf('Network Throughput is: %.2f GBps',Throughput)
    %计算平均时延
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
