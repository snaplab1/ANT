% This is just for doing some scratch calculations to try to work out the 
% how to ensure we get a balanced number of each type of trial


trialprop = cell(numtrials,9);  % pre-allocate
% populate trialprop matrix
%%(12 basic trial types)
trprop(1,:)={'N','T','','C','','','','',''};
trprop(2,:)={'N','B','','C','','','','',''};
trprop(3,:)={'N','T','','I','','','','',''};
trprop(4,:)={'N','B','','I','','','','',''};

trprop(5,:)={'C','T','','C','','','','',''};
trprop(6,:)={'C','B','','C','','','','',''};
trprop(7,:)={'C','T','','I','','','','',''};
trprop(8,:)={'C','B','','I','','','','',''};

trprop(9,:)={'S','T','','C','','','','',''};
trprop(10,:)={'S','B','','C','','','','',''};
trprop(11,:)={'S','T','','I','','','','',''};
trprop(12,:)={'S','B','','I','','','','',''};
