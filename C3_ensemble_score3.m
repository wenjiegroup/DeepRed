function [ M2_e3, AUC_e3, AUC_e2, AUC_e1, AUC_i1 ] = C3_ensemble_score3( type, subdir, test_cell, range, sizes, num_epochs, num_partition, alpha )
t0=clock
tic
%A4O_OUTPUT_SCORE Summary of this function goes here
%   Detailed explanation goes here

%third level ensemble: combine results of 11 training cells


if nargin<1
    type='Pooled';  % Pooled or Separate type for training model
end
if nargin<2
    subdir =  strcat('Sequence_',type,'_for_Input_Data_chr');   % sub-directory of directory 'Raw_Data' which contains test data 
end
if nargin<3
    test_cell = 'Helas3CellPap';   
end
if nargin<4
    range=[20 50];   % [20 50] to combine results of 20bp and 50bp
end
if nargin<5
    sizes = [1000 100];   %structure of DNN. defualt: [100]; optimal:[1000 100]
end
if nargin<6
    num_epochs = 50;   % 50 
end
if nargin<7
    num_partition=20;   
end
if nargin<8
    alpha=250000;   % number of resampling with replacment each time.
end


% training_cell={'BjCellLongnonpolya','Gm12878CytosolPap','Helas3CytosolPap','Hepg2CellPap','Hepg2CytosolLongnonpolya','NhekNucleusLongnonpolya'};
training_cell={'BjCellLongnonpolya','Gm12878CytosolPap','Gm12878NucleusLongnonpolya','Helas3CytosolPap','Helas3NucleusPap',...
            'Hepg2CellPap','Hepg2CytosolLongnonpolya','MCF7CellPap','NhekNucleusLongnonpolya','NhekNucleusPap','SknshraCellLongnonpolya'};

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

disp( ['range=' num2str(range) 'bp; num_epochs=' num2str(num_epochs) '; num_partition=' num2str(num_partition)]);
fprintf('\n');

range_flag=[];
for i=1:numel(range)
    range_flag=strcat(range_flag,'_',num2str(range(i)));
end
range_flag=range_flag(2:end);

disp( strcat('Test data:',test_cell) );
load( strcat(indir,'Raw_Data/',subdir,'/training_data.',test_cell,'.100bp.mat'), 'label');
M2_e3=[];
AUC_e2=[];
AUC_e1=[];
AUC_i1=[];
for i=1:numel(training_cell)
    disp( strcat('Training model:',training_cell{i}) );

    if exist(strcat(dir_out,'/M2_e2.',training_cell{i},'.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.mat'),'file')
        temp=load( strcat(dir_out,'/M2_e2.',training_cell{i},'.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.mat'),'M2_e2','AUC_e2','AUC_e1','AUC_i1');
        M2_e2=temp.M2_e2;
        AUC_e2=cat(3,AUC_e2,temp.AUC_e2);
        AUC_e1=cat(3,AUC_e1,temp.AUC_e1);
        AUC_i1=cat(3,AUC_i1,temp.AUC_i1);
    else
        [ M2_e2, AUC_e2(:,:,i), AUC_e1(:,:,i), AUC_i1(:,:,i) ] = C2_ensemble_score2( type, training_cell{i}, subdir, test_cell, range, sizes, num_epochs, num_partition, alpha ); 
    end
    
    M2_e3=cat(3,M2_e3,M2_e2);  
  
end
M2_e3=mean(M2_e3,3);
[~,~,~,AUC_e3] = perfcurve(label,M2_e3(:,1),1);

disp(AUC_e3);

save( strcat(dir_out,'/M2_e3.',num2str(numel(training_cell)),'cells.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.mat'),'M2_e3','AUC_e3','AUC_e2','AUC_e1','AUC_i1');


%my change
log_dir=strcat('/home/ouyang/ShortProject/ShortProject1_DeepRed_from_LiuFeng/2_Assessment_by_SEQC/runtime_compare/DeepRed/matlab_cputime','/Score_',type);
if ~exist(log_dir,'dir')
    mkdir(log_dir);
end

log_dir=strcat(log_dir,'/',test_cell);
if ~exist(log_dir,'dir')
    mkdir(log_dir);
end

fid=fopen(strcat(log_dir,'/M2_e3.',num2str(numel(training_cell)),'cells.',test_cell,'.s',size_flag,'_i',num2str(num_epochs),'.',flag,num2str(num_partition),'.',range_flag,'bp.log'),'w+')

%t1=cputime-t0
t1=etime(clock,t0)
T=strcat('tictoc_time:',num2str(toc),' etime:',num2str(t1))
fprintf(fid,'%s\n',T)
fclose(fid)

end
