%
% Copyright 2011-2012 Ben Wojtowicz
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU Affero General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU Affero General Public License for more details.
%
%    You should have received a copy of the GNU Affero General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Function:    cmn_viterbi_decode
% Description: Viterbi decodes a convolutionally
%              coded input bit array using the
%              provided parameters
% Inputs:      in       - Input bit array
%              k        - Constraint length
%              r        - Rate
%              g        - Polynomial definition
%                         array in octal
% Outputs:     out      - Ouput bit array
% Spec:        N/A
% Notes:       N/A
% Rev History: Ben Wojtowicz 11/22/2011 Created
%              Ben Wojtowicz 01/29/2012 Fixed license statement
%              Ben Wojtowicz 02/19/2012 Added soft bit decoding
%
in= input_to_viterbi;
k= 7;
g= [133 171 165];
r = 3;

    % Check constraint length
    if(k > 9)
        printf("ERROR: Maximum supported constraint length = 9\n");
        out = 0;
        return;
    endif

    % Check r and g   check that g = [133 171 165]
    if(length(g) != r)
        printf("ERROR: Invalid rate (%u) or polynomial definition (%u)\n", r, length(g));
        out = 0;
        return;
    endif

    % Determine number of states

    num_states = 2^(k-1);
    % Convert g from octal to binary array
    g_array = cmn_oct2bin(g, k);

    %We will deal with k=7 as statedin the standard 
    %st_output is a metric that contains all the output on all links 
    st_output = [  0,0,0 ; 1,1,1;
   1,0,0;  0,1,1;
   0,0,1;  1,1,0;
   1,0,1;  0,1,0;
   1,1,0;  0,0,1;
   0,1,0;  1,0,1;
   1,1,1;  0,0,0;
   0,1,1;  1,0,0;
   1,1,1;  0,0,0;
   0,1,1;  1,0,0;
   1,1,0;  0,0,1;
   0,1,0;  1,0,1;
   0,0,1;  1,1,0;
   1,0,1;  0,1,0;
   0,0,0;  1,1,1;
   1,0,0;  0,1,1;
   0,1,1;  1,0,0;
   1,1,1;  0,0,0;
   0,1,0;  1,0,1;
   1,1,0;  0,0,1;
   1,0,1;  0,1,0;
   0,0,1;  1,1,0;
   1,0,0;  0,1,1;
   0,0,0;  1,1,1;
   1,0,0;  0,1,1;
   0,0,0;  1,1,1;
   1,0,1;  0,1,0;
   0,0,1;  1,1,0;
   0,1,0;  1,0,1;
   1,1,0;  0,0,1;
   3,  4;
   7,  0;
   7,  0;
   3,  4;
   6,  1;
   2,  5;
   1,  6;
   5,  2;
   0,  7;
   4,  3;
   0,  7;
   4,  3;
   1,  6;
   5,  2;
   6,  1;
   2,  5;
   7,  0;
   3,  4;
   4,  3;
   0,  7;
   5,  2;
   1,  6;
   2,  5;
   6,  1;
   3,  4;
   7,  0;
   3,  4;
   7,  0;
   2,  5;
   6,  1;
   5,  2;
   1,  6;
   4,  3;
   0,  7 ];    
    % Calculate branch and path metrics
    tf_state = zeros(num_states, (length(in)/r)+1);
    path_metric = zeros(num_states, (length(in)/r)+1); %% bug release
    for(n=0:(length(in)/r)-1) % in the i_th time 
        br_metric = zeros(num_states, 2); % the current path cost (hamming one) (branch_metric)
        p_metric  = zeros(num_states, 2); % the total path cost from the src to the i_th state
        w_metric  = zeros(num_states, 2); % for not sending 1,0 pair 

        for(m=0:num_states-1) % in the immediate state with index m
            % Calculate the accumulated branch metrics for each state
            for(o=0:1) % in path number o
                prev_state        = mod(bitshift(m, 1) + o, num_states);
                p_metric(m+1,o+1) = path_metric(prev_state+1,n+1); % initially must be zeros but the br_metric will add cost to me.
                st_arr            = cmn_dec2bin(st_output(m+o+1,:), r); % output generated from each state
                for(p=0:r-1)
                    if(in(n*r+p+1) == 0) %%% if (bit # x in the (in array) of index (r*n) == 0 or 1 ) or it uses actual data before demap?
                        in_bit = 0;
                    else
                        in_bit = 1;
                    endif
                    % compare bit to bit between the state array generated in the previous section and the incoming in array.
                    % mod(st_arr(p+1)+in_bit, 2) if the 2 bits are the same then mod = 0 if not it will generate hamming cost = 1 for that 
                    % bit and that path.  
                    br_metric(m+1,o+1) = br_metric(m+1,o+1) + mod(st_arr(p+1)+in_bit, 2);
                    w_metric(m+1,o+1)  = w_metric(m+1,o+1) + abs(in(n*r+p+1)); % for not sending 1,0 pair
                endfor
            endfor
            % ACS (Add- compare- select)
            % Keep the smallest branch metric as the path metric, weight the branch metric
            tmp1 = br_metric(m+1,1) + p_metric(m+1,1);
            tmp2 = br_metric(m+1,2) + p_metric(m+1,2);
            if(tmp1 > tmp2) 
                path_metric_new(m+1) = p_metric(m+1,2) + w_metric(m+1,2)*br_metric(m+1,2);
                tf_state(m+1,n+2) = prev_state;% +2 to start with state zero
            else
                path_metric_new(m+1) = p_metric(m+1,1) + w_metric(m+1,1)*br_metric(m+1,1);
                tf_state(m+1,n+2) = mod(bitshift(m, 1) + 0, num_states); % n+2 to start with state zero
            endif
        endfor
        path_metric(:,n+2) = path_metric_new'; 
    endfor
        % after the pevious loop we have now 2^(k)-1 minimum cost pathes and we wanna to pick up the minimum cost one.

    % Find the minimum metric for the last iteration (want to get the minimum path by searching in the last state which contains the total-
    % -pathes)
    init_min      = 1000000; 
    idx           = 1;
    tb_state(idx) = 1000000; % traceback state 
    for(n=0:num_states-1)
        if(path_metric(n+1,(length(in)/r)+1) < init_min)
            init_min      = path_metric(n+1,(length(in)/r)+1);
            tb_state(idx) = n;
        endif
    endfor
    idx = idx + 1;

    % Traceback to find the minimum path metrics at each iteration
    for(n=(length(in)/r)-1:-1:0)
        prev_state_0 = mod(bitshift(tb_state(idx-1), 1) + 0, num_states);
        prev_state_1 = mod(bitshift(tb_state(idx-1), 1) + 1, num_states);

        % Keep the smallest state
        if(path_metric(prev_state_0+1,n+1) > path_metric(prev_state_1+1,n+1))
            tb_state(idx) = prev_state_1;
        else
            tb_state(idx) = prev_state_0;
        endif
        idx = idx + 1;
    endfor

    % Read through the traceback to determine the input bits
    idx = 1;
    for(n=length(tb_state)-2:-1:0)
        % If transition has resulted in a lower valued state,
        % the output is 0 and vice-versa
        if(tb_state(n+1) < tb_state(n+1+1))
            out(idx) = 0;
        elseif(tb_state(n+1) > tb_state(n+1+1))
            out(idx) = 1;
        else
            % Check to see if the transition has resulted in the same state
            % In this case, if state is 0 then output is 0
            if(tb_state(n+1) == 0)
                out(idx) = 0;
            else
                out(idx) = 1;
            endif
        endif
        idx = idx + 1;
    endfor
