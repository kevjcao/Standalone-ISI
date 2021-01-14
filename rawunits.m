function [unit_raster, units_sorted] = rawunits(num, Sort, ISIcutoff, ISIexport)
%% Function returns array of units from the raw spike array and plots a raster 
% Split raw spikes array into corresponding electrode channels

if ISIexport == 1
    % num(num == 9999) = NaN;                                               % replace all artifact values (e.g., values = 9999) with NaN
    idx = num(:,4) > ISIcutoff;                                             % index all ISI values greater than idx value
    num(idx, 4) = NaN;                                                      % replace all ISI values greater than idx with NaN;
end

[~,~,channels] = unique(num(:,3));                                          % first separate raw num array based on electrode ch from MEA chip
raw_channels = accumarray(channels, 1:size(num,1),[],@(r){num(r,:)});       % generate a cell w/ subcells that contain each channel's unit firing

%% Split electrode channels into unique units (waveforms)
raw_units = [];
ntrials = [];
spike_times = [];

for i = 1:numel(raw_channels)
    [~,~,units] = unique(raw_channels{i,1}(:,2));                           % generate raw_channels array based on unit number from each ch
    raw_units = [raw_units; ...
        accumarray(units, ...
        1:size(raw_channels{i,1}(:,2),1),[],@(r){raw_channels{i,1}(r,:)})]; % generate a cell array with subcells that has each unit's activity
end

%% Sort each unit by descending spike time
units_sorted = cell(numel(raw_units),1);
for m = 1:length(raw_units)
    units_sorted{m} = sortrows(raw_units{m});
end

%% Plot raster of the spike activity for each unit
unit_raster = figure(2);
hold on;
if Sort == 0
    for m = 1:length(units_sorted)
        spike_times = units_sorted{m}(:,1);
        ntrials = ones(size(spike_times,1),1) * m;
        plot(spike_times, ntrials, 'Marker', '.', 'Color', 'k', 'LineStyle', 'none')
    end
else
end
if Sort == 1
    [~,sorted_units] = sort(cellfun(@length, units_sorted), 'descend');
    units_sorted = units_sorted(sorted_units);
    for m = 1:length(units_sorted)
        spike_times = units_sorted{m}(:,1);
        ntrials = ones(size(spike_times,1),1) * m;
        plot(spike_times, ntrials, 'Marker', '.', 'Color', 'k', 'LineStyle', 'none')
    end
else
end

ylim([0 size(units_sorted,1) + 1]);
xlabel('Time (s)');
ylabel('Unit');
set(gca, 'TickDir', 'out');
hold off

fprintf('Number of channels = %d \n', i);
fprintf('Number of units = %d \n\n', m);

end

