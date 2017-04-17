sigs= {ones(100,1)', zeros(1,100)};
orbit_package = {0,430};

a = linspace(1,5.5);
global verbose
verbose = 0
figure
hold on
axis([0 6 -15 0]);
plot(a, desert_ext_model(a));
plot(a, rural_5km_cloudy_model(a));
plot(a, rural_23km_cloudy_model(a));
plot(a, rural_23km_NC_model(a));


