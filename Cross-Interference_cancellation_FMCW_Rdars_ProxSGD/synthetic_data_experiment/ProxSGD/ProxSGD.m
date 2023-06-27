function [delta_X] = ProxSGD(X,lambda,initial_step_size,limit,maxIter)

[N,L] = size(X);


% Initial Correction matrices for gradient descent
delta_X = zeros(size(X));

% Complex Correction matrix of previous iteration
delta_X_previous = zeros(size(X));

% Normalized DFT matrix
F1 = dftmtx(N)/sqrt(N); % Range
F2 = dftmtx(L)/sqrt(L); % Doppler
step = (initial_step_size); % step size

for loop = 1:maxIter
    %     tic;
  
    Z_c = F1*(X - delta_X_previous)*transpose(F2); % 

    S_sgn = complex(sign(real(Z_c)),sign(imag(Z_c)));
 
    Gsub = conj(F1)*S_sgn*conj(F2);
   
    delta_X = delta_X_previous + step*Gsub;
    delta_X = complex(soft_thresholding(real(delta_X), lambda),soft_thresholding(imag(delta_X), lambda));

  
%     % Exit/stopping criterion
%     delta_X_relchange = norm(delta_X - delta_X_previous)/norm(delta_X_previous);
%     %fprintf('Iteration = %d, \t step: %d ,\t obj val: %d \n',loop, step, optimizing_funct_value_itr(loop));
%     
%     %fprintf('Iteration = %d, \t G1: %d \t G2 = %d\n',loop, norm(G1), norm(G2));
%     if(delta_X_relchange*100 < limit)
%         break
%     end
   
    %     toc;
       
%    delta_X_relchange_vec(loop) = delta_X_relchange;

   % prepare for next iteration
   delta_X_previous = delta_X;

end


end





