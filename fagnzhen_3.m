%仿真三：对经济效益价值的仿真
clear all
close all

m=[1,2,3,4,5,6,7,8,9];
%n=[144,128,110,95,80,60,45,32,15];
n=(144:-15:15);
Y=[1:1:10];
P=zeros(10,9);
RMAX=zeros(10,9);
RMIN=zeros(10,9);
CMIN=zeros(10,9);
CMAX=zeros(10,9);
for i=1:9
    for j=1:10
        R=Y(j)*(m(i)*100*27+(250-25*m(i))*100*1.2);
        C=19830+Y(j)*(1200+m(i)*55+(250-25*m(i))*7.5)+Y(j)*(Y(j)-1)*150/2;
        P(j,i)=R-C;
        RMAX(j,i)=Y(j)*30000;
        RMIN(j,i)=Y(j)*27000;
        CMIN(j,i)=19830+Y(j)*1750+Y(j)*(Y(j)-1)*150/2;
        CMAX(j,i)=19830+Y(j)*3075+Y(j)*(Y(j)-1)*150/2;
    end
end
PMAX=RMAX-CMIN;
VE=P./PMAX;


    