function [isi_histo, isi_3d, ISI_raw] = interspikeinterv(units_sorted, BW_ISI, ISIexport, ISIcutoff)
%% Find ISI values for each unit from the spike times in raw_units
% will find ISI values for each unit, if not already exported from Plexon
% if ISI values were exported as the 4th column, use ISIexport == 1 (see
% below)

if ISIexport == 0
    ISI_raw = cell(numel(units_sorted), 1);

    for m = 1:length(units_sorted)
        ISI_raw{m} = diff(units_sorted{m}(:,1)*1000);
    end
    
    isi_N = cell(numel(ISI_raw), 1);                                        % number of units per BSW_ISI bin
    isi_edges = cell(numel(ISI_raw), 1);                                    % edges of bins 

    for m = 1:length(ISI_raw)                                               % generate a histogram of binsize BW_ISI on ISI data from each unit
        [isi_N{m}, isi_edges{m}] = histcounts(ISI_raw{m}, 'BinWidth', BW_ISI);
    end

    max_ISIcell = max(cellfun(@numel, isi_N));                              % find unit with max number of histogram bins
    padded_ISIcell = cellfun(@(x) [x zeros(1, max_ISIcell - numel(x))], isi_N, 'un', 0);
    padded_ISIs = cell2mat(padded_ISIcell);                                 % pad all other units with zeros to match unit with max bins to conver to matrix

    if ISIcutoff > 0
        padded_ISIs = padded_ISIs(:,1:(ISIcutoff / BW_ISI));
    else
    end
    
    fprintf('ISI times binned at %d ms \n\n', BW_ISI);
    
    %% Create raster of ISI histograms
    isi_histo = figure(6);
    hold on;
    imagesc(padded_ISIs);
    ylabel('Unit');
    ylim([0 m]);
    xlabel('Interspike interval, ms');
    xlim([0 50]);                                                           % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
    xt = get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
    p = colorbar;
    p.Label.String = ('Counts');
    p.Label.FontSize = 11;
    set(gca, 'TickDir', 'out');
    hold off
    
    % Create 3D surf plot of ISIs
    isi_3d = figure(7);
    hold on;
    surf(padded_ISIs, 'FaceColor', 'interp');
    view([25 60]);                                                          % set azimuth and elevation of 3d plot
    ylabel('Unit');
    ax = gca;
    ax.YDir = ('Reverse');
    ylim([0 m]);
    xlabel('Interspike interval, ms');
    zlabel('Counts');
    xlim([0 50]);                                                           % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
    xt = get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
    set(gca, 'TickDir', 'out');
    hold off
end

%% Calculate the interspike intervals (ISIs) for each unit

if ISIexport == 1
    isi_N = cell(numel(units_sorted), 1);                                   % number of units per BSW_ISI bin
    isi_edges = cell(numel(units_sorted), 1);                               % edges of bins 

    for m = 1:length(units_sorted)                                          % generate a histogram of binsize BW_ISI on ISI data from each unit
        [isi_N{m}, isi_edges{m}] = histcounts(units_sorted{m}(:,4), 'BinWidth', BW_ISI);
    end

    max_ISIcell = max(cellfun(@numel, isi_N));                              % find unit with max number of histogram bins
    padded_ISIcell = cellfun(@(x) [x zeros(1, max_ISIcell - numel(x))], isi_N, 'un', 0);
    padded_ISIs = cell2mat(padded_ISIcell);                                 % pad all other units with zeros to match unit with max bins to conver to matrix

    %% Create raster of ISI histograms for each unit

    isi_histo = figure(6);
    hold on;
    ISIraster = imagesc(padded_ISIs);

    ylabel('Unit');
    xlabel('Interspike interval, ms');
    xlim([0 20]);                                                           % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
    xt = get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
    colorbar;
    set(gca, 'TickDir', 'out');
    hold off

    isi_3d = figure(7);
    hold on;
    ISI3d = surf(padded_ISIs);

    ylabel('Unit');
    xlabel('Interspike interval, ms');
    zlabel('Counts');
    xlim([0 20]);                                                           % x-axis limit, scale by BW_ISI (multiply by BW_ISI for time, in ms)
    xt = get(gca, 'XTick');
    set(gca, 'XTick', xt, 'XTickLabel', xt*BW_ISI);
    set(gca, 'TickDir', 'out');
    hold off
end
end