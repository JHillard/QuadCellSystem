
function output_package= link_block(sigs, orbit_package)
    global verbose
    signal_tx = sigs{1};
    noise_tx = sigs{2};
    
    zenith_ang = orbit_package{1}/180*pi; %Converts to radians
    distance = orbit_package{2}*1000; %convert km to meters
    
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
    atmo_signal = geometeric_signal.*db2mag(attenuation);
    if(verbose)
        'Atmospheric Attenuation'
        attenuation
    end
    %output_package = {geometeric_signal, output_noise};
end


