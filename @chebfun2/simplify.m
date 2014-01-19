function f = simplify( f ) 
% Simplify a chebfun2 

% Simplify the column and row slices. 
f.cols = simplify( f.cols ); 
f.rows = simplify( f.rows ); 

% TODO: Simplify the rank.  

end 