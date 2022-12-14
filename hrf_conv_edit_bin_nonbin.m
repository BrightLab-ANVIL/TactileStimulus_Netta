clc;
clear;

%% Triggers are not evenly spaced vs. the Time_s column?

% Change lines 8 and 9 upon every iteration!

participant = 'sub-03';
scan = 'TASK1';
directory = ['C:/Users/Joshua/Documents/Research/IEEE_Paper/scans/' participant '/'];

cd(directory)

%filepath = 'C:/Users/Joshua/Documents/Research/IEEE_Paper/scans/sub-04/sub-04_scan1.xlsx';
file = [directory participant '_' scan '.xlsx']
T = readtable([file]);
time_s = T{:,1};
time_s = time_s - time_s(1);
Force = T{:,3};
MRISignal = T{:,2};     % Get the trigger info


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read in Data

%% Create binary stimulus files

% Upsample binary stim file to full scan length
sf = 100; % sampling frequency

% WHAT WAS THE SAMPLING FREQUENCY?

% Create R and L grip stimuli on order of seconds
scan_length = time_s(end) - time_s(1);
Force_ups = zeros(round(scan_length*sf),1); % Preallocate RG

for ii = 1:length(time_s)
    if Force(ii) ~= 0
        Force_ups_bin(time_s(ii)*sf:time_s(ii)*sf+(1*sf)) = 1; % binary: the stimuli is on
    end
    if Force(ii) ~= 0
        Force_ups(time_s(ii)*sf:time_s(ii)*sf+(1*sf)) = Force(ii); % nonbinary: the stimuli is on
    end
end

subplot(2,1,1)
plot(Force_ups_bin)
subplot(2,1,2)
plot(Force_ups)


%% Convolution (HiRes)
% HRF Information
fs = 100;
t = 0:1/fs:25;
HRF = exp(-t) .* ((0.00833333 .* t .^ 5) - (1.27e-13 .* t .^ 15)) ;

% Convolve signals
force_bin_conv = conv(Force_ups_bin,HRF);
force_conv = conv(Force_ups,HRF);

% Demean
force_bin_conv_dm = force_bin_conv - mean(force_bin_conv);
force_conv_dm = force_conv - mean(force_conv);

% Rescale to -0.5 and 0.5
FORCE_BIN = rescale(force_bin_conv_dm,-0.5,0.5);
FORCE = rescale(force_conv_dm,-0.5,0.5);

subplot(2,1,1)
plot(FORCE_BIN)
subplot(2,1,2)
plot(FORCE)


%% Downsample to trigger resolution

TR = 1.5;

counter = 1;
for ii = 1:length(FORCE_BIN)
    if mod(ii,TR*sf) == 0   % assuming TR is 1.5, and had upsampled up 100 times...
        FORCE_BIN_ds(counter) = FORCE_BIN(ii); % binary: the stimuli is on
        counter = counter + 1;
    end
end

counter2 = 1;
for ii = 1:length(FORCE)
    if mod(ii,150) == 0
        FORCE_ds(counter2) = FORCE(ii); % binary: the stimuli is on
        counter2 = counter2 + 1;
    end
end

%% Write data to txt files
cd(directory)
writematrix(FORCE_BIN_ds,[num2str(participant) '_' scan '_Force_bin_HRFconv.txt']);
writematrix(FORCE_ds,[num2str(participant) '_' scan '_Force_Nonbin_HRFconv.txt']);

%% PLOT
t = tiledlayout(4,1);
nexttile
plot(FORCE_BIN_ds)
title('FORCE BIN ds')
nexttile
plot(FORCE_ds)
title('FORCE ds')
nexttile
plot(FORCE_BIN)
title('FORCE BIN ups')
nexttile
plot(FORCE)
title('FORCE ups')





