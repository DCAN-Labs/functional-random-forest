function [ aligned_community_assignments ] = AlignSubGroups(target_community_assignments,reference_community_assignments,varargin)
%AlignSubgroups matches target_community_assignments to
%reference_community_assignments using the algorithm found in Gordon, 2017.
%    USAGE: aligned_community_assignments =
%    AlignSubGroups(target_community_assignments,reference_community_assignments,'Threshold',5)
%%%%%%INPUTS%%%%%%%%
%       
%       target_community_assignments -- N x C matrix of community
%       assignments to align, where N is the number of nodes and C is the
%       number of sets of community assignments (e.g. by edge density)
%
%       reference_community_assignments -- N x 1 matrix of template
%       community
%       assignments, with the same number of nodes N as the target
%
%%%%%%%OPTIONAL PAIRED INPUTS%%%%%%
%
%       'Threshold',scalar -- 'Threshold' followed by a number will specify
%       the jaccard index value to indicate a successful match, set to 0.1
%       by default (see Gordon, 2017)
%
%
threshold = 0.1;
mincol=1;
if isempty(varargin) == 0
    for i = 1:size(varargin,2)
        if ischar(varargin{i})
            switch(varargin{i})
                case('Threshold')
                    threshold = varargin{i+1};
                case('MinimumColumn')
                    mincol = varargin{i+1};
                case('ManualSet')
                    manualset = varargin{i+1};
            end
        end
    end
end

%% determine assignments

all_assignments = [1:100];
[unique_ref_assignments,first_occurence,repeated_occurences] = unique(reference_community_assignments);
ref_assignment_counts = accumarray(repeated_occurences,1);
ref_community_table = [unique_ref_assignments, ref_assignment_counts];
[~,ref_community_reorder] = sort(ref_community_table(:,2),'descend');
potential_assignments = ref_community_table(ref_community_reorder,1);
new_to_use_assignments = setdiff(all_assignments,potential_assignments);
unassigned_networks = cell(1,size(target_community_assignments,2));
all_recoded = zeros(size(target_community_assignments));

%% run consensus mapping approach
for c = 1:size(all_recoded,2)
    col_consensusmap = target_community_assignments(:,c);


    unassigned = find(col_consensusmap<1);
    for unassignedindex = unassigned'
        thisassignments = target_community_assignments(unassignedindex,mincol:end);
        thisassignments(thisassignments<1) = [];
        if ~isempty(thisassignments)
            col_consensusmap(unassignedindex) = thisassignments(1);
        end
    end
    networks = unique(col_consensusmap);
    networks(networks<=0) = [];
    new_networks = networks;
    assigning_networks = networks;

    col_out = zeros(size(col_consensusmap));

    if exist('manualset','var')
        if isempty(manualset)
            clear manualset
        else
            for i = 1:size(manualset,1)
                col_out(col_consensusmap==manualset(i,1)) = manualset(i,2);
                new_networks(new_networks==manualset(i,1)) = [];
                if all(manualset(i,2)~=potential_assignments)
                       new_networks = [new_networks; manualset(i,2)];
                end
                assigning_networks(assigning_networks==manualset(i,1)) = [];
            end
        end
    end

    for i = 1:length(potential_assignments)
        if exist('manualset','var') && any(manualset(:,2)==potential_assignments(i))
        else
            if ~isempty(assigning_networks)
                groupnetwork_comp = reference_community_assignments==potential_assignments(i);
                D = zeros(length(assigning_networks),1);
                P = zeros(length(assigning_networks),1);
                for j = 1:length(assigning_networks)

                    network_comp = col_consensusmap_nosubcort==assigning_networks(j);
                    P(j) = nnz(groupnetwork_comp & network_comp);
                    D(j) = P(j)/nnz(groupnetwork_comp | network_comp);

                    if c>2 && any(any(all_recoded(1:ncortverts,1:(c-1))==potential_assignments(i)))
                        prevnetwork_comp = any(all_recoded(1:ncortverts,1:(c-1))==potential_assignments(i),2);
                        D_withprev = nnz(prevnetwork_comp & network_comp) ./ nnz(network_comp | prevnetwork_comp);
                        if D_withprev < .1
                            D(j) = 0;
                        end
                    end
                end
                [maxval, maxind(i)] = max(D);

                if maxval > .1
                    col_out(col_consensusmap==assigning_networks(maxind(i))) = potential_assignments(i);
                    new_networks(new_networks==assigning_networks(maxind(i))) = [];
                    assigning_networks(assigning_networks==assigning_networks(maxind(i))) = [];
                end
            end
        end

    end
    clear maxind D P
    for j = 1:length(new_networks)
        col_out(col_consensusmap==new_networks(j)) = newcolors(j);
    end
    all_recoded(:,c) = col_out;
    unassigned_networks{c} = assigning_networks;
end


all_recoded(target_community_assignments<=0) = 0;
cifti_data.data = all_recoded;
if ~exist('cifti_data.mapname')
    for col = 1:size(all_recoded,2)
        cifti_data.mapname{col} = ['Column number ' num2str(col)];
    end
    cifti_data.dimord = 'scalar_pos';
end

dotsloc = strfind(regularized_ciftifile,'.');
basename = regularized_ciftifile(1:(dotsloc(end-1)-1));
outname = [basename '_allcolumns_recolored'];
ft_write_cifti_mod(outname,cifti_data);
set_cifti_powercolors([outname '.dscalar.nii'])




out = all_recoded(:,mincol);

uniquevals = unique(out); %uniquevals(uniquevals<1) = [];
colors_tofix = setdiff(uniquevals,potential_assignments);
verts_tofix = [];
for colornum = 1:length(colors_tofix)
    verts_thiscolor = find(out==colors_tofix(colornum));
    verts_tofix = [verts_tofix ; verts_thiscolor(:)];
end
for vertnum = verts_tofix'
    for col = (mincol+1):size(all_recoded,2)
        if any(all_recoded(vertnum,col)==potential_assignments)
            out(vertnum) = all_recoded(vertnum,col);
            break
        end
    end
end
end

