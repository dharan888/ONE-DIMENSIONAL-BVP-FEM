function [K,F] = apply_bound_condns(K,F,BC)
   w = size(K,2);
%% applying left boundary condition
    cond_type = left_BC(1);
    if cond_type == 1
       d = left_BC(2);
       F(1:w) = F(1:w) - transpose(K(1,:))*d;
       F(1) = []; K(1,:) = [];
    elseif cond_type == 2
       f = left_BC(3);
       F(1) = F(1) + f;
    else
       c = left_BC(2);
       d = left_BC(3);
       K(1,1) = K(1,1) - c;
       F(1) = F(1) + d;
    end
 %% applying right boundary condition
    cond_type = right_BC(1);
    if cond_type == 1
       d = right_BC(2);
       n = size(F,1);
       st = n-1; 
       en = n-w+1;
       for i = st:-1:en
           F(i) = F(i) - K(i,n-i+1)*d;
       end
       F(end) = []; K(end,:) = [];
    elseif cond_type == 2
       f = right_BC(3);
       F(end) = F(end) + f;
    else
       c = right_BC(2);
       d = right_BC(3);
       K(end,1) = K(end,1) + c;
       F(end) = F(end) - d;
    end
end