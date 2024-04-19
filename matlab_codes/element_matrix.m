function [Ke, Fe] = element_matrix(a,b,f,L,elem_type)
    if elem_type==1
        Ke_alpha = (a/L)*[1 -1;1 0];
        Ke_beta  = (b*L/6)*[2 1;2 0];
        Ke = Ke_alpha + Ke_beta;
        Fe = (f*L/2)*[1;1];
    else
        Ke_alpha = (a/(3*L))*[7 -8 1;16 -8 0;7 0 0];
        Ke_beta  = (b*L/30)*[4 2 -1;16 2 0;4 0 0];
        Ke = Ke_alpha + Ke_beta;
        Fe = (f*L/6)*[1;4;1];
    end
end
