%%
%This program calculates the maximum Hertzian stress for a given stress field.
%The equations are based on Barber (2018) Contact Mechanics
%(c) Derek Leung 2020
%Submitted as a supplementary material for MScR GeoSciences
%a>b

%Input 
a = 0.0094615;%semi-major axis of contact
b = 0.0056725;%semi-minor axis of contact

%a = 0.016425/2;%minimum collisional scenario
%b = 0.00707/2;%minimum collisional scenario


R = 0.13934; %Radius of curling stone
B = (1/R+1/R)/2 %Curvature of curling stone (inverse of radius)
v = 0.2; %Poisson's ratio
E = 39e9 %Young's modulus
Estar = 1/((1-v^2)/E + (1-v^2)/E) %Equivalent Young's modulus

e = sqrt(1-b^2/a^2) %Eccentricity

%syms theta
%fun = @(theta) 1/sqrt(1-e*e*cos(theta)*cos(theta))
%Ke = integral(fun , 0, pi/2)
[Ke,Ee] = ellipke(e^2)

%B = 1/(Ke-Ee)*(Ee/(1-e^2)-Ke)*A
A = B*(Ke-Ee)/(Ee/(1-e^2)-Ke)
RA = 1/A

po = A*Estar*a^2*e^2/((Ke-Ee)*b)
pob = B*Estar*a^2*e^2/((Ee/(1-e^2)-Ke)*b) %alternative method, double-check that the math is right
delta = po*b*Ke/Estar

pm = po*2/3


%%%
%%% Hertz impact of spheres

%m = 18.415;
%M = 1/(1/m + 1/m)
%Requiv = 1/(1/R + 1/R)
%V = 2.8; % speed in m/s
%eq 20.11
%pmax = Estar/pi*(30*M*V^2/(Estar*Requiv^3))^(1/5) 

%eq 20.15 total contact time
%tc = 2.868*(M^2/(Estar^2*V*Requiv))^(1/5)

%% some code to check that it should be ellipke(e^2) (ex. from p. 38)
%[Kee,Eee] = ellipke(0.60^2)
%anotherA = ((3*20*(Kee-Eee))/(2*pi*0.60^2*115.4*10^9*50))^(1/3)


%% plots the stress distribution at surface

[X,Y] = meshgrid(-a:0.001:a,-a:0.001:a);
Z = real(po*sqrt(1-X.^2/a^2 -Y.^2/b^2));
surf(X,Y,Z)