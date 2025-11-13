
% get location of the "main" directory (directory housing this script..)
startDirTmp=pwd; % save initial path..
current_versionTmp = 'antWelcome.m'; % will need to update with versioning..
antVersion="ANTmain3.m";
scrptDir = fileparts(which(current_versionTmp));
% cd to it..
cd(scrptDir);
% enter data dir and save absolute path..


%% Set up welcome banner

% Vector-o-rediculous-greetings
greeting_vect = {"Howdy, partner!","Ahoy, matey!","Avast m'harties!","Peek-a-boo!","Ello, gov'nor!","What's crackin?","Sup, homeslice?","Greetings and salutations.","Howdy, howdy, howdy!","Whaddup?!?","Shiver me timbers!","Ello, mate.","Why, hello there!","Aloha!", "Shalom","Que pasa Mufasa?","Bonjour!","Hallo", "Hei Hei! Hvorden har du det?","Ciao","Konnichiwa","Hiya!","Howdy-doody!","Yeeeeeeee Haaaawww!", "Yoooooouuu Hooooooo!!!!","Top of the mornin, to ya!","What's the word, hummingbird?","Hola, como estas?", "Hello! Is this the person to whom I'm speaking?", "What it do buckaroo?", "Greetings Comrade!","Good day mortals!","What's the word baby birds?","Guten Tag!","What's kickin, chicken?", "What's shakin, bacon?", "So... we meet at last!", "Greetings friend!","Peace be with you","Ayyyyyyoooooooooooooo!", "Shhaaaaaazzzzaaaaaammm!", "I BELIEVE IN A THING CALLED LOVE! JUSTLISTENTOTHERHYTHMOFYAHEEAAARRRT!!... ehhem.. excuse me...", "And I Said .. Heeyyyyaaaayahhyayaya..", "My regards to your superiors.", "Welcome to my humble abode.", "Greetings Earthlings!", "Fancy meeting you here!", "Welcome to chaos!", "Shalomie my homie!", "Wake up Neo... The Matrix has you...", "It was best of times. It was the worst of times.", "I'm glad that you are here with me. Here at the end of all things.", "Lets get down to business! To complete.. some runs!", "Haaaallp! Get me out of here!","Pax Hominibus.. Peace on the Minibus.","Stop monkeying around and get to work!", "This experiment bears the indelible stamp of our lowly origins..", "What is up my scallywagz?","Och aye the noo!","Velkommen!","Hou ar ye?", "I came in like a wreeeeecking balll!!!"};
n_greetings = length(greeting_vect);
ran_idx = randi([1,n_greetings]);

greeting = greeting_vect{1,ran_idx};
brk_line = '-----------------------------------------------------------------------------------------------\n';
greeting2 = 'This is the main script for running ANT experiments';
ref_str = brk_line;

%% Run interactive CLI for selecting/starting the experiment

% 1) Welcome Screen
pauseDuration=0.05; % Controls the rate at which the banner image "scrolls out"
asciiMatPath=strcat(scrptDir,"/asciiBannerIms/asciiArt.mat"); % path to mat of asciis..
fprintf('\n');
randAsciiArt(asciiMatPath,pauseDuration)
greeting1=cln_cmdlinemsg(ref_str,greeting,"-");
fprintf(greeting1);
greeting2=cln_cmdlinemsg(ref_str,greeting2,"-");
fprintf(greeting2);
versionmsg = strcat("(",antVersion, ", Written by: A.S. Greenberg PhD, and E.J. Duwell PhD)");
versionmsg = cln_cmdlinemsg(ref_str,versionmsg,"-");
fprintf(versionmsg);
continuemsg = cln_cmdlinemsg(ref_str,"Press Enter/Return to Continue...", "-");
fprintf(continuemsg);
input("",'s');
cd(startDirTmp);
