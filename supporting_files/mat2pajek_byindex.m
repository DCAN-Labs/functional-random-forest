function mat2pajek_byindex(mat,ind,outputname,outputname2)
%mat2pajek_byindex(mat,ind,outputname)
%
% This takes a matrix, a list of indices within the matrix that survive
% some threshold, and a name for the output, and writes the graph in the
% pajek format, which is used in Pajek (for windows only), and also for
% some compiled versions of things, like Infomap. 
% 
% NOTE: pajek files should have .net extensions
%
%TOL 06/26/15; modified from JDP 10/10/10


% only the upper triangle
mat=triu(mat,1);

% get edges and values
[x y] = ind2sub(size(mat),ind);
z = mat(ind);

towrite = [x y z];
%%% make the input file %%%
nodes = size(mat,1);
nodenum = 1:nodes;

c=clock; 
fprintf('\t%2.0f:%2.0f:%2.0f: mat2pajek: writing .net file, with %d vertices and %d edges\n',c(4),c(5),c(6),nodes,length(x));

fid=fopen(outputname,'W');
fprintf(fid,'*Vertices %d\n',nodes);
fprintf(fid,'%d "%d"\n',[nodenum; nodenum]);
fprintf(fid,'*Edges %d\n',length(x));

fprintf(fid,'%d %d %f\n',towrite');
fclose(fid);

%cesna output2
if exist('outputname2','var') == 1
    fid=fopen(outputname2,'W');
    %fprintf(fid,'%d %d %f\n',towrite'); include weights in the output
    towrite = [x y]; % print only nodes not weights
    fprintf(fid,'%d\t%d\n',towrite'); % print only nodes not weights
    fclose(fid);
end

