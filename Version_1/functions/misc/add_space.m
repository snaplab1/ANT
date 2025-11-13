function  [output] = add_space(longest_text,input,filler)
    greeting2 = longest_text ;
    greeting = input;
    g_len = strlength(greeting);
    g_len2 = strlength(greeting2);
    d_len = g_len2-g_len;

    len_add1 = round((g_len2/4)-6);

    chk = filler;
    chk_init1 = chk;
    for ii = 1:(len_add1-1)
    chk_init1 = strcat(chk_init1,chk);
    end
    clear ii

    greeting = strcat(chk_init1,greeting," ");
    output = greeting;
end
