function [ functional_data ] = FDAfit(datavector,timevector,splinestruct,estimation_type,lambda,Lfd_object,weight_vector,timemulti)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if exist('timemulti','var') == 0
    timemulti = 5;
end
switch(estimation_type)
    case('simple')
        rng = [splinestruct.knots(1),splinestruct.knots(end)];
        functional_data.basis_functions = create_bspline_basis(rng,splinestruct.nbasis,splinestruct.norder,splinestruct.knots);
        error_order = splinestruct.norder -2;
        if error_order < 1
            error_order = 1;
        end
%set up roughness penalty smoothing function
        if exist('Lfd_object','var') == 0
            Lfd_object = int2Lfd(error_order); %penalizes the N-2th derivative, helps estimate acceleration functions
        elseif isempty(Lfd_object)
            Lfd_object = int2Lfd(error_order); %penalizes the N-2th derivative, helps estimate acceleration functions            
        end
        if exist('lambda','var') == 0
            lambda = 1e-1;%default cost
        end
        functional_data.smoothing_parameter = fdPar(functional_data.basis_functions,Lfd_object,lambda);
%smooth data and return functional data object
        if exist('weight_vector','var')
            if isempty(weight_vector) == 0
                %use the specified weighted vector to weight the smoothing
                functional_data.smoothdata = smooth_basis(timevector,datavector,functional_data.smoothing_parameter,weight_vector);
            else
                functional_data.smoothdata = smooth_basis(timevector,datavector,functional_data.smoothing_parameter);
            end
        else
            functional_data.smoothdata = smooth_basis(timevector,datavector,functional_data.smoothing_parameter);
        end
%generate fine predictions for data,velocity,and acceleration
        functional_data.timefine = linspace(rng(1),rng(2),length(splinestruct.knots)*timemulti);
        functional_data.datafine = eval_fd(functional_data.timefine,functional_data.smoothdata);
        functional_data.velfine = eval_fd(functional_data.timefine,functional_data.smoothdata,1);
        functional_data.accfine = eval_fd(functional_data.timefine,functional_data.smoothdata,2);
%extract the calculated fit and store the residuals and coefficients
        functional_data.fit = eval_fd(timevector,functional_data.smoothdata);
        functional_data.residuals = datavector - functional_data.fit;
        functional_data.coeffs = getcoef(functional_data.smoothdata);
        functional_data.datavector = datavector;
        functional_data.timevector = timevector;
end
end

