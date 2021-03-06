function [  ] = B1_train_individual_classifier( type, cell, range, sizes, numepochs, idx_partition, alpha   )
%A2_TRAIN Summary of this function goes here
%   Detailed explanation goes here

if nargin<1
    type='Pooled';  % Pooled or Separate
end
if nargin<2
    cell='Helas3CytosolPap';    % cell used for training
end
if nargin<3
    range=20;   % defualt: 20; optimal:-20bp~20bp + -50bp~50bp. base pairs upstream/downstream of the target base pair used for training
end
if nargin<4
    sizes = [1000 100];   %structure of DNN. defualt: [100]; optimal:[1000 100]
end
if nargin<5
    numepochs = 50;   % number of epochs. defualt: 50; optimal: 50
end
opts.numepochs=numepochs;
if nargin<6
    idx_partition=20;   % the index of individual DNNs. defualt:20; if the total number of individual DNNs is N, then the index can be 1~N.
end
if nargin<7
    alpha=250000;   % number of resampling with replacment each time.
end



disp(['loading training data of ', cell]);
fprintf('\n');
load(strcat('Raw_Data/Sequence_',type,'_for_Input_Data_chr/training_data.',cell,'.100bp.mat'),'training_x','training_y','training_z');


mid=(size(training_x,2)/4+1)/2;
ind=4*(mid-range-1)+1:4*(mid+range);
training_x=training_x(:,ind);
disp(strcat(num2str(size(training_x,2)),'-D'));


dir_out=strcat('Model_learnt_for_Sequence_',type,'_chr');
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
dir_out=strcat(dir_out,'/Model_learnt_for_',cell);
if ~exist(dir_out,'dir')
    mkdir(dir_out);
end
if ~exist(strcat(dir_out,'/temp'),'dir')
    mkdir(strcat(dir_out,'/temp'));
end


addpath(genpath('./Matlab_code_of_DeepRed/'));

size_flag=[];
for i=1:length(sizes)
    size_flag=strcat(size_flag,'_',num2str(sizes(i)));
end
size_flag=size_flag(2:end);


%% train individual models
rng('shuffle');
ind_rand_positive=[];
ind_rand_negative=[];
ind_rand_other=[];

for chr_ind=1:23    % 23 chromosomes: 1-22 and X
    ind_positive_chr=find(training_y==1 & training_z==chr_ind);
    ind_negative_chr=find(training_y==2 & training_z==chr_ind);
    ind_other_chr=find(training_y==3 & training_z==chr_ind);
    
    flag=strcat('bagging_',num2str(alpha),'alpha');
    num_samples=round(alpha/23);
    ind_rand_positive_chr=randi(length(ind_positive_chr),num_samples,1); % resample negative samples with replacment
    ind_rand_negative_chr=randi(length(ind_negative_chr),num_samples,1); % resample negative samples with replacment
    ind_rand_other_chr=randi(length(ind_other_chr),num_samples,1); % resample negative samples with replacment    

    ind_rand_positive=[ind_rand_positive; ind_positive_chr(ind_rand_positive_chr)];
    ind_rand_negative=[ind_rand_negative; ind_negative_chr(ind_rand_negative_chr)];
    ind_rand_other=[ind_rand_other; ind_other_chr(ind_rand_other_chr)];
end
    
disp( ['sizes=[' num2str(sizes) ']; numepochs=' num2str(opts.numepochs) '; idx_partition=' num2str(idx_partition) '; flag=' flag]);
fprintf('\n');


if exist(strcat(dir_out,'/temp/individual_model','.s',size_flag,'_i',num2str(opts.numepochs),'.',flag,num2str(idx_partition),'.',num2str(range),'bp.mat'),'file')
    return;
end

% nlabs=matlabpool('size');
% if ~nlabs
%     matlabpool open;
% end
% parfor i=1:idx_partition      % the tranining procedure of DNN is very time-cosuming and the number of DNNs is very large, so we use PBS to submit multiple jobs on clusters 
for i=idx_partition
    disp( ['DNN model: ' num2str(i) ' of ' num2str(idx_partition)] );

    %%train individual models
    training_x_i=training_x([ind_rand_positive;ind_rand_negative;ind_rand_other],:);
    training_y_i=training_y([ind_rand_positive;ind_rand_negative;ind_rand_other]);
    
    training_x=[];
    training_y=[];

    [ ~,stackedAEOptTheta_i{i},output1_i{i},output2_i{i},output3_i{i},T_i(i) ] = supervisedlearnig(training_x_i,training_y_i,training_x_i,training_y_i,sizes, 0, opts); %% the main learning function of DNN
    fprintf('\n');
    
end
% nlabs=matlabpool('size');
% if nlabs
%     matlabpool close;
% end

save(strcat(dir_out,'/temp/individual_model','.s',size_flag,'_i',num2str(opts.numepochs),'.',flag,num2str(idx_partition),'.',num2str(range),'bp.mat'),...
    'stackedAEOptTheta_i','output1_i','output2_i','output3_i','T_i','-v7.3');  %% save individual models


% %% evaluate ROC related of ensemble model and individual models on training set
% [ M2_e, AUC_e, OPTROCPT_e, GM_MAX_e, CUTOFF1_e, CUTOFF2_e, M2_i, AUC_i, OPTROCPT_i, GM_MAX_i ] = performance_evaluation_of_ROC(stackedAEOptTheta_i,output1_i,output2_i,output3_i,training_x,training_y);
% 
% %% evaluate ensemble model on training set at a output cutoff
% [ performance_e ] = ensemble_performance_evaluation_at_a_cutoff(stackedAEOptTheta_i,output1_i,output2_i,output3_i,cutoff,training_x,training_y,feature);
% 
% %% evaluate individual models on training set at a output cutoff (optional, for inner test)
% for i=1:idx_partition
%     [ performance_i{i} ] = individual_performance_evaluation_at_a_cutoff(stackedAEOptTheta_i{i},output1_i{i},output2_i{i},output3_i{i},cutoff,training_x,training_y,feature);
% end
% 
% 
% save(strcat(dir_out,'/ensemble_model','.s',size_flag,'_i',num2str(opts.numepochs),'.',flag,num2str(idx_partition),'.mat'),...
%     'stackedAEOptTheta_i','output1_i','output2_i','output3_i',...
%     'AUC_e','OPTROCPT_e','GM_MAX_e','CUTOFF1_e','CUTOFF2_e','AUC_i','OPTROCPT_i','GM_MAX_i',...
%     'performance_e','performance_i','-v7.3');  %% save individual models, their performance and ensemble performance


end






