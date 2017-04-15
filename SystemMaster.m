clear all
close all
%Helpful References:
%http://www.ti.com/lit/an/sboa060/sboa060.pdf
% Walks through the noise calculations of a tia^

%% System Parameters:
recieved_optical_signal = 22E-6;%Opals prediction.
recieved_optical_signal = 1E-6;%Opal's prediction w/ airmass=10;

albedo_irradiance = 1E-6; %Noise levels caused by Earth's irradiance and background light.
    %Todo; Fix. Totally made up number;
optical_noise = 1E-12; %Laser noise. Atmo-noise. Anything the link budget says we've got.
    %Todo; Fix. Also totally made up
global verbose;
verbose = 1;

F_high = 10E6;
F_low = 2;

F_high = 100;
F_low = 0.01;

F_high = 15900;
F_low = 673;

samples = 100000;
df = ((F_high-F_low)/samples);


df = round(F_high)-round(F_low);
df = df/samples;
a = linspace(F_low, F_high, samples);

%Log exploration:
f_log_h= 8;
f_log_l= -1;
a = logspace(f_log_l, f_log_h, 1000);
%a =linspace(f_log_l, f_log_h, 1000)

%a = np.linspace(df, frequencies)
w = a;
bandwidth = F_high-F_low;

ai = albedo_irradiance.*ones(length(w),1)'; 
on = optical_noise.*ones(length(w),1)';
sigs = { recieved_optical_signal, ai, on };


tia_block(sigs, bandwidth, w, df);
%'yo?'
