%% Standalone ISI analysis (from main MEA code) - 2021-Jan-12, KJC
%% Notes
% 1. This code requires sorted spike data from Plexon saved in an excel
% format delineated as: 'SpikeTimes', 'Unit no.', 'channels. no.'; in that order. 

% 2. It will generate a new array named 'raw_units' with each unit's firing
% activity listed as a single Nx3 or Nx4 array where N is the no. of events. The
% rasters are created from just the first column of each unit's array (e.g.
% the spike times).

%% Workspace clear
tic
clear;
close all;

%% Conditions
% Analysis duration
Duration = 1;                                                               % 1 = analysis performed for a segment of the recording
spike_start = 00;                                                           % in seconds
spike_end = 120;                                                            % in seconds

% Conditions for frequency analysis
BW = 0.1;                                                                   % bin width for histogram of raw unsorted spike data

% Plots and graphs
Histoplot = 1;                                                              % set 0 (no histogram) or 1 (histogram)
Sort = 0;                                                                   % if 1 = sort units, if 0 = no sorting

% Parameters for ISI analysis
ISI = 1;                                                                    % 1 = run analysis for ISIs, requires 4th column in raw Plexon export with ISIs
BW_ISI = 5;                                                                 % bin width for ISI histograms, in ms
ISIcutoff = 200;                                                            % max ISI threshold, in ms

%% Import raw sorted spike data from Plexon 

[FileName, FilePath] = uigetfile( ...
       {'*.xlsx','New Excel (*.xlsx)'; ...
       '*.xls','Old Excel (*.xls)';
       '*.txt', 'Text file (*.txt)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on');
File = fullfile(FilePath, FileName);
[num, txt, raw] = xlsread(File);

fprintf('%s \n\n', FileName);                                               % Display file name / experiment details

clearvars txt FilePath FileName

%% Sets start and end times for analysis

if Duration == 1
    num = num(num(:,1)>=spike_start & num(:,1)<=spike_end, :);
    raw = cellfun(@(z) z(z(:,1)>=spike_start & z(:,1)<=spike_end, :), raw, 'UniformOutput', false);
    
    fprintf('Record analyzed from %d to %ds \n\n', spike_start, spike_end);
end

if Duration == 0
    fprintf('Full record analyzed \n\n');
end

%% Bin raw spike data into 100ms slices

fprintf('Bin size = %d ms \n', BW * 1000)

spike_timeHist = cell2mat(raw(:,1));
[N, EDGES] = histcounts(spike_timeHist, 'BinWidth', BW);                    % N is the counts for each bin; EDGES are the bin edges

if Histoplot == 1
    hold on;
    histogram_plot = figure(1);
    HistoSpikes = histogram(spike_timeHist, 'BinWidth', BW);
    xlabel('Time (s)');
    ylabel('Number of spikes');
    set(gca, 'TickDir', 'out');
    hold off
else 
    fprintf('No histogram plotted\n\n');
end

clearvars spike_timeHist spike_start spike_end

%% Arrange raw spike data into units and generate raster plot of unit activity

[raw_units, unit_raster] = rawunits(num, Sort, ISI, ISIcutoff);

clearvars num

%% Plot normalized firing frequency of recording

[freq_plot] = freqplot(N, BW, EDGES, raw_units);

clearvars N BW EDGES

%% Analyze ISI for each unit

if ISI == 1
    [units_isi, isi_histo] = interspikeinterv(raw_units, BW_ISI);
end
toc
