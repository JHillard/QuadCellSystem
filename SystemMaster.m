clear all
close all
%Helpful References:
%http://www.ti.com/lit/an/sboa060/sboa060.pdf
% Walks through the noise calculations of a tia^

%% System Parameters:
recieved_optical_signal = 22E-6;%Opals prediction.
recieved_optical_signal = 1E-6;%Opal's prediction w/ airmass=10;

albedo_irradiance = 1E-6; %Noise levels caused by Earth's irradiance and background light.
albedo_irradiance = 0;

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

%ground_telescope(w); %Handles ground modulation
atmo_sigs = atmo_block(ground_sigs, w);
tia_outputs = tia_block(atmo_sigs, bandwidth, w, df);
tia_sig = tia_outputs{1};
tia_noise = tia_outputs{2};
%signal_processing_block(sigs, w);

%%
%Converts SNR into an angle
SNR = logspace(-5,10,1000);
SNR = get_snr(tia_sig, tia_noise, df);
%mag2db(SNR) %Sanity check component.
%from Theory of tracking accuracy of laser systems. eq 62
spot_size = 0.001; %.2mm
var_x = SNR.^-1.*(1-8./SNR)./(1+8./SNR).^2;
dx = spot_size.^2*var_x %denormalized variance. eq 3b
fc = 0.015 %focal distance assuming simple telescope (it's not)
var_theta_II = asin(dx/fc);

if(verbose ==1)
    'Angle Variance: '
    var_theta_II
end
    %target_theta = 1E-6;
%tg = ones(1,length(SNR))*target_theta;
%figure
%semilogy(mag2db(SNR), var_theta_II);
%title('SNR vs Angular Determination');
%xlabel('SNR (dB)')
%ylabel('Radians')

%'yo?'
