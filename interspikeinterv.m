function [isi_histo, isi_3d] = interspikeinterv(raw_units, BW_ISI)
%% Calculate the interspike intervals (ISIs) for each unit

isi_N = cell(numel(raw_units), 1);                                          % number of units per BSW_ISI bin
isi_edges = cell(numel(raw_units), 1);                                      % edges of bins 

for m = 1:length(raw_units)                                                 % generate a histogram of binsize BW_ISI on ISI data from each unit
    [isi_N{m}, isi_edges{m}] = histcounts(raw_units{m}(:,4), 'BinWidth', BW_ISI);
end

max_ISIcell = max(cellfun(@numel, isi_N));                                  % find unit with max number of histogram bins
padded_ISIcell = cellfun(@(x) [x zeros(1, max_ISIcell - numel(x))], isi_N, 'un', 0);
padded_ISIs = cell2mat(padded_ISIcell);                                     % pad all other units with zeros to match unit with max bins to conver to matrix

%% Create raster of ISI histograms for each unit

isi_histo = figure(4);
hold on;
ISIraster = imagesc(padded_ISIs);

ylabel('Unit');
xlabel('Interspike interval, ms');
xlim([0 20]);                                                               % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
colorbar;
set(gca, 'TickDir', 'out');
hold off

isi_3d = figure(5);             
hold on;
ISI3d = surf(padded_ISIs);

ylabel('Unit');
xlabel('Interspike interval, ms');
zlabel('Counts');
xlim([0 20]);                                                               % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
xt = get(gca, 'XTick');
set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
set(gca, 'TickDir', 'out');
set(gca, 'Ydir', 'reverse');
hold off


end