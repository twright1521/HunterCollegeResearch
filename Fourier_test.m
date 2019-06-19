%% Fourier Transforms Test

% Finds the fourier transform of the 10-yr running mean 
% Does this for a single set of data

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

clearvars

%% Inputs
    

yr_array = (0:1500)./1000;        % Time vector

S = 0.7*sin(2*pi*50*yr_array) + sin(2*pi*120*yr_array);
perc_50_array = S + 2*randn(size(yr_array));

%% Program Start

% Calculate Fourier Transform
F = fft(perc_50_array);
L = length(yr_array);

P2 = abs(F/L);
P1 = P2(1:floor(L/2+1));
P1(2:end-1) = 2*P1(2:end-1);
f = (0:L/2)/L;

% Peaks and Max
[pks,locs] = findpeaks(abs(P1));
[val,idx] = max(abs(P1));
[~,idx2] = max(pks);

if ~isempty(idx2)
    b = sqrt(1/f(locs(idx2)));
else
    b = 0;
end

% Combined Peaks
if ~isempty(pks)
    comb_pks_pos_pos = 0;
    comb_pks_pos_neg = 0;
    comb_pks_neg_pos = 0;
    comb_pks_neg_neg = 0;

    for zeta = 1:length(locs)
        comb_pks_pos_pos = comb_pks_pos_pos + pks(zeta)*sin(2*pi*f(locs(zeta))*(yr_array + b));  
        comb_pks_pos_neg = comb_pks_pos_neg + pks(zeta)*sin(2*pi*f(locs(zeta))*(yr_array - b));
        comb_pks_neg_pos = comb_pks_neg_pos + pks(zeta)*sin(-2*pi*f(locs(zeta))*(yr_array + b));
        comb_pks_neg_neg = comb_pks_neg_neg + pks(zeta)*sin(-2*pi*f(locs(zeta))*(yr_array - b));
    end

    if f(idx) == 0
        comb_pks_pos_pos = comb_pks_pos_pos + val;
        comb_pks_pos_neg = comb_pks_pos_neg + val;
        comb_pks_neg_pos = comb_pks_neg_pos + val;
        comb_pks_neg_neg = comb_pks_neg_neg + val;
    end
end

% Max Peak
if ~isempty(idx2)
    if f(idx) == 0
        max_pk_pos_pos = pks(idx2)*sin(2*pi*f(locs(idx2))*(yr_array + b)) + val;
        max_pk_pos_neg = pks(idx2)*sin(2*pi*f(locs(idx2))*(yr_array - b)) + val;
        max_pk_neg_pos = pks(idx2)*sin(-2*pi*f(locs(idx2))*(yr_array + b)) + val;
        max_pk_neg_neg = pks(idx2)*sin(-2*pi*f(locs(idx2))*(yr_array - b)) + val;
    else
        max_pk_pos_pos = pks(idx2)*sin(2*pi*f(locs(idx2))*(yr_array + b));
        max_pk_pos_neg = pks(idx2)*sin(2*pi*f(locs(idx2))*(yr_array - b));
        max_pk_neg_pos = pks(idx2)*sin(-2*pi*f(locs(idx2))*(yr_array + b));
        max_pk_neg_neg = pks(idx2)*sin(-2*pi*f(locs(idx2))*(yr_array - b));
    end
end

% Period
T = (1./([f(idx),f(locs)]))./1000;

% Red Noise
ar1 = arima(1,0,0);
mdl = estimate(ar1,perc_50_array.','Display','off'); 
red_noise = simulate(mdl,L);
red_noise = red_noise.';
red_noise_filter = thselect(red_noise,'minimaxi');
F_red = fft(red_noise_filter);
P2_red = abs(F_red/L);
P1_red = P2_red(1:floor(L/2+1));
P1_red(2:end-1) = 2*P1_red(2:end-1);

% White Noise
white_noise = randn(1,length(yr_array))*sqrt(var(perc_50_array));
white_noise_filter = thselect(white_noise,'minimaxi');
F_white = fft(white_noise_filter);
P2_white = abs(F_white/L);
P1_white = P2_white(1:floor(L/2+1));
P1_white(2:end-1) = 2*P1_white(2:end-1);

% Power
power = abs(P1).^2/length(f);
power_red = abs(P1_red).^2/length(f);
power_white = abs(P1_white).^2/length(f);


%% Plot Devices
y_string = 'Variable';


%% Plotting
fignum = 1;

% Time series
figure(fignum)
hold on
plot(yr_array,perc_50_array)
xlabel('Years')
ylabel('Data')
title('Time Series')
fignum = fignum + 1;

% Frequency Spectrum - Amplitude
title_str = 'Amplitude vs Single-Sided Frequency Spectrum';

figure(fignum)
hold on
plot(f,P1,'b') 
plot(f,P1_red,'r')
plot(f,P1_white,'k')
title(title_str)
xlabel('Frequency')
ylabel(strcat('Amplitude'))
legend('Data','Red Noise','White Noise')
fignum = fignum + 1;

clearvars title_str

% Frequency Spectrum - Power
title_str = 'Power vs Single-Sided Frequency Spectrum';

figure(fignum)
hold on
plot(f,power,'b') 
plot(f,power_red,'r')
plot(f,power_white,'k')
title(title_str)
xlabel('Frequency')
ylabel(strcat('Power'))
legend('Data','Red Noise','White Noise')
fignum = fignum + 1;

clearvars title_str

%% Plots without first value
% Frequency Spectrum - Amplitude
title_str = 'Amplitude vs Single-Sided Frequency Spectrum V2';

figure(fignum)
hold on
plot(f(2:end),P1(2:end),'b') 
plot(f(2:end),P1_red(2:end),'r')
plot(f(2:end),P1_white(2:end),'k')
title(title_str)
xlabel('Frequency')
ylabel(strcat('Amplitude'))
legend('Data','Red Noise','White Noise')
fignum = fignum + 1;

clearvars title_str

% Frequency Spectrum - Power
title_str = 'Power vs Single-Sided Frequency Spectrum V2';

figure(fignum)
hold on
plot(f(2:end),power(2:end),'b') 
plot(f(2:end),power_red(2:end),'r')
plot(f(2:end),power_white(2:end),'k')
title(title_str)
xlabel('Frequency')
ylabel(strcat('Power'))
legend('Data','Red Noise','White Noise')
fignum = fignum + 1;

clearvars title_str

%% Combined Peaks vs Data
% if ~isempty(pks)
%     %Pos Pos
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,comb_pks_pos_pos,'r')
%     title({'Combined Peak Frequencies',...
%             'Positive Frequency',strcat('Positive Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data','Combined Peak Frequencies')
%     fignum = fignum + 1;
% 
%     %Pos Neg
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,comb_pks_pos_neg,'r')
%     title({'Combined Peak Frequencies',...
%             'Positive Frequency',strcat('Negative Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data','Combined Peak Frequencies')
%     fignum = fignum + 1;
% 
%     %Neg Pos
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,comb_pks_neg_pos,'r')
%     title({'Combined Peak Frequencies',...
%             'Negative Frequency',strcat('Positive Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data','Combined Peak Frequencies')
%     fignum = fignum + 1;
% 
% 
%     %Neg Neg
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,comb_pks_neg_neg,'r')
%     title({'Combined Peak Frequencies',...
%             'Negative Frequency',strcat('Negative Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data','Combined Peak Frequencies')
%     fignum = fignum + 1;
% 
% end
% 
% %% Max Peak vs Data
% if ~isempty(idx2)
%     %Pos Pos
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,max_pk_pos_pos,'r')
%     title({'Most Correlated Period',...
%             'Positive Frequency',strcat('Positive Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data',strcat(num2str(1./f(locs(idx2))),32,'year period'))
%     fignum = fignum + 1;
% 
%     %Pos Neg
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,max_pk_pos_neg,'r')
%     title({'Most Correlated Period',...
%             'Positive Frequency',strcat('Negative Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data',strcat(num2str(1./f(locs(idx2))),32,'year period'))
%     fignum = fignum + 1;
% 
%     %Neg Pos
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,max_pk_neg_pos,'r')
%     title({'Most Correlated Period',...
%             'Negative Frequency',strcat('Positive Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data',strcat(num2str(1./f(locs(idx2))),32,'year period'))
%     fignum = fignum + 1;
% 
%     %Neg Neg
%     figure(fignum)
%     hold on
%     plot(yr_array,perc_50_array,'b') 
%     plot(yr_array,max_pk_neg_neg,'r')
%     title({'Most Correlated Period',...
%             'Negative Frequency',strcat('Negative Phase',32,num2str(b))})
%     xlabel('Year')
%     ylabel(y_string)
%     legend('Data',strcat(num2str(1./f(locs(idx2))),32,'year period'))
%     fignum = fignum + 1;
%     
% end

%% Bar Chart
if ~isempty(pks)
    idx3 = find(pks >= 0.2*max(pks));
    
    figure(fignum)
    bar(1./f(locs(idx3)),pks(idx3),0.3)
    title('Periods vs Amplitudes')
    xlabel('Period - Years')
    ylabel('Amplitude')
    fignum = fignum + 1;
end

%% Table

tempmat = [([f(idx),f(locs)]).', T.', ([val,pks]).']; 
tempmat = tempmat.';

names{1} = 'Max_Amplitude';
Val_Table = table(tempmat,'VariableNames',names);

Val_Table.Properties.RowNames = {'Frequency';'Period';'Amplitude'};
                                
figure(fignum)
uitable('Data',Val_Table{:,:},'ColumnName',...
    Val_Table.Properties.VariableNames,'RowName',Val_Table.Properties.RowNames,'Units',...
    'Normalized','Position',[0,0,1,1]);
