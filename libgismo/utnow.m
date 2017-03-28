function utdnum=utnow()
% UTNOW
%    ut_datenum = utnow()
%    Return a MATLAB datenum corresponding to the current UT time/date.
%    Uses Unix date command, so should work on Linux, Solaris & MacOS.  
%
%    It is a convenient way to compute UTC regardless of whether summer
%    time applies.
%
%    Caveats: 
%	Currently only configured for 'AKDT' and 'AKST'. If your Unix
%	timezone is anything else, you need to add cases.
%
%    See also datenum, now

%    Author: Glenn Thompson
    persistent hour_adjust; % assumes time zone is UTC  i.e. GMT
    if isempty(hour_adjust) % look up first time only
        atomtime = get_atomic_time();
        [status, unixnowstr] = system('date +"%Y-%m-%d %H:%M:%S"');
        unixnow = datenum(unixnowstr);
        hour_adjust = round(24 * (unixnow - atomtime));
    end

    if isunix
        [status, unixnowstr] = system('date +"%Y-%m-%d %H:%M:%S"');
        unixnow = datenum(unixnowstr);
        [status, unixnowTZ] = system('date +"%Z"'); 
        unixnowTZ = unixnowTZ(1:end-1); % chomp
        switch unixnowTZ
%             case 'BST'
%                 utdnum = unixnow - 1/24;
            case 'AKDT'
                utdnum = unixnow + 8/24;
            case 'AKST'
                utdnum = unixnow + 9/24;
            otherwise
                utdnum = unixnow + hour_adjust;
        end
    else
        disp('utnow: Sorry, your system does not support the Unix date command.')
    end

end


function atomTime = get_atomic_time()
    URL = 'http://tycho.usno.navy.mil/cgi-bin/timer.pl';
    atomTime = datenum(regexp(urlread(URL), ...
        '<BR>(.*)\sUTC','tokens','once'),'mmm. dd, HH:MM:SS');
end

