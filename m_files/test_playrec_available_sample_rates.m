function [sr_ok] = test_playrec_available_sample_rates(sr_to_try,out_ID,in_ID)
if 0
verbose = 1;

nsr = length(sr_to_try);
sr_ok = zeros(nsr,1);
for i= 1:nsr
    if playrec('isInitialised')
        playrec('reset')
    end
    try
        playrec('init', sr_to_try(i), out_ID, in_ID);
        sr_ok(i) = 1;
        if verbose
            fprintf ('   Initialising device at %dHz succeeded\n', sr_to_try(i));
        end
    catch
        if verbose
            fprintf ('   Initialising device at %dHz failed with error: %s\n', sr_to_try(i), lasterr);
        end
    end
end
if playrec('isInitialised')
    playrec('reset')
end
sr_ok = sr_to_try(sr_ok==1);
else
    sr_ok = sr_to_try;
end

