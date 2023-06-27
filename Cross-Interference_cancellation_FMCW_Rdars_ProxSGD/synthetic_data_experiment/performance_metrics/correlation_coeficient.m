function corr_coef = correlation_coeficient(data_set1,data_set2)

corr_coef = ((data_set2)'*(data_set1))*(1/(norm(data_set2)*norm(data_set1)));

end