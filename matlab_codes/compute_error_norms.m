function [error_norms, Fs] = compute_error_norms(K,F,D,d_known)
    n = size(K,1);
    w = size(K,2); % half band width 
    for i = 1:n
        Fc = 0; 
        for j = 1:n
            if i < j
                if (j-i) < w
                    Fc = Fc + K(i,j-i+1)*D(j);
                end
            else
                if (i-j) < w
                    Fc = Fc + K(j,i-j+1)*D(j);
                end
            end
        end   
    end
    nodes       = d_known(:,1);
    Fs          = Fc(nodes);
    F(nodes)    = [];
    Fc(nodes)   = [];
    err         = F - Fc; 
    R_norm = sqrt(err'*err);
    F_norm = sqrt(F'*F);
    error_norms = [R_norm,R_norm/F_norm];
end