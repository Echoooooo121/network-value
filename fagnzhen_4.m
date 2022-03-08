%仿真四：整体网络价值，VSAFE取所有负载下的平均值；VQOS取负载为0.9时的值
VSAFE=[0.979319585	0.974158702;%s=1,rc=1
       0.873195662	0.867701713;%s=1,rc=0.8
       0.783455668	0.779326961;%s=0.8,rc=1
       0.697917156	0.694603459];%s=0.8,rc=0.8
VQOS=[0.74217842 0.725828034;0.769887964 0.75571763;0.797597508	0.785607225;0.825307052	0.81549682;0.853016596	0.845386416];%ONUE为1,3，5,7,9时负载为0,9时的值
VE1=[0.822743468	0.802850356	0.782957245	0.763064133	0.743171021	0.72327791	0.703384798	0.683491686	0.663598575;
0.918263965	0.909090909	0.899917853	0.890744797	0.881571742	0.872398686	0.86322563	0.854052574	0.844879518;
0.930549093	0.92275477	0.914960447	0.907166124	0.899371801	0.891577478	0.883783155	0.875988832	0.868194509;
0.93529858	0.928037282	0.920775984	0.913514685	0.906253387	0.898992088	0.89173079	0.884469492	0.877208193;
0.937771014	0.930787191	0.923803369	0.916819546	0.909835724	0.902851901	0.895868079	0.888884256	0.881900434;
0.939255189	0.932437932	0.925620676	0.918803419	0.911986162	0.905168905	0.898351648	0.891534392	0.884717135;
0.940221434	0.933512617	0.926803799	0.920094982	0.913386165	0.906677347	0.89996853	0.893259713	0.886550895;
0.940882309	0.934247661	0.927613012	0.920978363	0.914343714	0.907709066	0.901074417	0.894439768	0.88780512;
0.941347917	0.934765523	0.928183128	0.921600734	0.915018339	0.908435944	0.90185355	0.895271155	0.888688761;
0.941680994	0.93513598	0.928590966	0.922045952	0.915500938	0.908955924	0.90241091	0.895865896	0.889320882
];
%VE = [0.985422291	0.971040877	0.956851664	0.942850677	0.929034056	0.91539805	0.90193901	0.888653393	0.875537751];
%VE=[0.984085358	0.970527097	0.958660147	0.948053695	0.938416224	0.929543298	0.921287191	0.91353841	0.906213998];
%VE=[0.993695227287056,0.987461601153533,0.981297924069572,0.975203025230922,0.969175759817521,0.963215008276623,0.957319675629535,0.951488690801043,0.945721005970689];
%VE=[0.987390455	0.974923202	0.962595848	0.95040605	0.93835152	0.926430017	0.914639351	0.902977382	0.891442012];%第十年
%VE=[0.985422291	0.971040877	0.956851664	0.942850677	0.929034056	0.91539805	0.90193901	0.888653393	0.875537751];%第2年到第10年平均
%VE=[0.960213396	0.926317742	0.896650368	0.870134237	0.846040561	0.823858245	0.803217977	0.783846025	0.765534996];%第1年到第10年平均
%VE=[0.924801396	0.916362022	0.907922648	0.899483274	0.891043899	0.882604525	0.874165151	0.865725776	0.857286402];%
V = zeros(9,2);
for i=1:2
    for j = 1:10
        V(j,i) = 0.4934*VSAFE(4,i)+0.3108*VQOS(2,i)+0.1958*VE1(j,3);
    end
end