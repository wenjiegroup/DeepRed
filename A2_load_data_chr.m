function [ ] = A2_load_data_chr( range, directory )
%A1_LOAD_DATA Summary of this function goes here
%   Detailed explanation goes here

if nargin<1
    range=100;   % -100bp~100bp
end
if nargin<2
    directory='Population_seq_for_Input_Data_chr';
end

dir_in=strcat('Raw_Data/',directory);
files=dir(dir_in);
% all.feature=[];
% all.label=[];
% all.training_x=[];
% all.training_y=[];
for i=1:numel(files)
    if isempty( regexp(files(i).name,'^input_data.+\.txt$', 'once') )
        continue;
    end
    
    temp=regexp(files(i).name,'\.', 'split');
    cell=temp{2};
    disp(cell);

    data=load( strcat(dir_in,'/input_data.',cell,'.txt') ); % RNA editing: 1; SNP: -1; other: 0,2,3,4
    feature=data(:,1:end-1);    % 804-D: -100b~100b;  404-D: -50b~50b;   164-D: -20b~20b
    label=data(:,end);

    mid=(size(feature,2)/4+1)/2;
    ind=4*(mid-range-1)+1:4*(mid+range);
    feature=feature(:,ind);
    disp(strcat(num2str(size(feature,2)),'-D'));

    ind_positive=find(label==1);
    ind_negative=find(label==-1);
    ind_other=find(label>=0 & label~=1);
    disp( strcat('P:',num2str(length(ind_positive)),';N:',num2str(length(ind_negative)),';O:',num2str(length(ind_other)) ) );

    label(ind_positive)=1;
    label(ind_negative)=2;
    label(ind_other)=3;
    order=[ind_positive; ind_negative; ind_other];
    training_x=feature(order,:);
    training_y=label(order);
    
    chr_ind=load( strcat(dir_in,'/chr_ind.',cell,'.txt') );
    training_z=chr_ind(order);  % index of chromosome


    % q=quantile(training_x,[0 1]);
    % training_x = bsxfun(@minus,training_x,q(1,:));
    % training_x = bsxfun(@rdivide,training_x,q(2,:)-q(1,:));
    % feature = bsxfun(@minus,feature,q(1,:));
    % feature = bsxfun(@rdivide,feature,q(2,:)-q(1,:));
    % ind_remove=find(q(1,:)==q(2,:));
    % feature(:,ind_remove)=[];
    % training_x(:,ind_remove)=[];

    % 
    % training_x=training_x(1:2*length(find(training_y==1)),:);
    % training_y=training_y(1:2*length(find(training_y==1)),:);
    save(strcat(dir_in,'/training_data.',cell,'.',num2str(range),'bp.mat'),'training_x','training_y','training_z','feature','label','-v7.3');            
    
%     all.feature=[all.feature; feature];
%     all.label=[all.label; label];
%     all.training_x=[all.training_x; training_x];
%     all.training_y=[all.training_y; training_y];
end
% feature=all.feature;
% label=all.label;
% training_x=all.training_x;
% training_y=all.training_y;
% save(strcat(dir_in,'/training_data.All8.',num2str(rang),'bp.mat'),'training_x','training_y','feature','label','-v7.3');            
 


end

