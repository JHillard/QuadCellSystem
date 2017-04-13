clear all
close all
%Helpful References:
%http://www.ti.com/lit/an/sboa060/sboa060.pdf
% Walks through the noise calculations of a tia^

%% System Parameters:
OPTICAL_POWER = 0.005/(pi*0.005.^2);
T = 273 %Kelvin



R2 = 1E7; %1M
R1 = 1E8;
C1 = 25E-12; %PHOTODIODE_CAPACITANCE
C2 = 1E-12;

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
f_log_h= 8
f_log_l= -1
a = logspace(f_log_l, f_log_h, 1000);
%a =linspace(f_log_l, f_log_h, 1000)

%a = np.linspace(df, frequencies)
w = a;

%%
%Load component values
opspecs = opa111(w);
    photspecs = bpw34();

    OPAMP_3DB_OPENLOOP = opspecs{1};
    OPAMP_DC_GAIN = opspecs{2};
    OPAMP_VNOISE = opspecs{3};
    OPAMP_INOISE = opspecs{4};
    OPAMP_OPENLOOPGAIN = opspecs{5};
    PHOTODIODE_RESPONSIVITY = photspecs{1};
    PHOTODIODE_CAPACITANCE = photspecs{2};

    I_DC = PHOTODIODE_RESPONSIVITY*OPTICAL_POWER;

%%
%Amplifer Voltage Noise
    A = OPAMP_OPENLOOPGAIN; % Open loop gain
    j = (-1)^.5;
    C1S = 1*w.*C1;
    C2S = 1*w.*C2;
    inv_B = 1 + R2.*(R1.*C1S+1)./(R1.*(R2.*C2S+1));
    B=1./inv_B;
    AB = A.*B; % loop gain
    en = OPAMP_VNOISE;
    eo = en.*(A./(1+AB));
    noise_tf = inv_B.*(1./(1+inv_B./A));
    %noise_tf = (A./(1+AB));
    v_noise = en.* noise_tf;
    %THE NOISE WILL LOOK WEIRD IF YOU PLOT IT. 
    %REMEMBER, PLOT IT AS log10(v_noise*1E9) TO PLOT
    %IN nV. The nV is important for non-weird scaling.

    get_rms(v_noise,df)
%%
%Misc Figures for sanity
    figure
    hold on
    plot(log10(w),mag2db(AB));
    plot(log10(w),mag2db(inv_B));
    plot(log10(w),mag2db(noise_tf));
    plot(log10(w),mag2db(A));
    plot(log10(w),mag2db(B));
    plot(log10(w),mag2db(en*1E9));
    plot(log10(w),mag2db(en.*noise_tf.*1E9));
    
    %plot(log10(w),mag2db(inv_B));
    
    
    title('Voltage Noise Transfer Functions');
    xlabel('10^x Hz');
    ylabel('db Gain');
    legend('AB','1/B','V_noise TF','A','B','en','final_noise');
  
    
    %%
    figure
    hold on
    plot(log10(w),mag2db(en*1E9));
    plot(log10(w),mag2db(noise_tf),'.');
    plot(log10(w),mag2db(v_noise*1E9));
    
    title('Voltage Noise Transfer Functions');
    xlabel('10^x Hz');
    ylabel('db Gain');
    legend('en','tf');

%%
%Input Current Noise
%warning, these are functions of frequency. Must have some w defined.
    c = 1.60217662E-19; %TODO, HOW to actually do shot noise. This is an educated guess.
    SHOT = 2.*c.*I_DC;
    K = 1.38E-23 %Boltzmann's
    RES = 4*K*T*R2;%Resistor Noise
    i_n =  (OPAMP_INOISE.^2 + SHOT.^2 + RES.^2).^2;
    Z2 = (R2.^-1 + (1./(w.*C2)).^-1).^-1;
    i_noise = i_n .* Z2;
        %%
        figure
        hold on
        plot(log10(w),mag2db(OPAMP_INOISE*w));
        plot(log10(w),mag2db(Z2));
        title('Current Noise Transfer Functions');
        xlabel('10^x Hz');
        ylabel('db Gain');
        legend('opamp inoise','Transfer Function');