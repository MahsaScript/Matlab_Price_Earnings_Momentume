%save to mycmdout.txt
[status,cmdout]=system('curl -k https://finviz.com/screener.ashx?v=152&f=cap_smallover&ft=4&c=0,1,2,6,7,10,11,13,14,45,65');
file_id = fopen('mycmdout.txt', 'wt');
fwrite(file_id, cmdout, '*char');
fclose(file_id);

ii = 0; % stock counter

% search the source for the number of pages we'll have to search and then
% pull stock data
% tic
% load 'mycmdout.txt'
loop = 1;
fid = fopen('mycmdout.txt');
%--------We know that we have 411 pages =>numpages=411
% while loop<412  %Because There are 441 pages and it takes long time
%     
%     tline = fgetl(fid);
%     if length(tline) > 40
%         if strcmp(tline(1:40),'<option selected="selected" value=1>Page')
%             b1 = find(tline == '/'); b2 = find(tline == '<'); % string identifiers
%             numpages = str2double(tline(b1(1)+1:b2(2)-1)); % Number of pages with stock data
% %             loop = 0;
%             loop=loop+1;
%         end
%     end
% end
% fclose(file_id);
% toc
% 
loop = 1;
while loop
    tline = fgetl(fid);
    if length(tline) > 15
        if strcmp(tline(1:15),'<td height="10"') % stock table identifier
            ii = ii + 1; % increment stock counter
            % parse the data by first identifying symbols and then storing the
            %clear data
            rem = regexprep(tline,'</td>','`'); % replace all table data breaks with backticks (just an odd delimeter)
            stkraw = regexprep(rem,'<.*?>',''); % remove all remaining HTML data
            d1 = regexp(stkraw,'(`|>)'); % locate the backticks and unbalanced HTML
            tick(ii) = {stkraw(d1(2)+1:d1(3)-1)}; % ticker symbol
            name(ii) = {stkraw(d1(3)+1:d1(4)-1)}; % company name
            if stkraw(d1(5)-1) == 'B'
                capmult = 1000000000;
            else
                capmult = 1000000;
            end
%             mktcap(ii) = str2num(stkraw(d1(4)+1:d1(5)-2)) * capmult; % market cap     
            pe_s(ii) = {stkraw(d1(5)+1:d1(6)-1)}; % Price/Earnings 
            ps_s(ii) = {stkraw(d1(6)+1:d1(7)-1)}; % Price/Sales 
            pb_s(ii) = {stkraw(d1(7)+1:d1(8)-1)}; % Price/Book 
            pfcf_s(ii) = {stkraw(d1(8)+1:d1(9)-1)}; % Price/Free Cash Flow 
            div_s(ii) = {stkraw(d1(9)+1:d1(10)-2)}; % Dividend Yield
            mom_s(ii) = {stkraw(d1(10)+1:d1(11)-2)}; % 6-month relative price strength
            price_s(ii) = {stkraw(d1(12)+1:d1(13)-1)}; % Current stock price
        end
    end
    if ii > 0 && length(tline) < 10
        loop = 0;
    end
% loop=loop+1;
end
% 
% % Now that the first page of stocks (20) is exhausted, we have to start
% % advancing pages
% 
fclose(file_id);
numpages=4;
for jj = 2:numpages
   request_name = ['curl -k https://finviz.com/screener.ashx?v=152&f=cap_smallover&ft=4&r=' num2str(jj*20+1)  '&c=0,1,2,6,7,10,11,13,14,45,65'];

    [status,cmdout]=system(request_name);


    file_name = [num2str(jj)  'jj.txt'];
    file_id = fopen(file_name, 'wt');
    fwrite(file_id, cmdout, '*char');

    fid = fopen(file_name);
    loop = 1;
    stktrigger = 0; % can't use i as the trigger anymore

    while loop
%         tline = char(readLine(buffer));
        tline = fgetl(fid);
        if length(tline) > 15
            if strcmp(tline(1:15),'<td height="10"') % stock table identifier
                ii = ii + 1; % increment stock counter
                if stktrigger == 0
                    stktrigger = 1;
                end
                % parse the data by first identifying symbols and then storing the
                %clear data
                rem = regexprep(tline,'</td>','`'); % replace all table data breaks with backticks (just an odd delimeter)
                stkraw = regexprep(rem,'<.*?>',''); % remove all remaining HTML data
                d1 = regexp(stkraw,'(`|>)'); % locate the backticks and unbalanced HTML
                tick(ii) = {stkraw(d1(2)+1:d1(3)-1)}; % ticker symbol
                name(ii) = {stkraw(d1(3)+1:d1(4)-1)}; % company name
                if stkraw(d1(5)-1) == 'B'
                    capmult = 1000000000;
                else
                    capmult = 1000000;
                end
%                 mktcap(ii) = str2num(stkraw(d1(4)+1:d1(5)-2)) * capmult; % market cap
                pe_s(ii) = {stkraw(d1(5)+1:d1(6)-1)}; % Price/Earnings 
                ps_s(ii) = {stkraw(d1(6)+1:d1(7)-1)}; % Price/Sales 
                pb_s(ii) = {stkraw(d1(7)+1:d1(8)-1)}; % Price/Book 
                pfcf_s(ii) = {stkraw(d1(8)+1:d1(9)-1)}; % Price/Free Cash Flow 
                div_s(ii) = {stkraw(d1(9)+1:d1(10)-2)}; % Dividend Yield
                mom_s(ii) = {stkraw(d1(10)+1:d1(11)-2)}; % 6-month relative price strength
                price_s(ii) = {stkraw(d1(12)+1:d1(13)-1)}; % Current stock price
            end
        end
        if stktrigger > 0 && length(tline) < 10
            loop = 0;
        end
    end
    fclose(file_id);
%     loop=loop+1;
end
% 
% toc
% tic
% % Yahoo! finance reports EV/EBITDA on each stock's Key Statistics page.
% 
% % pre-allocate EV/EBITDA for speed -- how to preallocate cells?
% 
% 
for jj = 1:ii

	request_name = ['curl -k https://finance.yahoo.com/quote/' tick{jj} '/Key-Statistics'];

    [status,cmdout]=system(request_name);
    
    
    file_name = [num2str(jj)  'tick.txt'];
    file_id = fopen(file_name, 'wt');
    fwrite(file_id, cmdout, '*char');
    loop = 1;
    fid = fopen(file_name);
    while loop
%         tline = char(readLine(buffer));
        tline = fgetl(fid);
        str_expression  = ["There" "is" "no" "Key" "Statistics"];
        if ~isempty(regexpi(tline,str_expression,'match','once'))% non-financial file like a mutual fund
%         if regexp(tline,str_expression) % non-financial file like a mutual fund
            evebitda_s(jj) = {'1000'}; % artificially assign the evebitda value to something high.
            %disp([tick{jj} ' is a fund with no EV/EBITDA information']); % used for debug purposes
            break
        end
         str_expression  = ["Get" "Quotes" "Results" "for" ];
        if ~isempty(regexpi(tline,str_expression,'match','once')) % can't locate the ticker
            evebitda_s(jj) = {'1000'};
            break
        end
         str_expression  = ["Changed" "Ticker" "Symbol" ];
        if ~isempty(regexpi(tline,str_expression,'match','once')) % ticker symbol has been changed, ignore
            evebitda_s(jj) = {'1000'};
            break
        end
        if regexp(tline,'</html>') % reached the end of html, haven't found the data
            evebitda_s(jj) = {'1000'};
            break
        end
        if regexp(tline,'Enterprise.Value/EBITDA') % if the line contains EV/EBITDA info, grab it
            rem = regexprep(tline,'</td>','`'); % same as abefore, replace table breaks with a weird delimiter
            stkraw = regexprep(rem,'<.*?>',''); % remove all HTML data, leaving just the stock data
            d1 = regexp(stkraw,'`'); % locate backticks
            for kk = 1:numel(d1)-1
                if strcmp(stkraw(d1(kk)+1:d1(kk)+23),'Enterprise Value/EBITDA')
                    evebitda_s(jj) = {stkraw(d1(kk+1)+1:d1(kk+2)-1)};
                    break
                end
            end
            %disp([tick{jj} ' is good']); % used for debug purposes.
            break
        end
    end
    if mod(jj,100) == 0
        disp(['EV/EBITDA #' num2str(jj) ' of ' num2str(ii) ' completed.']); % track progress
    end
    fclose(fid);
end

% toc
% tic
% 
% BBY = zeros(1,ii); % preallocate buyback yield (BBY)

for mm = 1:ii
	request_name = ['curl -k https://finance.yahoo.com/q/cf?s=' tick{mm} '&ql=1'];

    [status,cmdout]=system(request_name);
    
    
    file_name = [num2str(mm)  'mm.txt'];
    file_id = fopen(file_name, 'wt');
    fwrite(file_id, cmdout, '*char');
    fid = fopen(file_name);
    
    lcount = 0;
    loop = 1;
    runningtot = 0;
    ll = 0;

    while loop
        tline = fgetl(fid);
%         tline = char(readLine(buffer));
        str_expression  = ["There" "is" "no" "Cash" "Flow"];
        if ~isempty(regexpi(tline,str_expression,'match','once')) % no data 
            break
        end
        str_expression  = ["Get" "Quotes" "Results" "for" ];
        if  ~isempty(regexpi(tline,str_expression,'match','once')) % can't locate the ticker
            break
        end
        str_expression  = ["Changed" "Ticker" "Symbol" ];
        if  ~isempty(regexpi(tline,str_expression,'match','once'))% ticker symbol has been changed, ignore
            break
        end
        if regexp(tline,'</html>') % We've reached the end of the html, the data's not here
            break
        end
        if regexp(tline,'Sale.Purchase.of.Stock') % contains the Sale/Purchase of Stock information
            if regexp(tline,'Net.Borrowings') % find if the line contains borrowings detail as well
                tline = regexprep(tline,'Net.Borrowings.*',''); % remove all extra data
            end
            tline = tline(regexp(tline,'Sale.Purchase.of.Stock'):end); % trim prior data.
            posneg = regexprep(tline,'(','-'); % determine buys or sells.  (X,XXX) becomes -X,XXX)
            nocommas = regexprep(posneg,',|)',''); % eliminates commas and close parens.  -X,XXX) becomes -XXXX
            remhtml = regexprep(nocommas,'<.*?>|&nbsp;',','); % remove HTML data and various markup, replacing them with commas
            starts = regexp(remhtml,',\d+,|,.\d+'); % locate the beginning of quarterly Sale Purchase Data points
            ends = regexp(remhtml,'\d,'); % locate the end of the quarterly Sale Purchase Data points
            for ll = 1:length(starts)
                runningtot = runningtot + str2double(remhtml(starts(ll)+1:ends(ll)))*1000; % Sum up all of the buys and sells
            end
            break
        end
    end
    fclose(fid);
%     BBY(mm) = -1*runningtot/mktcap(mm)*100; % Buy back yield as a percentage of current market cap
%     if mod(mm,100) == 0
%         disp(['BBY #' num2str(mm) ' of ' num2str(ii) ' completed.']); % track progress
%     end
end
% toc
% tic
% 
% % Now that all of the data is imported, let's find errors caused by
% % negative earnings or no dividends, etc.
% 
% 
% % Convert everything to workable numbers
pe = str2double(pe_s);
ps = str2double(ps_s);
pb = str2double(pb_s);
pfcf = str2double(pfcf_s);
div = str2double(div_s);
mom = str2double(mom_s);
price = str2double(price_s);
evebitda = str2double(evebitda_s);

% Identify and repair all NaNs.
badpe = find(isnan(pe));
badps = find(isnan(ps));
badpb = find(isnan(pb));
badpfcf = find(isnan(pfcf));
baddiv = find(isnan(div));
badmom = find(isnan(mom));
badev = find(isnan(evebitda));

% Find EV/EBITDA values < 0 (I'm not sure how this happens, but it happens
% and I don't like it!)
badev2 = find(evebitda < 0);

% artificially set P/E, P/S, P/B at 100000 for sorting purposes.  This value
% should be high enough (or low enough) where it automatically ranks them
% last/tied for last
pe(badpe) = 100000; 
ps(badps) = 100000;
pb(badpb) = 100000;
pfcf(badpfcf) = 100000;
div(baddiv) = 0; % no dividend paid
mom(badmom) = 0; % no positive price momentum
evebitda(badev) = 100000;
evebitda(badev2) = 100000;

% Define shareholder yield as dividend + buyback yield
% shyield = div + BBY;

% Rank stocks based on each metric

perank = ((-1*tiedrank(pe)/length(pe))+1)*100; % Rank P/E values, with the lowest getting 100
psrank = ((-1*tiedrank(ps)/length(ps))+1)*100; % Rank P/S values, with the lowest getting 100
pbrank = ((-1*tiedrank(pb)/length(pb))+1)*100; % Rank P/B values, with the lowest getting 100
pfcfrank = ((-1*tiedrank(pfcf)/length(pfcf))+1)*100; % Rank P/FcF values, with the lowest getting 100
% shyieldrank = tiedrank(shyield)/length(shyield)*100; % Rank shareholder yield values, with the highest getting 100
evrank = ((-1*tiedrank(evebitda)/length(evebitda))+1)*100; % Rank EV/EBITDA value, with the lowest getting 100

% stkrank = perank + psrank + pbrank + pfcfrank + shyieldrank + evrank; % Total stock valuation

% identify the top performing decile
% ovrrnk = tiedrank(stkrank)/length(stkrank);
% tops = find(ovrrnk > 0.9);

% sort top decile by price momentum
% momtops = tiedrank(mom(tops));
% mom_backup = mom; % just a backup for reference as we delete items from the original in the next step

% return top n stocks
% for kk = 1:25
%     topmom = find(mom == max(mom(tops))); % If two stocks have the same price momentum, it will return all of them, regardless of whether or not it's in the top decile
%     if numel(topmom) > 1 % check for multiple entries
%         for n = 1:length(topmom)
%             if ovrrnk(topmom(n)) > 0.9 % make sure the entry is in the top decile
%                 topmom = topmom(n);
%                 break
%             end
%         end
%     end
%     stk(kk) = topmom;
%     mom(topmom) = -100; % artificially decrease price momentum to -100% so that it's no longer the max in the data set
% end
% mom = mom_backup; % repair momentum variable for later analysis
% disp(tick(stk)); % If you've already run the script and just want to display the stocks, use tick(stk).  Also for specific data, like p/e of those, pe(stk).
% toc
pemomentume = ['Price Earning Momentume:' num2str(mean(perank)/length(perank))];
disp(pemomentume);



% Save the data for later use
svname = [date '_Stock_Data'];
% save(svname,'pe','perank','ps','psrank','pb','pbrank','pfcf','pfcfrank','evebitda','evrank','div','shyield','shyieldrank','stkrank','ovrrnk','mom','tick','name','price','stk')
save(svname,'pe','perank','ps','psrank','pb','pbrank','pfcf','pfcfrank','evebitda','evrank','div','tick','name','price')