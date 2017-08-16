function [ M2_e1, AUC_e1, AUC_i1 ] = C1_ensemble_score1( type, training_cell, subdir, test_cell, range, sizes, num_epochs, num_partition, alpha )
%A4O_OUTPUT_SCORE Summary of this function goes here
%   Detailed explanation goes here

%first level ensemble: combine 20 individual DNNs


if nargin<1
    type='Pooled';  % Pooled or Separate type for training model
end
if nargin<2
    training_cell = 'Helas3CytosolPap';   
end
if nargin<3
    subdir =  strcat('Sequence_',type,'_for_Input_Data_chr');   % sub-directory of directory 'Raw_Data' which contains test data 
end
if nargin<4
    test_cell = 'Helas3CellPap';   
end
if nargin<5
    range=20;   % 20 or 50 
end
if nargin<6
    sizes = [1000 100];   %structure of DNN. defualt: [100]; optimal:[1000 100]
end
if nargin<7
    num_epochs = 50;   % 50 
end
if nargin<8
    num_partition=20;   
end
if nargin<9
    alpha=250000;   % number of resampling with replacment each time.
end

indir='/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/DeepRed_Code_from_LiuFeng/';
dir_in=strcat(indir,'Model_learnt_for_Sequence_',type,'_chr');
dir_out=strcat(indir,'Score');
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/Score_',type);
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/',subdir);
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/',test_cell);
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

size_flag=[];
for i=1:length(sizes)
    size_flag=strcat(size_flag,'_',num2str(sizes(i)));
end
size_flag=size_flag(2:end);
flag=strcat('bagging_',num2str(alpha),'alpha');

disp( ['rang=' num2str(range) 'bp; num_epochs=' num2str(num_epochs) '; num_partition=' num2str(num_partition)]);
fprintf('\n');

disp( strcat('Training model:',training_cell) );
load( strcat(dir_in,'/Model_learnt_for_',training_cell, ...
    '/ensemble_model.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',num2str(range),'bp.mat') );
disp( strcat('Test data:',test_cell) );
load( strcat(indir,'Raw_Data/',subdir,'/training_data.',test_cell,'.100bp.mat'),'feature','label' );

mid=(size(feature,2)/4+1)/2;
ind=4*(mid-range-1)+1:4*(mid+range);
feature=feature(:,ind);
disp(strcat(num2str(size(feature,2)),'-D'));

if exist(strcat(dir_out,'/M2_e1.',training_cell,'.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',num2str(range),'bp.mat'),'file')
    load( strcat(dir_out,'/M2_e1.',training_cell,'.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',num2str(range),'bp.mat'),'M2_e1','AUC_e1','AUC_i1');
else
    [ M2_e1, AUC_e1, ~, ~, ~, ~, ~, AUC_i1, ~, ~ ] = performance_evaluation_of_ROC(stackedAEOptTheta_i,output1_i,output2_i,output3_i,feature,label);
    save( strcat(dir_out,'/M2_e1.',training_cell,'.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',num2str(range),'bp.mat'),'M2_e1','AUC_e1','AUC_i1');
end

disp(AUC_e1);





end

