function output_package= transmitter_block(sigs, orbit_package, w, scenario);
    global verbose
    signal_transmitted = sigs{1};
    noise_transmitted = sigs{3};
    
    zenith = orbit_package{1};
    distance = orbit_package{2};
    
    %transmitted signal should be normalized to 0-1 range.
    %% System Parameters:
    %Warning: Divergance angle taken as full width of beam. So the
    %triangular angle of the div_angle is half the value reported.
    %Transmitter from OCTL:
    laser_tx_power = 1.6; %Watts
    tx_divergance_angle = 1.5E-3; %1.5mRad 
    
    
    cone_radius = distance*tan(tx_divergance_angle/2);
    
    
    
    output_package = {output_signal, output_noise, w, df};
end

