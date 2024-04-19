function F = system_solver(K,F,d_known)
% system_solver solves positive definite matrix system 
%   K - halfbanded stiffness matrix with size n by w (half band width)
%   F - force/flux values
%   Outputs D - diplacement or temperature values
    
%% parameters
    tol = 1e-6; % tolerance limit for the pivotal values
    n = size(K,1); % size of the stiffness matrix
    w = size(K,2); % half band width 

%% applying boundary conditions
    nodes       = d_known(:,1);
    d           = d_known(:,1);
    F(nodes)    = d;
    nNodes      = length(nodes);
    vec         = zeros(1,w);
    vec(1)      = 1;
    for p = 1:nNodes
        i       = nodes(p);
        K(i,:)  = vec;
        col     = 2;
        for row = i-1:-1:1
            K(row,col)  = 0;
            col         = col + 1;
        end
    end

%% factorization
    for i = 1:n
        %finding D_hat values
        st_p = max(i-w+1,1);
        en_p = i-1;
        for p = st_p:en_p
            K(i,1) = K(i,1) - (K(p,i-p+1)^2)*K(p,1); 
        end
        % checking whehter the pivot values lesser than the tolerance
        if K(i,1) <= tol
           F=[];
           disp("pivot values are closer to zero"); 
           return % exiting the function
        end
        %finding L_ij values
        st_j = i+1;
        en_j = min(i+w-1,n);
        for j = st_j:en_j
            st_p = max(j-w+1,1);
            en_p = i-1;
            for p = st_p:en_p
                K(i,j-i+1) = K(i,j-i+1) - K(p,j-p+1)*K(p,1)*K(p,i-p+1); 
            end
            K(i,j-i+1) = K(i,j-i+1)/K(i,1);
        end
    end
    %% forward substitution
    %finding Q values
    for i = 2:n
        st_p = max(i-w+1,1);
        en_p = i-1;
        for p = st_p:en_p
            F(i) = F(i) - K(p,i-p+1)*F(p);
        end
    end
    %% backward substitution
    %finding D values
    F(n) = F(n)/K(n,1);
    for i=n-1:-1:1
        F(i) = (F(i)/K(i,1));
        st_j = i+1;
        en_j = min(i+w-1,n);
        for j = st_j:en_j
            F(i) = F(i) - K(i,j-i+1)*F(j);
        end
    end  
end