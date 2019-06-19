%% Annual 10-yr Middle Running Mean File

% Create Annual 10-yr Running Mean File from Combined_Annual_Mean file data
% (generated from the "Create_Annual_Mean_Max_Min_Files.m" program)

% Also works for seasonal mean data 
% (generated from the "Create_Seasonal_Mean_Max_Min_Files.m" program)


% Also Generates data array for future use
% Runs multiple files

% This program takes a very long time

% Input Data files must be formatted in the following way

% Column 1 - Year
% Column 2+ - Mean Data

%%%%%%%%%%%%%% 
% This program plays a loud gong when finished
% To disable set this flag to false
gong_flag = true;

clearvars -except gong_flag

%% Inputs

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

% Model Folder - List of Main Folders for the models
Model_Fol = {'catskills_sta_data_may15_2018','cmip5_may15_2018'};

% File Folder - List of the separate file folders - i.e. model folders
% For catskill data files, include an empty string
File_Fol = {'','5.1_cccma_canesm2_tasmin_output','7.1_ncar_ccsm4_tasmin_output',...
            '21.2_HadGEM2-CC_tasmin_output','5.1_cccma_canesm2_tasmax_output',...
            '7.1_ncar_ccsm4_tasmax_output','21.2_HadGEM2-CC_tasmax_output',...
            '5.1_cccma_canesm2_output','7.1_ncar_ccsm4_output',...
            '21.2_HadGEM2-CC_output'};       

% File Name - must end with  "_Annual_Mean"
% List of the individual files
file_name = {'tasmin_day_CanESM2_historical_r1i1p1_Seasonal_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r2i1p1_Seasonal_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r3i1p1_Seasonal_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r4i1p1_Seasonal_Mean_Summer',...
               'tasmin_day_CanESM2_historical_r5i1p1_Seasonal_Mean_Summer'};

%% Program Start

for file_idx = 1:length(file_name)
    for fol_idx = 1:length(File_Fol)
        for model_idx = 1:length(Model_Fol)
            % Data file path
            if  isempty(File_Fol{fol_idx}) == 1
                File_Path = Model_Fol{model_idx};
            else
                File_Path = strcat(Model_Fol{model_idx},filesep,File_Fol{fol_idx});
            end

            file = strcat(Main_Dir,filesep,File_Path,filesep,file_name{file_idx},'.mat');

            % Loading data file under a specific name
            if ~exist(file)
                continue      %Skips to next iteration if the file isnt in this file path
            end
            
            % Loading data file under a specific name
            array = struct2cell(load(file));
            array = array{1};

            [m,n] = size(array);

            % Vecter of each year in data array 
            a = array(2:end,1);
            
            [temp_yr_array,m1,~] = unique(a,'first');
            [~,d1] = sort(m1);
            yr_array = temp_yr_array(d1);

            clearvars a m1 d1 temp_yr_array

            % Calculate 10-yr Middle Runninng Mean
            avg_array = [];

            for x = str2double(array{2,1})+5:str2double(array{m,1})-4

                yr_test = strcmp(array(:,1),num2str(x));
                yr_idx = find(yr_test == 1);
                val_array = [];

                for y = yr_idx-5:yr_idx+4
                    vals = str2double(array(y,2:n));
                    val_array = [val_array; vals];
                end

                test_nan = ~isnan(val_array);

                for z = 1:size(test_nan,2)
                    sum_test_nan = sum(test_nan(:,z));
                    if (sum_test_nan >= 7)
                        temp_avg_array(1,z) = mean(val_array(:,z),'omitnan');
                    else
                        temp_avg_array(1,z) = NaN;
                    end
                    clearvars sum_test_nan
                end

                % Array of the mean values
                avg_array = [avg_array; temp_avg_array];

                clearvars val_array temp_avg_array test_nan
            end

            %% Saving Data Array
            % Creating the new file name from the old name
            % i.e. changing the end of the file name
            name_flag = false;
            c = textscan(file_name{file_idx},'%s','delimiter','_');
            temp_string = c{1};
            for x = 1: length(temp_string)
                if strcmp(temp_string{x},'Annual')
                    name_flag = true;
                    temp_string{x} = '10yr_Middle_Running_Mean';
                    for y = x+1:length(temp_string)
                        temp_string{y} = [];
                    end
                    break
                end
                if strcmp(temp_string{x},'Seasonal')
                    name_flag = true;
                    temp_string{x} = '10yr_Middle_Running_Mean';
                    for y = x+1:length(temp_string)
                        if strcmp(temp_string{y},'Summer')
                            temp_string{y} = 'Summer';
                        else
                            if strcmp(temp_string{y},'Winter')
                                temp_string{y} = 'Winter';
                            else
                                temp_string{y} = [];
                            end
                        end
                    end
                    break
                end
            end

            % Checks to ensure the proper file name was used
            % (generated from the "Create_Annual_Mean_Max_Min_Files.m" program)
            if name_flag == false
                error('Check File Name - Incorrect File Used')
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

            % Creating the output array
            output_array{1,1} = array{1,1};
            for x = 2:size(array,2)
                output_array{1,x} = array{1,x};
            end

            for x = 1:size(avg_array,1)
                for y = 1:size(avg_array,2)+1
                    if y == 1
                        output_array{x+1,y} = yr_array{x+5,1};
                    else
                        output_array{x+1,y} = num2str(avg_array(x,y-1));
                    end
                end
            end

            % Saving the year-value array to a matlab usable file
            save(strcat(Main_Dir,filesep,File_Path,filesep,name_string,'.mat'),'output_array')

            %% Writing File

            new_file = strcat(Main_Dir,filesep,File_Path,filesep,name_string,'.txt');
            fid = fopen(new_file,'wt');

            % Wrinting the column heaaders
            fprintf(fid,strcat('Year',32));

            for y = 2:n
                fprintf(fid,strcat(array{1,y},32));
            end

            fprintf(fid,'\n');

            % Wrinting the data into the file
            for x = 1:size(avg_array,1)
                fprintf(fid,strcat(yr_array{x+5},32));
                for y = 1:n-1        
                    fprintf(fid,strcat(num2str(avg_array(x,y)),32));
                end
                fprintf(fid,'\n');
            end

            fclose(fid);

            clearvars -except Main_Dir Model_Fol File_Fol file_name file_idx fol_idx model_idx gong_flag 
        end
    end
end

%% End Gong
% Lets you know when the program finishes
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end