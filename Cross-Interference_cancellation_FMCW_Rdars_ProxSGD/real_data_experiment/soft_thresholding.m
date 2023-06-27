function Y = soft_thresholding (X,lambda)

    Y = zeros(size(X));
    
    supp = find(X > lambda);
    Y(supp) = X(supp) - lambda;
    
    supp = find(X < -1*lambda);
    Y(supp) = X(supp) + lambda;

end
