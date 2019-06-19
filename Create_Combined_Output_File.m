%% Program Info

% This program takes the time series files and combines them into a single
% file, taking only the desired locations values
% also outputs the data array for use in Matlab

% Used for model output

% Processes one ensemble member at a time
% As each ensemble member has their own set files/dates to be combined

% This program takes a very long time

%%%%%%%%%%%%%% 
% This program plays a loud gong when finished
% To disable set this flag to false
gong_flag = true;

clearvars -except gong_flag

%% Inputs

% Location Data
% Might need to change when changing models
% Location data is consistent across ensembles
lon_range = [283, 287];       %range of longitudes
lat_range = [40, 44];     %range of latitudes

        
% Filename Prefix
file_name_pre = 'tasmin_day_CanESM2_historical_r1i1p1_';

% File Date Range Names
file_name_dates = {'18500101-20051231'};

% Filename Suffix
file_name_suf = '_NE_ts';

% Main Directory
Main_Dir = 'C:\Users\Trevor Riot\Documents\College Stuff\Research\Hunter Research';

% Model Folder
Model_Fol = 'cmip5_may15_2018';

% File Folder
File_Fol = '5.1_cccma_canesm2_tasmin_output';

% Static File Name - sonsistent across ensemble members
static_file = 'cccma_canesm2_NE_static.txt';

    
%% Program Start

% File Directory
File_Dir = strcat(Main_Dir,filesep,Model_Fol,filesep,File_Fol);


% Parsing the Static-Data to deterimine locations
fid = fopen(strcat(File_Dir,filesep,static_file));   
c = textscan(fid,'%s','delimiter','\n');
fclose(fid);
lines = c{1};
static_data = [];
for x = 1:length(lines)
    if ~isempty(lines{x})
        parsenumbers = textscan(lines{x},'%f');
        numbers = parsenumbers{1};
        if ~isempty(numbers)
            static_data = [static_data;numbers.'];
        end
    end
    clearvars parsenumbers numbers
end

clearvars lines c fid

% Determining Available Longitude and Latitude
lon_vect = unique(static_data(:,1));
lat_vect = unique(static_data(:,2));

loc_num = length(lon_vect)*length(lat_vect);        %total number of locations

% Determining  Lon and Lat Values
lon = lon_vect(lon_vect >= lon_range(1) & lon_vect <= lon_range(2));
lat = lat_vect(lat_vect >= lat_range(1) & lat_vect <= lat_range(2));

% Determining PX Values for Lon-Lat Locations
Pidx = [];

for x = 1:length(lon)
    for y = 1:length(lat)
        temp_idx = find(static_data(:,1) == lon(x) & static_data(:,2) == lat(y));
        Pidx = [Pidx,temp_idx-1];
        clearvars temp_idx
    end
end

% Read each file and add to string array

string_cell = [];

for x = 1:length(file_name_dates)
    file_name = strcat(file_name_pre,file_name_dates{x},file_name_suf,'.txt');
    
    fid = fopen(strcat(File_Dir,filesep,file_name));
    c = textscan(fid,'%s','delimiter','\n');
    fclose(fid);
    lines = c{1};
    
    if (x == 1)
        string_cell = [string_cell;lines];
    else
        string_cell = [string_cell;lines(2:end,:)];
    end
    
    clearvars c lines file_name fid
end

% Splits each string in string array into individual parts
% Creates main output array

output_array = [];

for x = 1:length(string_cell)
    data_cell = strsplit(string_cell{x});
    temp_array = data_cell;
    
    output_array = [output_array; temp_array];
    
    clearvars data_cell temp_array
end

% Removing Unwanted Columns i.e Locations

for x = loc_num+6:-1:7
 
    if ismember((x-7),Pidx)
        continue
    else
        output_array(:,x) = [];
    end

end

output_array(:,6) = []; %Removes time of day column

% Adjusting Temperature Data
c = textscan(file_name_pre,'%s','delimiter','_');
pre_string = c{1};

if ~strcmp(pre_string{1},'pr')
    for x = 6:size(output_array,2)
        for y = 2:size(output_array,1)
            output_array{y,x} = num2str(str2double(output_array{y,x}) - 273);
        end
    end
end

clearvars c pre_string

% Writing New File

new_file = strcat(File_Dir,filesep,file_name_pre,'FULL',file_name_suf,'.txt');
fid = fopen(new_file,'wt');

for x = 1:length(output_array)
    for y = 1:length(Pidx)+5
        
        fprintf(fid,strcat(output_array{x,y},32));
    end
    fprintf(fid,'\n');
end

fclose(fid);
clearvars y 

% Saving the year-value array to a matlab usable file
save(strcat(File_Dir,filesep,file_name_pre,'FULL',file_name_suf,'.mat'),'output_array')


%% End GOng
% Lets you know when the program finishes
if (gong_flag == true)
    load('gong.mat');
    soundsc(y,Fs);
end