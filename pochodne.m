close all
clear
clc

syms Z_Tc Z_Td Z_I Z_P Z_fm
syms E_Tc E_Td E_I E_P E_fm f_p
syms F V C_Iin y_sp F_I R M_m C_min T
syms x1 x2 x3 x4 u y

% P_0 = sqrt((2 * f_p * x2 * Z_I * exp(-E_I/(R*T)))/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T))));
			

dx1 = -(Z_P * exp(-E_P / (R*T)) + Z_fm * exp(-E_fm / (R*T))) * x1 * sqrt((2 * f_p * x2 * Z_I * exp(-E_I/(R*T)))/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T)))) ...
	- (F * x1) / V + (F * C_min) / V;

dx2 = -(Z_I * exp(-E_I / (R*T)) * x2) - (F * x2) / V + (u * C_Iin) / V;
			
dx3 = (0.5 * Z_Tc * exp(-E_Tc / (R*T)) + Z_Td * exp(-E_Td / (R*T))) * (2 * f_p * x2 * Z_I * exp(-E_I/(R*T)))/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T))) ...
				+ Z_fm * exp(-E_fm / (R*T)) * x1 * sqrt((2 * f_p * x2 * Z_I * exp(-E_I/(R*T)))/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T)))) - (F * x3) / V;
			
dx4 = M_m * (Z_P * exp(-E_P / (R*T)) + Z_fm * exp(-E_fm / (R*T))) * x1 * sqrt((2 * f_p * x2 * Z_I * exp(-E_I/(R*T)))/(Z_Td * exp(-E_Td/(R*T)) + Z_Tc * exp(-E_Tc/(R*T)))) ...
				- (F * x4) / V;
y = x4/x3;

%Wyliczamy pochodne cz¹stkowe
% disp('dx1 po x1');
% dx1dx1=diff(dx1,x1) 
% disp('dx1 po x2');
% dx1dx2=diff(dx1,x2) 
% disp('dx1 po x3');
% dx1dx3=diff(dx1,x3) 
% disp('dx1 po x4');
% dx1dx4=diff(dx1,x4) 
% disp('dx1 po u');
% dx1du=diff(dx1,u) 


% disp('dx2 po x1');
% dx1dx1=diff(dx2,x1) 
% disp('dx2 po x2');
% dx1dx2=diff(dx2,x2) 
% disp('dx2 po x3');
% dx1dx3=diff(dx2,x3) 
% disp('dx2 po x4');
% dx1dx4=diff(dx2,x4) 
% disp('dx2 po u');
% dx1du=diff(dx2,u) 

% disp('dx3 po x1');
% dx1dx1=diff(dx3,x1) 
% disp('dx3 po x2');
% dx1dx2=diff(dx3,x2) 
% disp('dx3 po x3');
% dx1dx3=diff(dx3,x3) 
% disp('dx3 po x4');
% dx1dx4=diff(dx3,x4) 
% disp('dx3 po u');
% dx1du=diff(dx3,u) 

disp('dx4 po x1');
dx1dx1=diff(dx4,x1) 
disp('dx4 po x2');
dx1dx2=diff(dx4,x2) 
disp('dx4 po x3');
dx1dx3=diff(dx4,x3) 
disp('dx4 po x4');
dx1dx4=diff(dx4,x4) 
disp('dx4 po u');
dx1du=diff(dx4,u) 

% disp('y po x1');
% dx1dx1=diff(y,x1) 
% disp('y po x2');
% dx1dx2=diff(y,x2) 
% disp('y po x3');
% dx1dx3=diff(y,x3) 
% disp('y po x4');
% dx1dx4=diff(y,x4) 
% disp('y po u');
% dx1du=diff(y,u) 