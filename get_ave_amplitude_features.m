%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% Generates average amplitude features%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script passes each signal through a bandpass filter and then
%calculates the average amplitude of the filtered signal for windows of
%various lengths and lags after the feedback event

clear
dir_info=loadjson('SETTINGS.json'); %get directory information
tic

%set up parameters for Butterworth bandpass filter
lb=1; %set lower frequency bound (Hz)
hb=20; %set higher frequency bound (Hz)
butt_ord=5; %order for the Butterworth filter
Wn = [lb/100, hb/100];  % Normalized cutoff frequency (as data sampled at 200hz)
[b,a]=butter(butt_ord,Wn);

%set up parameters for windows over which the average amplitude is to be calculated
length_vec=[10:10:130]; %Window lengths 
offset_vec=[0:10:250];  %Window lags

training_set=[2,6,7,11,12,13,14,16,17,18,20,21,22,23,24,26];  %vector of training subject ids
test_set=[1,3,4,5,8,9,10,15,19,25]; %vector of test subject ids

% EEG channels
chan_vec{1}='Time';%;  Timestamp of each sample
chan_vec{2}='Fp1';%: EEG samples recorded from Fp1
chan_vec{3}='Fp2';%: EEG samples recorded from Fp2
chan_vec{4}='AF7';%: EEG samples recorded from AF7
chan_vec{5}='AF3';%: EEG samples recorded from AF3
chan_vec{6}='AF4';%: EEG samples recorded from AF4
chan_vec{7}='AF8';%: EEG samples recorded from AF8
chan_vec{8}='F7';%: EEG samples recorded from F7
chan_vec{9}='F5';%: EEG samples recorded from F5
chan_vec{10}='F3';%: EEG samples recorded from F3
chan_vec{11}='F1';%: EEG samples recorded from F1
chan_vec{12}='Fz';%: EEG samples recorded from Fz
chan_vec{13}='F2';%: EEG samples recorded from F2
chan_vec{14}='F4';%: EEG samples recorded from F4
chan_vec{15}='F6';%: EEG samples recorded from F6
chan_vec{16}='F8';%: EEG samples recorded from F8
chan_vec{17}='FT7';%: EEG samples recorded from FT7
chan_vec{18}='FC5';%: EEG samples recorded from FC5
chan_vec{19}='FC3';%: EEG samples recorded from FC3
chan_vec{20}='FC1';%: EEG samples recorded from FC1
chan_vec{21}='FCz';%: EEG samples recorded from FCz
chan_vec{22}='FC2';%: EEG samples recorded from FC2
chan_vec{23}='FC4';%: EEG samples recorded from FC4
chan_vec{24}='FC6';%: EEG samples recorded from FC6
chan_vec{25}='FT8';%: EEG samples recorded from FT8
chan_vec{26}='T7';%: EEG samples recorded from T7
chan_vec{27}='C5';%: EEG samples recorded from C5
chan_vec{28}='C3';%: EEG samples recorded from C3
chan_vec{29}='C1';%: EEG samples recorded from C1
chan_vec{30}='Cz';%: EEG samples recorded from Cz
chan_vec{31}='C2';% EEG samples recorded from C2
chan_vec{32}='C4';%: EEG samples recorded from C4
chan_vec{33}='C6';%: EEG samples recorded from C6
chan_vec{34}='T8';%: EEG samples recorded from T8
chan_vec{35}='TP7';%: EEG samples recorded from TP7
chan_vec{36}='CP5';%: EEG samples recorded from CP5
chan_vec{37}='CP3';%: EEG samples recorded from CP3
chan_vec{38}='CP1';%: EEG samples recorded from CP1
chan_vec{39}='CPz';%: EEG samples recorded from CPz
chan_vec{40}='CP2';%: EEG samples recorded from CP2
chan_vec{41}='CP4';%: EEG samples recorded from CP4
chan_vec{42}='CP6';%: EEG samples recorded from CP6
chan_vec{43}='TP8';%: EEG samples recorded from TP8
chan_vec{44}='P7';%: EEG samples recorded from P7
chan_vec{45}='P5';%: EEG samples recorded from P5
chan_vec{46}='P3';%: EEG samples recorded from P3
chan_vec{47}='P1';%: EEG samples recorded from P1
chan_vec{48}='Pz';%: EEG samples recorded from Pz
chan_vec{49}='P2';%: EEG samples recorded from P2
chan_vec{50}='P4';%: EEG samples recorded from P4
chan_vec{51}='P6';%: EEG samples recorded from P6
chan_vec{52}='P8';%: EEG samples recorded from P8
chan_vec{53}='PO7';%: EEG samples recorded from PO7
chan_vec{54}='POz';%: EEG samples recorded from POz
chan_vec{55}='P08';%: EEG samples recorded from P08
chan_vec{56}='O1';%: EEG samples recorded from O1
chan_vec{57}='O2';%: EEG samples recorded from O2
chan_vec{58}='EOG';%: samples recorded from EOG derivation
chan_vec{59}='FeedBackEvent';%: a zero vector  except for each occurring feedback timestamp for which value is equal to one

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Training set%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get trial ids and training labels
data=readtable(strcat(dir_info.features, 'training_set_meta_features.csv'));
train=data(:,1);
get_label=data.label;


 
for l=2:58
chan=chan_vec{l};
for jj=1:length(offset_vec) %offset
       for ii=1:length(length_vec)
           if offset_vec(jj)+length_vec(ii)<261
                ave_collect=zeros(5440,1);
                row_count=0;
                   for sub=training_set
                        for j=1:5
                            sesh=j;
                            disp(sprintf('training data, length=%d, offset=%d, chan=%s, subject=%d, session=%d',length_vec(ii), offset_vec(jj), chan,sub,j))
        
                            if sub<10
                               data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh));            
                            else
                                data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh));            
                            end
        
                            data=readtable(data_path);
                            ind=find(data.FeedBackEvent==1);
                            data_filt=filter(b,a,eval(strcat('data.',chan)));  %filter data
                                for i=1:length(ind)
                                row_count=row_count+1;    
                                ave_collect(row_count)=mean(data_filt(ind(i)+offset_vec(jj):ind(i)+offset_vec(jj)+length_vec(ii)-1));
                                end
                       end
                    end
    
                eval(strcat('train.',sprintf('%s_L%d_O%d',chan,length_vec(ii),offset_vec(jj)),'=ave_collect;'))
            else
            end
        end
end
end

train.label=get_label; %add labels to training data
writetable(train,strcat(dir_info.features,'training_set_ave_amp_features.csv')) %save files

data=readtable(strcat(dir_info.features, 'test_set_meta_features.csv'));
test=data(:,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Test set%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



 
for l=2:58
chan=chan_vec{l};
for jj=1:length(offset_vec) %offset
       for ii=1:length(length_vec)
           if offset_vec(jj)+length_vec(ii)<261
                ave_collect=zeros(3400,1);
                row_count=0;
                   for sub=test_set
                        for j=1:5
                            sesh=j;
                            disp(sprintf('test data, length=%d, offset=%d, chan=%s, subject=%d, session=%d',length_vec(ii), offset_vec(jj), chan,sub,j))
        
                            if sub<10
                               data_path=strcat(dir_info.data,sprintf('Data_S0%d_Sess0%d.csv',sub,sesh));           
                            else
                                data_path=strcat(dir_info.data,sprintf('Data_S%d_Sess0%d.csv',sub,sesh));           
                            end
        
                            data=readtable(data_path);
                            ind=find(data.FeedBackEvent==1);
                            data_filt=filter(b,a,eval(strcat('data.',chan)));  %filter data
                                for i=1:length(ind)
                                row_count=row_count+1;    
                                ave_collect(row_count)=mean(data_filt(ind(i)+offset_vec(jj):ind(i)+offset_vec(jj)+length_vec(ii)-1));
                                end
                       end
                    end
    
                eval(strcat('test.',sprintf('%s_L%d_O%d',chan,length_vec(ii),offset_vec(jj)),'=ave_collect;'))
            else
            end
        end
end
end
writetable(test,strcat(dir_info.features,'test_set_ave_amp_features.csv')) %save files
toc
