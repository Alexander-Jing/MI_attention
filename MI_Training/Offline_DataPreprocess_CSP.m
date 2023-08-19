function [random_X, random_Y] = Offline_DataPreprocess_CSP(rawdata, classes)

    assert(classes == 2, "CSP only supports binary classification.")
    
    %% �ɼ�����
    sample_frequency = 256;
    seconds_per_trial = 8; 
    data_points_per_trial = sample_frequency * seconds_per_trial;
    
    WindowLength = 512;  % ÿ�����ڵĳ���
    SlideWindowLength = 256;  % �������
    
    Trigger = rawdata(end,:); %rawdata���һ��
    IdleRawData = flipud(double(rawdata(1:end-1,Trigger==1)));   %flipud�������·�ת��Size=32x122880(256Hz*8sec*20trial/action*3sets of data=25600)
    WalkRawData = flipud(double(rawdata(1:end-1,Trigger==2)));
    AscendRawData = flipud(double(rawdata(1:end-1,Trigger==3)));
    DescendRawData = flipud(double(rawdata(1:end-1,Trigger==4)));

    trials_per_action = size(IdleRawData,2) / data_points_per_trial;  % ÿ�ද��Trial������,3 set data,=20*3
    windows_per_trial = (data_points_per_trial - WindowLength) / SlideWindowLength + 1;  % ����trial������Ĵ�����,((2048-512)/256)+1=7

    % shape: (1, number of windows in all trials)
    IdleSlideSample = cell(1, windows_per_trial * trials_per_action); %IdleSlideSample:1x420 cells (420=7windows/trial*20trial/test*3tests)
    WalkSlideSample = cell(1, windows_per_trial * trials_per_action);
    AscendSlideSample = cell(1, windows_per_trial * trials_per_action);
    DescendSlideSample = cell(1, windows_per_trial * trials_per_action);
    
    %% ��������󣬽�ÿ������������ȡ��
    % channels = [3:32]; 
    channels = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]; 
    number_of_channels = length(channels);
    
    for i = 1:trials_per_action
        
        for j = 1:windows_per_trial
            % ÿ�ද����20trial*3test��*7windows=420����������
            PointStart = (i-1)*data_points_per_trial + (j-1)*SlideWindowLength;
            IdleSlideSample{1, (i-1)*windows_per_trial+j} = IdleRawData(channels,PointStart + 1:PointStart + WindowLength );
            WalkSlideSample{1, (i-1)*windows_per_trial+j} = WalkRawData(channels,PointStart + 1:PointStart + WindowLength );
            AscendSlideSample{1, (i-1)*windows_per_trial+j} = AscendRawData(channels,PointStart + 1:PointStart + WindowLength );
            DescendSlideSample{1, (i-1)*windows_per_trial+j} = DescendRawData(channels,PointStart + 1:PointStart + WindowLength );
        end
        
    end

    %% �˲�Ԥ����
    FilterOrder = 4;
    
%     Wband = [[1,6];[6,11];[11,16];[16,21];[21,26];[26,31];[31,36]];
    Wband = [[8,12];[12,30]];
    number_bandpass_filters = size(Wband,1);
    FilterType = 'bandpass';

    assert(size(IdleSlideSample,2) == size(WalkSlideSample,2) && size(WalkSlideSample,2) == size(AscendSlideSample,2) && size(AscendSlideSample,2) == size(DescendSlideSample,2));
    assert(size(IdleSlideSample,2) == size(WalkSlideSample,2) && size(WalkSlideSample,2) == size(AscendSlideSample,2));
    
    windows_per_action = size(IdleSlideSample,2); %window_per_action=��20trial*3test��*7windows=420

    % shape: (number of bandpass filters, windows per action)
    IdleFilterSample = cell(number_bandpass_filters, windows_per_action); % 2 Filtered Freq Bands * 420 Windows
    WalkFilterSample = cell(number_bandpass_filters, windows_per_action);
    AscendFilterSample = cell(number_bandpass_filters, windows_per_action);
    DescendFilterSample = cell(number_bandpass_filters, windows_per_action);

    for i = 1:windows_per_action
        
        for j = 1:number_bandpass_filters
            IdleFilterSample{j,i} = Rsx_ButterFilter(FilterOrder,Wband(j,:),sample_frequency,FilterType,IdleSlideSample{1,i},number_of_channels);
            WalkFilterSample{j,i} = Rsx_ButterFilter(FilterOrder,Wband(j,:),sample_frequency,FilterType,WalkSlideSample{1,i},number_of_channels);
            AscendFilterSample{j,i} = Rsx_ButterFilter(FilterOrder,Wband(j,:),sample_frequency,FilterType,AscendSlideSample{1,i},number_of_channels);
            DescendFilterSample{j,i} = Rsx_ButterFilter(FilterOrder,Wband(j,:),sample_frequency,FilterType,DescendSlideSample{1,i},number_of_channels);
        end
        
    end
    
    idle_samples_all = IdleFilterSample;
    walk_samples_all = WalkFilterSample;
    ascend_samples_all = AscendFilterSample;
    descend_samples_all = DescendFilterSample;
    


    %% CSP��CSPֻ����2���࣬for 4�������2�������Σ�
    CspTranspose = cell(1,number_bandpass_filters);
    
    for i = 1:number_bandpass_filters
        CspTranspose{i} = Rsx_CSP_R3(idle_samples_all(i,:),walk_samples_all(i,:));  
        % ��ȡCSP����CSP��������ά��Ϊ����1*2 bands�� cells��30*30/cell��
    end
    
    save('CspTranspose_Train.mat','CspTranspose');
    FilterNum = 2;

    assert(size(idle_samples_all, 2) == size(walk_samples_all, 2) && size(walk_samples_all, 2) == windows_per_action);
    number_of_windows_idle = size(idle_samples_all, 2);
    number_of_windows_walk = size(walk_samples_all, 2);
    number_of_windows_ascend = size(ascend_samples_all, 2);
    number_of_windows_descend = size(descend_samples_all, 2);

    % shape: (windows per action, number of bandpass filters * FilterNum)
    IdleTrainFea = [];
    WalkTrainFea = [];
    AscendTrainFea = [];
    DescendTrainFea = [];

    for i = 1:number_of_windows_idle %ÿ��window��ÿ��freq band����������ȡ
        FeaTemp = [];
        for j =1:number_bandpass_filters
            FeaTemp = [FeaTemp,Rsx_singlewindow_cspfeature(idle_samples_all{j,i},CspTranspose{j},FilterNum)];
            % Ϊ CspTranspose * idle_samples_all���õ��ö�����������
        end
        IdleTrainFea = [IdleTrainFea; FeaTemp]; %IdleTrainFea:420x4
    end

    for i = 1:number_of_windows_walk
        FeaTemp = [];
        for j =1:number_bandpass_filters
            FeaTemp = [FeaTemp,Rsx_singlewindow_cspfeature(walk_samples_all{1,i},CspTranspose{j},FilterNum)];
        end
        WalkTrainFea = [WalkTrainFea; FeaTemp];
    end

    for i = 1:number_of_windows_ascend
        FeaTemp = [];
        for j =1:number_bandpass_filters
            FeaTemp = [FeaTemp,Rsx_singlewindow_cspfeature(ascend_samples_all{1,i},CspTranspose{j},FilterNum)];
        end
        AscendTrainFea = [AscendTrainFea; FeaTemp];
    end
    
    for i = 1:number_of_windows_descend
        FeaTemp = [];
        for j =1:number_bandpass_filters
            FeaTemp = [FeaTemp,Rsx_singlewindow_cspfeature(descend_samples_all{1,i},CspTranspose{j},FilterNum)];
        end
        DescendTrainFea = [DescendTrainFea; FeaTemp];
    end
    
    if classes == 2
        X = [IdleTrainFea; WalkTrainFea;]; %X=features:840x4
%         Y = [ones(number_of_windows_idle / windows_per_trial, 1); ones(number_of_windows_walk / windows_per_trial, 1) + 1;];  % classes: 1 or 2 (for combined windows)
        Y = [ones(number_of_windows_idle, 1); ones(number_of_windows_walk, 1) + 1;];  % classes: 1 or 2
        
    elseif classes == 3
        X = [IdleTrainFea; WalkTrainFea; AscendTrainFea];
        Y = [ones(number_of_windows_idle, 1); ones(number_of_windows_walk, 1) + 1; ones(number_of_windows_ascend, 1) + 2];
        
    elseif classes == 4
        X = [IdleTrainFea; WalkTrainFea; AscendTrainFea; DescendTrainFea];
        Y = [ones(number_of_windows_idle, 1); ones(number_of_windows_walk, 1) + 1; ones(number_of_windows_ascend, 1) + 2; ones(number_of_windows_descend, 1) + 3]; 
    end
    
    
%     % combine the the windows of each trial. Permute the matrix first so
%     % that the reshape function works as expected, then permute back to the
%     % original shape.
%     X_combine_windows = permute(reshape(permute(X, [2, 1]), size(X, 2) * windows_per_trial, size(X, 1) / windows_per_trial), [2, 1]); 
%     % =permute(reshape[((4x840��X),4*7,840/7)],[2,1])
%     % size=120x28
%     % make sure the combinations are correct
%     assert(all([X(1 * 7 + 1, :), X(1 * 7 + 2, :), X(1 * 7 + 3, :), X(1 * 7 + 4, :), X(1 * 7 + 5, :), X(1 * 7 + 6, :), X(1 * 7 + 7, :)] == X_combine_windows(2, :)))
%     assert(all([X(119 * 7 + 1, :), X(119 * 7 + 2, :), X(119 * 7 + 3, :), X(119 * 7 + 4, :), X(119 * 7 + 5, :), X(119 * 7 + 6, :), X(119 * 7 + 7, :)] == X_combine_windows(120, :)))

    
    % random order
    random_index = randperm(size(Y, 1));
%     random_X = X_combine_windows(random_index, :); %ά��Ϊ120*28 for 2 class (120=3tests*20trials/test*2actions; 28=2bands*2most sig features*7windows)
    random_X = X(random_index, :);
    random_Y = Y(random_index, :);

end


