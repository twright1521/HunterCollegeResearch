%% Fourier Transforms - Red Noise - De-Trended

% Finds the fourier transform of the mean data
% Takes significant periods based on Red Noise

% De-trends the data if pValue is less than a designated threshold
% (this value can be changed on line 27)
% Uses a linear trend model

% Does this for multiple sets of data
% Data sets must be of the same type, i.e 'Precipitation', 'Tmax', or 'Tmin'

% Can process Annual, Seasonal, or 10yr Running Mean data

% Data Arrays must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

%%%%%%%%%%%%%% 
% This program plays a loud gong when finished
% To disable set this flag to false
gong_flag = true;

clearvars -except gong_flag

%% Inputs

%pValue Threshold - this determines which models get De-trended
pValue_threshold = 0.05;

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

% Model Folder - List of main Folders for the models
Model_Fol = {'catskills_sta_data_may15_2018','cmip5_may15_2018'};

% File Folder - List of the separate file folders - i.e. model folders
% For catskill data files, include an empty string
File_Fol = {'','5.1_cccma_canesm2_tasmin_output','7.1_ncar_ccsm4_tasmin_output',...
            '21.2_HadGEM2-CC_tasmin_output'};     

% File Name - must contain "Annual, "Seasonal", or "10yr"
file_name = {'catskill_compare_stations_june2017_TMIN_combined_Annual_Mean',...
             'tasmin_day_CCSM4_historical_r1i1p1_Annual_Mean',...
             'tasmin_day_CCSM4_historical_r2i1p1_Annual_Mean',...
             'tasmin_day_CCSM4_historical_r6i1p1_Annual_Mean',...
             'tasmin_day_HadGEM2-CC_historical_r1i1p1_Annual_Mean',...
             'tasmin_day_HadGEM2-CC_historical_r2i1p1_Annual_Mean',...
             'tasmin_day_HadGEM2-CC_historical_r3i1p1_Annual_Mean',...
             'tasmin_day_CanESM2_historical_r1i1p1_Annual_Mean',...
             'tasmin_day_CanESM2_historical_r2i1p1_Annual_Mean',...
             'tasmin_day_CanESM2_historical_r3i1p1_Annual_Mean',...
             'tasmin_day_CanESM2_historical_r4i1p1_Annual_Mean',...
             'tasmin_day_CanESM2_historical_r5i1p1_Annual_Mean'};

% Auto-save figures
% set tag to true to save figures automatically

save_tag = true;

%% Program Start

% Getting the file type - i.e mean, 10 yr mean, etc.
c = textscan(file_name{1},'%s','delimiter','_');
c = c{1};

name_flag = false;
for x = 1:length(c)
    if strcmp(c{x},'FULL') || strcmp(c{x},'final')
        folder_name = 'Daily Time Series';
        name_flag = true;
        break
    else
        if strcmp(c{x},'10yr')
            for y = x:length(c)
                if y == x
                    folder_name = c{x};
                else
                    folder_name = strcat(folder_name,32,c{y});
                end
            end
            name_flag = true;
            break
        end
    end
end

if (name_flag == false)
    if strcmp(c{end},'Mean')
        folder_name = strcat(c{end-1},32,c{end});
    else
        folder_name = strcat(c{end-2},32,c{end-1},32,c{end});
    end
end

%% Main Loop
fignum = 1;
P_idx = 1;

for file_idx = 1:length(file_name)
    for fol_idx = 1:length(File_Fol)
        for model_idx = 1:length(Model_Fol)

            % Data file path
            if  isempty(File_Fol{fol_idx})
                File_Path = Model_Fol{model_idx};
            else
                File_Path = strcat(Model_Fol{model_idx},filesep,File_Fol{fol_idx});
            end

            file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'.mat');

            % Loading data file under a specific name
            if ~exist(file)
                continue      %Skips to next iteration if the file isnt in this file path
            end

            %Determines if using mean data or full time series
            c = textscan(file_name{1},'%s','delimiter','_');
            c = c{1};
            name_flag = false;
            for x = 1:length(c)
                if strcmp(c{x},'FULL') || strcmp(c{x},'final')
                    name_flag = true;
                end
            end
        
            clearvars c
            
            % Getting the Plot Type
            c = textscan(file_name{1},'%s','delimiter','_');
            c = c{1};
            if strcmp(c{1},'catskill')
                if strcmp(c{5},'PRCP')
                    plot_type = 'Precipitation';
                else
                    if strcmp(c{5},'TMAX')
                        plot_type = 'Tmax';
                    else
                        plot_type = 'Tmin';
                    end
                end
            else
                if strcmp(c{1},'pr')
                    plot_type = 'Precipitation';
                else
                    if strcmp(c{1},'tasmax')
                        plot_type = 'Tmax';
                    else
                        plot_type = 'Tmin';
                    end
                end
            end
            
            clearvars c
            
            if(P_idx == 1)
                Main_plot_type = plot_type;
            end
            
            % Loading data file under a specific name
            array = struct2cell(load(file));
            array = array{1};
            
            if name_flag == true
                val_array = str2double(array(2:end,6:end));
            else
                val_array = str2double(array(2:end,2:end));
            end
            
            yr_array_init = str2double(array(2:end,1));

            if strcmp(plot_type,'Precipitation')
                yr_idx = find(yr_array_init >= 1930);
            else
                yr_idx = find(yr_array_init >= 1950);
            end
            
            yr_array = yr_array_init(yr_idx);
            
            % Calculate the 10, 50, 90 Percentiles Arrays
            perc_50_init = prctile(val_array,50,2);
            perc_50_array = perc_50_init(yr_idx);
            nan_idx = isnan(perc_50_array);
            perc_50_array(nan_idx) = [];
            yr_array(nan_idx) = [];

            % Trend Analysis
            trend_model =  fitlm(yr_array,perc_50_array);
            
            slope = trend_model.Coefficients.Estimate(2);
            inter = trend_model.Coefficients.Estimate(1);
            pValue = trend_model.Coefficients.pValue(2);
            
            if (pValue <= pValue_threshold) %this determines which models get De-Trended
                trend_data = inter + slope*yr_array;
                perc_50_array = perc_50_array - trend_data;
                trend_name = 'De-Trended';
            else
                trend_name = 'Not De-Trended';
            end
            
            % Calculate Fourier Transform
            F = fft(perc_50_array.');
            L = yr_array(end) - yr_array(1);

            P2 = abs(F/L);
            P1 = P2(1:floor(L/2+1));
            P1(2:end-1) = 2*P1(2:end-1);
            f = (0:L/2)/L;

            % Red and White Noise Simulations - Create Arrays
            red_noise_array = [];
            white_noise_array = [];
            
            for x = 1:2000
                ar1 = arima(1,0,0);
                mdl = estimate(ar1,perc_50_array,'Display','off'); 
                red_noise = simulate(mdl,L);
                red_noise = red_noise.';
                red_noise_array = [red_noise_array; red_noise];
                
                white_noise = randn(1,length(yr_array))*sqrt(var(perc_50_array));
                white_noise_array = [white_noise_array;white_noise];
            end
            
            % Red Noise
            F_red = fft(red_noise_array,[],2);
            P2_red = abs(F_red/L);
            P1_red = P2_red(1:end,1:floor(L/2+1));
            P1_red(1:end,2:end-1) = 2*P1_red(1:end,2:end-1);
            P1_red_99 = prctile(P1_red,99,1);
            P1_red_90 = prctile(P1_red,90,1);

            % White Noise
            F_white = fft(white_noise_array,[],2);
            P2_white = abs(F_white/L);
            P1_white = P2_white(1:end,1:floor(L/2+1));
            P1_white(1:end,2:end-1) = 2*P1_white(1:end,2:end-1);
            P1_white_99 = prctile(P1_white,99,1);
            P1_white_90 = prctile(P1_white,90,1);

            % Peaks and Max
            locs_90 = find(P1(2:end) > P1_red_90(2:end)); %90 percentile
            locs_90 = locs_90 + 1;
            pks_90 = P1(locs_90);
            
            locs_99 = find(P1(2:end) > P1_red_99(2:end)); %99 percentile
            locs_99 = locs_99 + 1;
            pks_99 = P1(locs_99);
            
            [val,idx] = max(P1);
            [~,idx2] = max(pks_90);

            if ~isempty(idx2)
                b = sqrt(1/f(locs_90(idx2)));
            else
                b = 0;
            end

            % Combined Peaks
            if ~isempty(pks_90)
                comb_pks_pos_pos = 0;
                comb_pks_pos_neg = 0;
                comb_pks_neg_pos = 0;
                comb_pks_neg_neg = 0;

                for zeta = 1:length(pks_90)
                    comb_pks_pos_pos = comb_pks_pos_pos + pks_90(zeta)*sin(2*pi*f(locs_90(zeta))*(yr_array + b));  
                    comb_pks_pos_neg = comb_pks_pos_neg + pks_90(zeta)*sin(2*pi*f(locs_90(zeta))*(yr_array - b));
                    comb_pks_neg_pos = comb_pks_neg_pos + pks_90(zeta)*sin(-2*pi*f(locs_90(zeta))*(yr_array + b));
                    comb_pks_neg_neg = comb_pks_neg_neg + pks_90(zeta)*sin(-2*pi*f(locs_90(zeta))*(yr_array - b));
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
                    max_pk_pos_pos = pks_90(idx2)*sin(2*pi*f(locs_90(idx2))*(yr_array + b)) + val;
                    max_pk_pos_neg = pks_90(idx2)*sin(2*pi*f(locs_90(idx2))*(yr_array - b)) + val;
                    max_pk_neg_pos = pks_90(idx2)*sin(-2*pi*f(locs_90(idx2))*(yr_array + b)) + val;
                    max_pk_neg_neg = pks_90(idx2)*sin(-2*pi*f(locs_90(idx2))*(yr_array - b)) + val;
                else
                    max_pk_pos_pos = pks_90(idx2)*sin(2*pi*f(locs_90(idx2))*(yr_array + b));
                    max_pk_pos_neg = pks_90(idx2)*sin(2*pi*f(locs_90(idx2))*(yr_array - b));
                    max_pk_neg_pos = pks_90(idx2)*sin(-2*pi*f(locs_90(idx2))*(yr_array + b));
                    max_pk_neg_neg = pks_90(idx2)*sin(-2*pi*f(locs_90(idx2))*(yr_array - b));
                end
            end

            % Significant Periods
            if f(idx) == 0
                T_90 = 1./([f(idx),f(locs_90)]);
                T_99 = 1./([f(idx),f(locs_99)]);
            else
                T_90 = 1./f(locs_90);
                T_99 = 1./f(locs_99);
            end

            
            %% Proper File Name
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            if strcmp(temp_string{1},'catskill')
                legend_name = temp_string{1};
            else
                legend_name = strcat(temp_string{3},'_',temp_string{5});
            end

            legend_name = strrep(legend_name,'_',' ');
            
            for x = 1: length(temp_string)
                if (strcmp(temp_string{x},'10yr') || strcmp(temp_string{x},'Annual'))
                    if isempty(File_Fol{fol_idx})
                        temp_string{x} = 'final';
                    else
                        temp_string{x} = 'FULL_NE_ts';
                    end
                    for y = x+1:length(temp_string)
                        temp_string{y} = [];
                    end
                    break
                end
            end

            for x = 1:length(temp_string)
                if x == 1
                    name_string = temp_string{x};
                else
                    if isempty(temp_string{x})
                        name_string = strcat(name_string,temp_string{x});
                    else
                        name_string = strcat(name_string,'_',temp_string{x});
                    end
                end
            end

            clearvars c temp_string
            
            %% Plot Devices
            
            % y_string for y axis labels
            if strcmp(plot_type,'Precipitation')
                y_string = 'Precipitation - mm';
            else
                y_string = 'Temperature - Celsius';
            end

            % Getting the Model Name
            if ~isempty(File_Fol{fol_idx})
                c = textscan(File_Fol{fol_idx},'%s','delimiter','_');
                temp_string = c{1};
                for x = 1: length(temp_string)
                    k1 = strfind(temp_string{x},'output');
                    k2 = strfind(temp_string{x},'tas');
                    if ~isempty(k1) || ~isempty(k2) 
                        for y = x:length(temp_string)
                            temp_string{y} = [];
                        end

                        for y = 1:length(temp_string)
                            if y == 1
                                Model_Name = temp_string{y};
                            else
                                if isempty(temp_string{y})
                                    break
                                else
                                    Model_Name = strcat(Model_Name,'_',temp_string{y});
                                end
                            end
                        end
                        break
                    end
                end
            end
            
            % Create folders to save figures
            if (save_tag == 1)
                save_folder = strcat(Main_Dir,filesep,Model_Fol{model_idx},filesep,'Figures_',Model_Fol{model_idx});
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                save_folder = strcat(save_folder,filesep,plot_type);
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                if ~isempty(File_Fol{fol_idx})
                    save_folder = strcat(save_folder,filesep,Model_Name);
                    if (exist(save_folder,'dir') == 0)
                        mkdir(save_folder)
                    end
                end
                
                save_folder = strcat(save_folder,filesep,name_string);
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end

                save_folder = strcat(save_folder,filesep,'De_Trended_Fourier_Transform_Red_Noise');
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end   

                save_folder = strcat(save_folder,filesep,folder_name);
                if (exist(save_folder,'dir') == 0)
                    mkdir(save_folder)
                end   
                
                combined_folder = strcat(save_folder,filesep,'Combined');
                if (exist(combined_folder,'dir') == 0)
                    mkdir(combined_folder)
                end

                best_fit_folder = strcat(save_folder,filesep,'Best Fit');
                if (exist(best_fit_folder,'dir') == 0)
                    mkdir(best_fit_folder)
                end
            end

            % Create folders to save PNGs
            if (save_tag == 1)
                save_PNG_folder = strcat(Main_Dir,filesep,Model_Fol{model_idx},filesep,'PNGs_',Model_Fol{model_idx});
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder = strcat(save_PNG_folder,filesep,plot_type);
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                if ~isempty(File_Fol{fol_idx})
                    save_PNG_folder = strcat(save_PNG_folder,filesep,Model_Name);
                    if (exist(save_PNG_folder,'dir') == 0)
                        mkdir(save_PNG_folder)
                    end
                end
        
                save_PNG_folder = strcat(save_PNG_folder,filesep,name_string);
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder = strcat(save_PNG_folder,filesep,'De_Trended_Fourier_Transform_Red_Noise');
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end

                save_PNG_folder = strcat(save_PNG_folder,filesep,folder_name);
                if (exist(save_PNG_folder,'dir') == 0)
                    mkdir(save_PNG_folder)
                end
                
                combined_PNG_folder = strcat(save_PNG_folder,filesep,'Combined');
                if (exist(combined_PNG_folder,'dir') == 0)
                    mkdir(combined_PNG_folder)
                end

                best_fit_PNG_folder = strcat(save_PNG_folder,filesep,'Best Fit');
                if (exist(best_fit_PNG_folder,'dir') == 0)
                    mkdir(best_fit_PNG_folder)
                end
            end

            

            %% Plotting
            
            % Frequency Spectrum - Amplitude
            title_str = strcat(legend_name,32,plot_type,32,'Amplitude vs Single-Sided Frequency Spectrum');

            figure(fignum)
            hold on
            plot(f,P1,'b') 
            plot(f,P1_red_99,'r--')
            plot(f,P1_red_90,'r')
            plot(f,P1_white_90,'k')
            title({trend_name;title_str})
            xlabel('Frequency')
            ylabel(strcat('Amplitude -',32,y_string))
            legend('Data','Red Noise - 99%','Red Noise - 90%','White Noise - 90%')
            hold off
            
            fignum = fignum + 1;

            if(save_tag == 1)
                savefig(strcat(save_folder,filesep,title_str))
                saveas(gcf,strcat(save_PNG_folder,filesep,title_str),'png')
            end

            clearvars title_str

            %% Plots without first value
            % Frequency Spectrum - Amplitude
            title_str = strcat(legend_name,32,plot_type,32,'Amplitude vs Single-Sided Frequency Spectrum V2');

            figure(fignum)
            hold on
            plot(f(2:end),P1(2:end),'b') 
            plot(f(2:end),P1_red_99(2:end),'r--')
            plot(f(2:end),P1_red_90(2:end),'r')
            plot(f(2:end),P1_white_90(2:end),'k')
            title({trend_name;title_str})
            xlabel('Frequency')
            ylabel(strcat('Amplitude -',32,y_string))
            legend('Data','Red Noise - 99%','Red Noise - 90%','White Noise - 90%')
            hold off
            fignum = fignum + 1;

            if(save_tag == 1)
                savefig(strcat(save_folder,filesep,title_str))
                saveas(gcf,strcat(save_PNG_folder,filesep,title_str),'png')
            end

            clearvars title_str

            %% Combined Peaks vs Data
            if ~isempty(pks_90)
                %Pos Pos
                title_str = strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies',32,...
                            'Positive Frequency',32,'Positive Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,comb_pks_pos_pos,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies'),...
                        'Positive Frequency',strcat('Positive Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),'Combined Peak Frequencies')
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(combined_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(combined_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Pos Neg
                title_str = strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies',32,...
                            'Positive Frequency',32,'Negative Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,comb_pks_pos_neg,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies'),...
                        'Positive Frequency',strcat('Negative Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),'Combined Peak Frequencies')
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(combined_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(combined_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Neg Pos
                title_str = strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies',32,...
                            'Negative Frequency',32,'Positive Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,comb_pks_neg_pos,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies'),...
                        'Negative Frequency',strcat('Positive Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),'Combined Peak Frequencies')
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(combined_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(combined_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Neg Neg
                title_str = strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies',32,...
                            'Negative Frequency',32,'Negative Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,comb_pks_neg_neg,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Combined Peak Frequencies'),...
                        'Negative Frequency',strcat('Negative Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),'Combined Peak Frequencies')
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(combined_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(combined_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str
            end

            %% Max Peak vs Data
            if ~isempty(idx2)
                %Pos Pos
                title_str = strcat(legend_name,32,plot_type,32,'Most Correlated Period',32,...
                        'Positive Frequency',32,'Positive Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,max_pk_pos_pos,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Most Correlated Period'),...
                        'Positive Frequency',strcat('Positive Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),strcat(num2str(1./f(locs_90(idx2))),32,'year period'))
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(best_fit_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(best_fit_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Pos Neg
                title_str = strcat(legend_name,32,plot_type,32,'Most Correlated Period',32,...
                            'Positive Frequency',32,'Negative Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,max_pk_pos_neg,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Most Correlated Period'),...
                        'Positive Frequency',strcat('Negative Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),strcat(num2str(1./f(locs_90(idx2))),32,'year period'))
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(best_fit_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(best_fit_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Neg Pos
                title_str = strcat(legend_name,32,plot_type,32,'Most Correlated Period',32,...
                            'Negative Frequency','Positive Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,max_pk_neg_pos,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Most Correlated Period'),...
                        'Negative Frequency',strcat('Positive Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),strcat(num2str(1./f(locs_90(idx2))),32,'year period'))
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(best_fit_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(best_fit_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str

                %Neg Neg
                title_str = strcat(legend_name,32,plot_type,32,'Most Correlated Period',32,...
                            'Negative Frequency',32,'Negative Phase');

                figure(fignum)
                hold on
                plot(yr_array,perc_50_array,'b') 
                plot(yr_array,max_pk_neg_neg,'r')
                title({trend_name,strcat(legend_name,32,plot_type,32,'Most Correlated Period'),...
                        'Negative Frequency',strcat('Negative Phase',32,num2str(b))})
                xlabel('Year')
                ylabel(y_string)
                legend(strcat(legend_name,32,'Data'),strcat(num2str(1./f(locs_90(idx2))),32,'year period'))
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(best_fit_folder,filesep,title_str,'.fig'))
                    saveas(gcf,strcat(best_fit_PNG_folder,filesep,title_str),'png')
                end

                clearvars title_str
            end

            %% Bar Chart
            if ~isempty(pks_90)
                figure(fignum)
                bar(1./f(locs_90),pks_90)
                title({trend_name,strcat(legend_name,32,plot_type,32,'Periods vs Amplitudes')})
                xlabel('Period - Years')
                ylabel(strcat('Amplitude -',32,y_string))
                xlim([0, ceil(L/5)*5])
                fignum = fignum + 1;

                if(save_tag == 1)
                    saveas(gcf,strcat(save_folder,filesep,'Bar Chart','.fig'))
                    saveas(gcf,strcat(save_PNG_folder,filesep,'Bar Chart'),'png')
                end
            end

            %% Table

            if f(idx) == 0
                tempmat = [([f(idx);f(locs_90).']).'; T_90; ([val;pks_90.']).']; 
            else
                tempmat = [f(locs_90); T_90; pks_90];
            end
            
%             tempmat = tempmat.';

            legend_name = strrep(legend_name,' ','_');
            names{1} = strrep(legend_name,'-','_');
            for x = 2:size(tempmat,2)
                names{x} = strcat('Period_',num2str(x-1));
            end
            
            for x = 1:size(tempmat,2)
                if x == 1
                    temp_name{1} = names{1};
                    Val_Table = table(tempmat(:,1),'VariableNames',temp_name);
                else
                    temp_name{1} = names{x};
                    Val_Table = [Val_Table,table(tempmat(:,x),'VariableNames',temp_name)];
                end
            end

            % Val_Table.Properties.VariableNames = names;
            Val_Table.Properties.RowNames = {'Frequency';'Period';'Amplitude'};

            figure(fignum)
            uitable('Data',Val_Table{:,:},'ColumnName',...
                Val_Table.Properties.VariableNames,'RowName',Val_Table.Properties.RowNames,'Units',...
                'Normalized','Position',[0,0,1,1]);

            if(save_tag == 1)
                savefig(strcat(save_folder,filesep,'Table of Values'))
                saveas(gcf,strcat(save_PNG_folder,filesep,'Table of Values'),'png')
            end

            fignum = fignum + 1;
            
            %% Period Array
            % Adding Significant Periods to Array
            Period_Array{P_idx,1} = names{1};
            
            if T_90(1) == Inf
                Period_Array{P_idx,2} = T_90(2:end);
            else
                Period_Array{P_idx,2} = T_90;
            end
            
            Period_Array{P_idx,3} = pks_90;
            
            if T_90(1) == Inf
                Period_Array{P_idx,4} = T_99(2:end);
            else
                Period_Array{P_idx,4} = T_99;
            end
       
            Period_Array{P_idx,5} = pks_99;
            
            P_idx = P_idx + 1;
            
            clearvars -except pValue_threshold gong_flag folder_name P_idx Period_Array Main_Dir Model_Fol File_Fol file_name save_tag file_idx fol_idx model_idx fignum Main_plot_type
        end
    end
end
       
%% Comparative Utilities

% Model/Ensemble names
for x = 1:size(Period_Array, 1)
    names_str{x} = strrep(Period_Array{x,1},'_',' ');
end

% Save location
if (save_tag == 1)
    save_folder = strcat(Main_Dir,filesep,'Fourier Analysis Red Noise');
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end

    save_folder = strcat(save_folder,filesep,'De_Trended');
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end
    
    save_folder = strcat(save_folder,filesep,Main_plot_type);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end
    
    save_folder = strcat(save_folder,filesep,folder_name);
    if (exist(save_folder,'dir') == 0)
        mkdir(save_folder)
    end   
end

%% Bar Graph - 90 Percentile

% This puts all the relevant information together in an array the "bar3"
% function will recognize
for x = 1:size(Period_Array, 1)
    temp_T = Period_Array{x,2};
    temp_A = Period_Array{x,3};
    
    if x == 1
        T_Vector = temp_T;
        A_Array = temp_A;
        continue
    else
        emp_row = zeros(1,size(A_Array,2));
        A_Array = [A_Array; emp_row];
    end
    
    
    for y = 1:length(temp_T)
        flag = false;
        for z = 1:length(T_Vector)
            if temp_T(y) == T_Vector(z)
                flag = true;
                break
            end
        end
        
        if flag == true
            A_Array(x,z) = temp_A(y);
        else
            T_Vector = [T_Vector,temp_T(y)];
            emp_col = zeros(size(A_Array,1),1);
            A_Array = [A_Array, emp_col];
            A_Array(end,end) = temp_A(y);
        end
    end
       
    clearvars temp_T temp_A 
end

[T_Vector,Idx] = sort(T_Vector);
A_Array = A_Array(:,Idx);
max_T = max(T_Vector);
A_Array(A_Array == 0) = NaN;

% Plot title
title_str = strcat(Main_plot_type,32,'Comparative');

% Plotting the bar graph
f = figure(fignum);
set(f,'Position',[10 10 900 600])
hold on
grid on
bar3(T_Vector,A_Array.','detached')
title({'De-Trended';title_str;'Period vs. Amplitude'})
legend(names_str)
ylabel('Period - yrs')
zlabel('Amplitude')
xlabel('Data/Model')
xticks(linspace(1,length(names_str),length(names_str)))
view(66,35.6)

fignum = fignum + 1;

if(save_tag == 1)
    savefig(strcat(save_folder,filesep,'Comparative Bar Graph'))
    saveas(gcf,strcat(save_folder,filesep,'Comparative Bar Graph'),'png')
end

%% Table - 90 and 99 Percentile

var_names = {'Percentile_90','Percentile_99'};

% Putting the data in an array the "table" function will recognize
% 90 Percentile
for x = 1:size(Period_Array,1)
    temp_T = Period_Array{x,2};
    
    if x == 1
        T_Array = temp_T;
        continue
    end
    
    if size(T_Array,2) > size(temp_T,2)
        for y = size(temp_T,2)+1:size(T_Array,2)
            temp_T(y) = NaN;
        end
    else
        if size(T_Array,2) < size(temp_T,2)
            y = size(temp_T,2) - size(T_Array,2);
            emp_col = zeros(size(T_Array,1),y);
            emp_col(emp_col == 0) = NaN;
            T_Array = [T_Array,emp_col];
        end
    end
    
    T_Array = [T_Array; temp_T];
end
 
var_string{1} = var_names{1};
for x = 2:size(T_Array,2)
    var_string{x} = [];
end

temp_name{1} = var_names{1};
Val_Table_1 = table(T_Array,'VariableNames',temp_name);

clearvars T_Array

% 99 Percentile
for x = 1:size(Period_Array,1)
    temp_T = Period_Array{x,4};
    
    if x == 1
        T_Array = temp_T;
        continue
    end
    
    if size(T_Array,2) > size(temp_T,2)
        for y = size(temp_T,2)+1:size(T_Array,2)
            temp_T(y) = NaN;
        end
    else
        if size(T_Array,2) < size(temp_T,2)
            y = size(temp_T,2) - size(T_Array,2);
            emp_col = zeros(size(T_Array,1),y);
            emp_col(emp_col == 0) = NaN;
            T_Array = [T_Array,emp_col];
        end
    end
    
    T_Array = [T_Array; temp_T];
end

var_string{length(var_string)+1} = var_names{2};

% Creating the table
temp_name{1} = var_names{2};
Val_Table_2 = table(T_Array,'VariableNames',temp_name);

Val_Table = [Val_Table_1,Val_Table_2];
Val_Table.Properties.RowNames = names_str;

title_str = 'De-Trended - Significant Periods';

% Creating table figure
figure(fignum)
uitable('Data',Val_Table{:,:},'ColumnName',...
    var_string,'RowName',Val_Table.Properties.RowNames,'Units',...
    'Normalized','Position',[0,0,1,1]);

if(save_tag == 1)
    savefig(strcat(save_folder,filesep,title_str))
    saveas(gcf,strcat(save_folder,filesep,title_str),'png')
end

%% End Gong
% Lets you know when the program finishes
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end

