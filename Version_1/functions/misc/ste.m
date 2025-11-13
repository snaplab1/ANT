function sterr = ste(data)

%% Each Column will be treated as dataset

DataSize = size(data);

if ismember(1,DataSize)
    N = max(size(data));
    StdDev = nanstd(data);
    sterr = StdDev/sqrt(N);
else
    NumCols = size(data,2);
    N = size(data,1);
    
    for i = 1:NumCols
       StdDev = nanstd(data(:,i));
       sterr(1,i) = StdDev/sqrt(N);
    end
    
end