%% Extract Station Data

% Extracts the station data 
% Saves the relevant data in a Matlab array

% This array is then used by the other programs
% Do not remove array from its file destination

% Do not use for models

% Can run multiple station data files

%%%%%%%%%%%%%% 
% This program plays a loud gong when finished
% To disable set this flag to false
gong_flag = true;

clearvars -except gong_flag

%% Inputs

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

% Data Folder
File_Fol = 'catskills_sta_data_may15_2018';

%File Name 
file_name = {'catskill_compare_stations_june2017_PRCP_combined_final',...
             'catskill_compare_stations_june2017_TMAX_combined_final',...
             'catskill_compare_stations_june2017_TMIN_combined_final'};

%% Program Start

for file_idx = 1:length(file_name)
    % File Directory
    File_Path = strcat(Main_Dir,filesep,File_Fol,filesep,file_name{file_idx},'.txt');

    % Loading data file under a specific name
    if ~exist(File_Path)
        continue      %Skips to next iteration if the file isnt in this file path
    end
            
    % Reading the File
    fid = fopen(File_Path);
    c = textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    string_cell = c{1};

    clearvars fid c

    % Splitting the Strings into a data cell
    data_array = [];

    for x = 1:length(string_cell)
        data_cell = strsplit(string_cell{x});
        temp_array = data_cell;

        data_array = [data_array; temp_array];

        clearvars temp_array data_cell
    end

    % Replacing 99999 with NaN and Adjusting Precipitation data
    c = textscan(file_name{file_idx},'%s','delimiter','_');
    test_str = c{1};
    flag = false;

    for x = 1: length(test_str)
        if strcmp(test_str{x},'PRCP')
            flag = true;
        end
    end

    if (flag  == true)
        for x = 2:size(data_array,1)
            for y = 5:size(data_array,2)
                if (str2double(data_array{x,y}) == 99999)
                    data_array{x,y} = NaN;
                else
                    data_array{x,y} = num2str(str2double(data_array{x,y})*10);
                end
            end
        end
    else
        for x = 2:size(data_array,1)
            for y = 5:size(data_array,2)
                if (str2double(data_array{x,y}) == 99999)
                    data_array{x,y} = NaN;
                end
            end
        end
    end

    % Create year fraction column
    yr_frac{1,1} = 'yr-fraction';

    for x = 2:size(data_array,1)
        if (mod(str2double(data_array{x,1}),4) == 0)
            yr_frac{x,1} = str2double(data_array{x,1}) + str2double(data_array{x,2})/366;
        else
            yr_frac{x,1} = str2double(data_array{x,1}) + str2double(data_array{x,2})/365;
        end
    end

    % Puts array in proper order for plotting program
    data_array = horzcat(data_array(:,1),yr_frac,data_array(:,3:4),data_array(:,2),data_array(:,5:end));

    % Saves the Data Array
    save(strcat(Main_Dir,filesep,File_Fol,filesep,file_name{file_idx},'.mat'),'data_array')
    
    clearvars -except gong_flag Main_Dir File_Fol file_name file_idx
end

%% End Gong
% Lets you know when the program finishes
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end
