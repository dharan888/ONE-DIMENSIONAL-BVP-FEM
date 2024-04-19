function [K,F] = system_assembly(alpha,beta,force,flux_node, ...
                                    nodal_flux,nodal_coord,element)
%% building halfbandwidth matrix
    nE = size(element,1); %number of elements
    nN = length(nodal_coord); %number of nodes
    w = size(element,2)-4; %half band width
    K = zeros(nN,w); %initializing K
    F = zeros(nN,1); %initializing F

    for i = 1:nE
        el = element(i,4); %type of element: 1-linear and 2-quadrilateral
        node_i = element(i,5);
        node_j = element(i,end);
        L = nodal_coord(node_j)-nodal_coord(node_i);
        alpha_grp = element(i,1);
        beta_grp = element(i,2);
        force_grp = element(i,3);
        a = alpha(alpha_grp);
        b = beta(beta_grp);
        f = force(force_grp);
        [Ke, Fe] = element_matrix(a,b,f,L,el);
        w = size(Ke,2);
        K(node_i:node_j,1:w) = K(node_i:node_j,1:w) + Ke;
        F(node_i:node_j) = F(node_i:node_j) + Fe;
    end

    if ~isempty(nodal_flux)
        F(flux_node)=nodal_flux;
    end 
end