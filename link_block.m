
function output_package= link_block(sigs, orbit_package, pointing_package)
    %Simulates effect of first half of link. Includes laser transmitter, to
    %pointing, to atmospheric effects. Outputs a
    %time-domain attenuated signal for irradiance at aperture, noise signal,
    %and subsequent power levels. 
    
    %signals are all assumed to be time-domain signals. Inputs should be 
    %normalized. WARNING: THIS IS IN CONFLICT WITH TIA_BLOCK, WHICH ASSUMES
    %FREQUENCY DOMAIN SIGNALS. PROPER CONVERTION IS NECASSARY IN
    %SYSTEMMASTER.

    %Several times in this simulation an OPALS paper is mentioned. It is
    %universally the "Optical Payload for Lasercomm Science (OPALS) Link
    %Validation During Operations from the ISS" paper.
    
    global verbose
    global best_case
    time = sigs{1}; %seconds
    signal_tx = sigs{2}; %unitless amplitude.
    noise_tx = sigs{3}; %unitless amplitude.

    signal_power = sigs{4};
    noise_power = sigs{5};
    
    
    
    zenith_ang = orbit_package{1}/180*pi; %Converts to radians
    distance = orbit_package{2}*1000; %convert km to meters
    
    %Neither of these have been implemented yet.
    %Requires better propogation with gaussian beam and better
    %understanding of optics. Get jitter from Hammati and gaussian from 
    %the lecture slides?
    point_err = pointing_package{1}; 
    jitter = pointing_package{2};
 
    %transmitted signal should be normalized to 0-1 range.
    %% System Parameters:
    %Warning: Divergance angle taken as full width of beam. So the
    %triangular angle of the div_angle is half the value reported.
    %Transmitter from OCTL:
    laser_tx_power = 1.6; %Watts
    tx_divergance_angle = 1.5E-3; %1.5mRad 
    
    laser_tx_power = 9.25;
    
    %Geometeric Decay Of Laser
    cone_radius = distance*tan(tx_divergance_angle/2);
    spot_size = pi*cone_radius.^2/laser_tx_power;
    ideal_power_at_satellite = laser_tx_power./spot_size
    geometeric_signal = ideal_power_at_satellite.*signal_tx;
    %Weirdly, getting different answers for ideal transmission
    
    %Atmosphereic Transfer Function for Laser
    %This should be simulated with MODTRAN, a $1500 yearly piece of
    %software. I've interpolated the attenuation graph from OPALS "Optical
    %Payload for Lasercom..." Fig 2.b.
    air_mass = 1./( cos(zenith_ang) + 0.50572.*(6.07995 + 90-zenith_ang).^-1.6364);
    %^Uses Kasten and Young Model to calculate air_mass. See Opals Paper
    %eq(1). section 2.1
    attenuation = rural_23km_cloudy_model(air_mass);
    %Rural_20km fit Opal's mission the best. 
    atmo_variance = 0.3; %Taken from Opals paper
    if(best_case)
        attenuation = desert_ext_model(air_mass);
        atmo_variance = 1E-2;
    end
    atmo_signal = geometeric_signal.*db2mag(attenuation); %signal after
    %atmospheric atetenuation.
    level =  mean(atmo_signal); 
    variance = level*atmo_variance; %b/c the number from OPALS was normalized.
    atmo_noise = variance.^.5*randn(length(atmo_signal),1);    
    %Todo: should 'level' be rms or mean? Did Opals Normalize variance to
    %signal mean or signal power? Signal mean seems more culturally common.
    %based off equation found under 'alternative definition':
    %https://en.wikipedia.org/wiki/Signal-to-noise_ratio
  
    %Best case, it's 1E-2
    %worst case, it's 0.3 of the range.
    
    
    %%Pointing
    %
    pointed_signal = atmo_signal; %Perfect pointing.
    %TODO: Not implemented yet
    
    %%
    %Putting it all together
    total_signal = pointed_signal;
    total_noise = atmo_noise + atmo_bg_noise;
    %Todo: Add pointing noise.
    
    total_signal_level = rms(total_signal);
    total_noise_level = (rms(atmo_noise).^2 + rms(atmo_bg_noise).^2).^0.5;
    
    
    if(verbose)
        figure;
        hold on;
        t = linspace(1,100);
        o = ones(length(t),1)';
        plot(t, mag2db(o.*rms(geometeric_signal)));
        plot(t, mag2db(o.*rms(atmo_signal)));
        plot(t, mag2db(o.*rms(atmo_atmo_noise + atmo_background)));
        plot(t, mag2db(o.*rms(atmo_atmo_noise))); 
        plot(t, mag2db(o.*rms(atmo_background)));
        
        title('Atmospheric Effects');
        legend('Signal After Propogation Loss', 'Signal After Atmospheric Loss', 'Total Atmo-Noise',...
            'Atmospheric Scintillation', 'Atmospheric Background Irradiance');
    end
    output_package = {time, total_signal , total_noise, total_signal_level, total_noise_level};
end


