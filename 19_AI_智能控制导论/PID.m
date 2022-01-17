%%
%清理屏幕
clc
clear
%%
%设置超参数
Kp=0.03;
Ki=0.002;
Kd=0.002;
tem_obj=100;%目标温度80℃
time_end=5; %观察5s
%%
%设置传递函数
T=1;%惯性系数
K=80;%稳态增益
tao=0.5;%滞后时间
ts=0.005;  %采样时间=0.005s
s=tf('s');
sys=K*exp(-tao*s)/(T*s+1);%传递函数
dsys=c2d(sys,ts,'z');      %离散化
[num,den]=tfdata(dsys,'v'); %求解系数
%%
%初始化
e_before=0;         %前一时刻的误差      
e_sum=0;            %累积偏差
e_now=0;            %现时刻的误差
u_before=0;      %前一时刻的控制量
u_now=0;            %现时刻的控制器输出
time=zeros(1,time_end/ts); %时刻点
y_before=0;          %前一时刻输出为0
y=zeros(1,time_end/ts);     %普通系统输出
r=ones(1,time_end/ts)*tem_obj; %期望输出
%%
%传统PID
for k=1:1:time_end/ts
    time(k)=k*ts;    %时间参数
    y(k)=-1*den(2)*y_before+num(2)*u_before+num(1)*u_now;%系统响应输出序列
    e_now=tem_obj-y(k);   %误差信号
    u_now=Kp*e_before+Ki*e_sum+Kd*(e_now-e_before); %系统PID控制器输出序列
    e_sum=e_sum+e_now;    %误差的累加和
    u_before=u_now;    	%前一个的控制器输出值
    y_before=y(k);    	%前一个的系统响应输出值
    e_before=e_now;		%前一个误差信号的值
end
plot(time,r,'k-.') %指令信号的曲线（即期望输入）
hold on;
plot(time,y,'r');%传统pid
hold on;
xlabel('t/s');
ylabel('tem/℃');
%%
%初始化
e_before=0;         %前一时刻的误差      
e_sum=0;            %累积偏差
e_now=0;            %现时刻的误差
u_before=0;      %前一时刻的控制量
u_now=0;            %现时刻的控制器输出
time=zeros(1,time_end/ts); %时刻点
y_before=0;          %前一时刻输出为0
y=zeros(1,time_end/ts);     %专家系统输出
r=ones(1,time_end/ts)*tem_obj; %期望输出
%%
for k=1:1:time_end/ts
    deta_e=0;
    Kp=0.05;
    Ki=0.002;
    Kd=0.001;
    time(k)=k*ts;    %时间参数
    y(k)=-1*den(2)*y_before+num(2)*u_before+num(1)*u_now;%系统响应输出序列
    e_now=tem_obj-y(k);   %误差信号
    max1=4;
    max2=0.05;
    %规则1
    if(abs(e_now)>=max1)
        Kp=Kp*10;
        Ki=0;
        Kd=Kd/10;
    %规则2
    elseif(abs(e_now)>=max2&&e_now*(e_now-e_before)>=0)
        Kp=Kp*10;
        Ki=Ki;
        Kd=Kd;
    %规则3
    elseif(abs(e_now)<max2&&e_now*(e_now-e_before)>=0)
        Kp=Kp;
        Ki=Ki;
        Kd=Kd;
    %规则4
    elseif(e_now*(e_now-e_before)<0 && deta_e*(e_now-e_before)>0 && abs(e_now)<max2)
        Kp=0.06*Kp;
        Ki=0;
        Kd=0;
    %规则5
    elseif(e_now*(e_now-e_before)<0 && deta_e*(e_now-e_before)<0 && abs(e_now)<max2)
        Kp=3*Kp;
        Ki=0;
        Kd=0;
     %规则6
    elseif(abs(e_now)<0.005)
        Kp=Kp;
        Ki=Ki;
        Kd=0;
    end
    deta_e=e_now-e_before; %记录deta_e
    u_now=Kp*e_before+Ki*e_sum+Kd*(e_now-e_before); %系统PID控制器输出序列
    e_sum=e_sum+e_now;    %误差的累加和
    u_before=u_now;    	%前一个的控制器输出值
    y_before=y(k);    	%前一个的系统响应输出值
    e_before=e_now;		%前一个误差信号的值
end
plot(time,y,'b');%专家pid
hold on;
legend('期望输出','传统PID','专家PID');

