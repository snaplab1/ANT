function  [output] = cln_cmdlinemsg(longest_text,input,filler)
    greeting2 = longest_text ;
    greeting = input;
    g_len = strlength(greeting);
    g_len2 = strlength(greeting2);
    d_len = g_len2-g_len;
    if ~mod(d_len,2) == 1
        len_add1 = round(d_len/2);
        len_add2 = len_add1;
    else
        len_add1 = round(d_len/2)-1;
        len_add2 = round(d_len/2);
    end
    chk = filler;
    chk_init1 = chk;
    for ii = 1:(len_add1)
    chk_init1 = strcat(chk_init1,chk);
    end
    clear ii
    chk_init2 = chk;
    for ii = 1:(len_add2)
    chk_init2 = strcat(chk_init2,chk);
    end
    clear ii

    greeting = strcat(chk_init1," ",greeting," ",chk_init2,'\n');
    output = greeting;
end
