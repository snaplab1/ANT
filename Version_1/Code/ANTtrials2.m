 function [trialprop] = ANTtrials2(numtrials,percentVal)

%
% ANTtrials1.m
% function for ANT fMRI experiment: generate block of trials
%
% Structure of Data Array:
%
%			 | cue type| targ locn | targ dir| flankers | flank dir| CTI | ITI | cueValidity | cueLocation
% trialprop: -------------------------------------------------------------------       | for spatial cues:
%			 | Spatial,| Top,      | Left,   |Congruent,| Right,   | see vars  |V (valid)    | T or B (top/bottom)
%			 | Center, | Bottom	   | Right   |			    | Left	   | below	   |I (invalid)  | for central/no cues:
%	  	 | None	   |     	     | 		     |Incongr.  |		       |		       |N (none)     | C or N (placeholder)
%			 -------------------------------------------------------------------
%
% Written by Adam Greenberg, UWM/Psych(Neuro)
% August, 2018

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

% shuffle it up
rp1 = randperm(size(trprop,1));
newtrprop(:,:) = trprop(rp1,:);

%%make enough to go around
allprop1 = trprop;
allprop = allprop1;
% allCTI1 = Shuffle([300,300,300,550,800,1050,1550,2300,3300,4800,6550,11800]);
allCTI1 = Shuffle([300,300,300,300,300,300,300,300,300,300,300,300]);
allCTI = allCTI1;
% allITI1 = Shuffle([1000,1250,1500,1750,2000,2500,3000,3500,4500,6000,8000,13000]);
allITI1 = Shuffle([1000,1750,2500,1000,1750,2500,1000,1750,2500,1000,1750,2500]);
allITI = allITI1;
for xx=1:(ceil(numtrials/12)-1)
    allprop = [allprop;allprop1];
	allCTI = [allCTI,allCTI1];
	allITI = [allITI,allITI1];
end;
for xx=1:(ceil(numtrials/12)-1)
	allCTI = [allCTI,allCTI1];
	allITI = [allITI,allITI1];
end;
%truncate for just the number we need (if it wasn't an integer multiple of 12)
trialprop1(1:numtrials,:) = allprop(1:numtrials,:);

% shuffle once more
rp2 = randperm(size(trialprop1,1));
trialprop(:,:) = trialprop1(rp2,:);
rp3 = randperm(size(trialprop1,1));
CTI = allCTI(rp3);
rp4 = randperm(size(trialprop1,1));
ITI = allITI(rp4);

%choose target direction, other logic, and distribute CTI/ITI
tdtemp = ones(numtrials/2,1);
targdir = [tdtemp; tdtemp*2];
td = Shuffle(targdir);

for xxx=1:numtrials
    switch td(xxx) % set target dir
        case 1
            trialprop{xxx,3} = 'L';
			switch trialprop{xxx,4}
				case 'C'
					trialprop{xxx,5} = 'L';
				case 'I'
					trialprop{xxx,5} = 'R';
			end;
        case 2
            trialprop{xxx,3} = 'R';
			switch trialprop{xxx,4}
				case 'C'
					trialprop{xxx,5} = 'R';
				case 'I'
					trialprop{xxx,5} = 'L';
			end;
    end;

  if trialprop{xxx,1} == 'S'
  % Do nothing for now. Will loop back after and fill in
  % valid/invalid cons for spatial cue condition
  elseif trialprop{xxx,1} == 'N'
  trialprop{xxx,8} = 'N';
  trialprop{xxx,9} = 'N';
  elseif trialprop{xxx,1} == 'C'
  trialprop{xxx,8} = 'C';
  trialprop{xxx,9} = 'C';
  end
	trialprop{xxx,6} = CTI(xxx);
	trialprop{xxx,7} = ITI(xxx);
end;


% Cue validity: generate vector of 1s/2s in proportion to requested
% percent valid/invalid.
scIdx=cell2mat(trialprop(:,1))=='S';
nSC=sum(scIdx);
nValid=round(nSC*percentVal);
nInValid=nSC-nValid;
cValtemp1=ones(nValid,1);
cValtemp2=ones(nInValid,1)*2;
cueVal=[cValtemp1; cValtemp2];
cueVal=Shuffle(cueVal);

% Loop through and fill in valid/invalid stuff for spatial cue conditions..
countr=1;
for ii=1:length(scIdx)
  if scIdx(ii)==1
    switch cueVal(countr)
    case 1 % Valid Conditions
      trialprop{ii,8} = 'V'; % valid set to 'V'
      trialprop{ii,9} = trialprop{ii,2}; % set cue location to same as target
    case 2 % Invalid Conditions
      trialprop{ii,8} = 'I';
      if trialprop{ii,2} == 'T'
      trialprop{ii,9} = 'B';
      elseif trialprop{ii,2} == 'B'
      trialprop{ii,9} = 'T';
      end
    end
    countr=countr+1;
  else
    trialprop{ii,9}=trialprop{ii,2}; % if this isn't a spatial cue set equal to cue column..
  end
end
clear countr;

end
