%% Trimming regressors to match number of volumes of BOLD fMRI scan file.

%% CHECKING LENGTHS OF TASK PARADIGMS
clc;clear;
%Upon every iteration, change lines 6-8!
participant = 'sub-02';
scan = 'TASK2';
volume_length = 365;    %of the SPC NIFTI file (the desired length of the task paradigm)

% bin_regr = load('C:/Users/Joshua/Documents/Research/IEEE_Paper/scans/sub-02/sub-02_TASK1_Force_bin_HRFconv.txt');
% nonbin_regr = load('C:/Users/Joshua/Documents/Research/IEEE_Paper/scans/sub-02/sub-02_TASK1_Force_Nonbin_HRFconv.txt');

directory = ['C:/Users/Joshua/Documents/Research/IEEE_Paper/scans/' participant '/'];
cd(directory)

bin_file = [directory participant '_' scan '_Force_bin_HRFconv.txt'];
bin_force = load(bin_file);
Nonbin_file = [directory participant '_' scan '_Force_Nonbin_HRFconv.txt'];
Nonbin_force = load(Nonbin_file);

figure(1)
plot(bin_force)
hold on
plot(Nonbin_force)

length(bin_force)
length(Nonbin_force)

% low_file = [directory participant '_' scan '_Force_low_HRFconv.txt'];
% low_force = load(low_file);
% medium_file = [directory participant '_' scan '_Force_medium_HRFconv.txt'];
% medium_force = load(medium_file);
% high_file = [directory participant '_' scan '_Force_high_HRFconv.txt'];
% high_force = load(high_file);
% 
% figure(1)
% plot(low_force)
% hold on
% plot(medium_force)
% hold on
% plot(high_force)
% 
% figure(2)
% subplot(3,1,1)
% plot(low_force)
% subplot(3,1,2)
% plot(medium_force)
% subplot(3,1,3)
% plot(high_force)
% 
% length(low_force)
% length(medium_force)
% length(high_force)


%% REMOVING VOLUMES
Nonbin_force = Nonbin_force(1,[1:volume_length])
low_force = low_force(1,[1:volume_length])
medium_force = medium_force(1,[1:volume_length])
high_force = high_force(1,[1:volume_length])

Nonbin_force = Nonbin_force';
low_force = low_force';
medium_force = medium_force';
high_force = high_force';

Nonbin_force_new_filepath = ['J:/ANVIL/NettaData/task_regressors/' participant '/' scan '/' participant '_' scan '_Force_Nonbin_HRFconv.txt']
writematrix(Nonbin_force, Nonbin_force_new_filepath);
low_new_filepath = ['J:/ANVIL/NettaData/task_regressors/' participant '/' scan '/' participant '_' scan '_Force_low_HRFconv.txt']
writematrix(low_force, low_new_filepath);
medium_new_filepath = ['J:/ANVIL/NettaData/task_regressors/' participant '/' scan '/' participant '_' scan '_Force_medium_HRFconv.txt']
writematrix(medium_force, medium_new_filepath);
high_new_filepath = ['J:/ANVIL/NettaData/task_regressors/' participant '/' scan '/' participant '_' scan '_Force_high_HRFconv.txt']
writematrix(high_force, high_new_filepath);

%Plot after having changed length -- make sure looks the same as pre-trim
figure(1)
plot(low_force)
hold on
plot(medium_force)
hold on
plot(high_force)

figure(2)
subplot(3,1,1)
plot(low_force)
subplot(3,1,2)
plot(medium_force)
subplot(3,1,3)
plot(high_force)

length(low_force)
length(medium_force)
length(high_force)


%% ADDING VOLUMES
for ii = [length(bin_force):volume_length]
    bin_force(1,ii) = bin_force(1,end)
end

figure()
plot(bin_force)
length(bin_force)
bin_force = bin_force';

bin_force_new_filepath = ['J:/ANVIL/NettaData/task_regressors/' participant '/' scan '/' participant '_' scan '_Force_bin_HRFconv.txt']
writematrix(bin_force, bin_force_new_filepath);

length(bin_force)




