function [ M2_e4, AUC_e4, AUC_e3, AUC_e2, AUC_e1, AUC_i1 ] = C4_ensemble_score4( subdir, test_cell, range, sizes, num_epochs, num_partition, alpha )
%A4O_OUTPUT_SCORE Summary of this function goes here
%   Detailed explanation goes here

%forth level ensemble: combine results of Pooled and Separate data


if nargin<1
    subdir =  strcat('Sequence_Pooled_for_Input_Data_chr');   % sub-directory of directory 'Raw_Data' which contains test data 
end
if nargin<2
    test_cell = 'Helas3CellPap';   
end
if nargin<3
    range=[20 50];   % [20 50] to combine results of 20bp and 50bp
end
if nargin<4
    sizes = [1000 100];   %structure of DNN. defualt: [100]; optimal:[1000 100]
end
if nargin<5
    num_epochs = 50;   % 50 
end
if nargin<6
    num_partition=20;   
end
if nargin<7
    alpha=250000;   % number of resampling with replacment each time.
end


% training_cell={'BjCellLongnonpolya','Gm12878CytosolPap','Helas3CytosolPap','Hepg2CellPap','Hepg2CytosolLongnonpolya','NhekNucleusLongnonpolya'};
training_cell={'BjCellLongnonpolya','Gm12878CytosolPap','Gm12878NucleusLongnonpolya','Helas3CytosolPap','Helas3NucleusPap',...
            'Hepg2CellPap','Hepg2CytosolLongnonpolya','MCF7CellPap','NhekNucleusLongnonpolya','NhekNucleusPap','SknshraCellLongnonpolya'};

types={'Pooled','Separate'};   

indir='/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng/';
dir_out=strcat(indir,'Score');
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/Score_combined');
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/',subdir);
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
% dir_out=strcat(dir_out,'/',test_cell);
% if ~exist(dir_out,'dir')
%     mkdir(dir_out);
% end

size_flag=[];
for i=1:length(sizes)
    size_flag=strcat(size_flag,'_',num2str(sizes(i)));
end
size_flag=size_flag(2:end);
flag=strcat('bagging_',num2str(alpha),'alpha');

disp( ['range=' num2str(range) 'bp; num_epochs=' num2str(num_epochs) '; num_partition=' num2str(num_partition)]);
fprintf('\n');

range_flag=[];
for i=1:numel(range)
    range_flag=strcat(range_flag,'_',num2str(range(i)));
end
range_flag=range_flag(2:end);

disp( strcat('Test data:',subdir,'/',test_cell) );

load( strcat(indir,'Raw_Data/',subdir,'/training_data.',test_cell,'.100bp.mat'), 'label');
M2_e4=[];
AUC_e3=[];
AUC_e2=[];
AUC_e1=[];
AUC_i1=[];
for i=1:numel(types)
    disp( strcat('type:',types{i}) );

    if exist(strcat(dir_out,'../../Score_',types{i},'/',subdir,'/',test_cell,'/M2_e3.',num2str(numel(training_cell)),'cells.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.mat'),'file')
        temp=load( strcat(dir_out,'../../Score_',types{i},'/',subdir,'/',test_cell,'/M2_e3.',num2str(numel(training_cell)),'cells.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.mat'),'M2_e3','AUC_e3','AUC_e2','AUC_e1','AUC_i1');
        M2_e3=temp.M2_e3;
        AUC_e3={AUC_e3,temp.AUC_e3};
        AUC_e2={AUC_e2,temp.AUC_e2};
        AUC_e1={AUC_e1,temp.AUC_e1};
        AUC_i1={AUC_i1,temp.AUC_i1};
    else
        [ M2_e3, AUC_e3{i}, AUC_e2{i}, AUC_e1{i}, AUC_i1{i} ] = C3_ensemble_score3( types{i}, subdir, test_cell, range, sizes, num_epochs, num_partition, alpha ); 
    end

    M2_e4=cat(3,M2_e4,M2_e3);  

end
M2_e4=mean(M2_e4,3);
[~,~,~,AUC_e4] = perfcurve(label,M2_e4(:,1),1);

disp(AUC_e4);
save( strcat(dir_out,'/Score_predicted.',test_cell,'.mat'),'M2_e4','AUC_e4','AUC_e3','AUC_e2','AUC_e1','AUC_i1');
dlmwrite(strcat(dir_out,'/Score_predicted.',test_cell,'.txt'),M2_e4(:,1));





end

