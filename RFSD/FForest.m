classdef FForest
    %FForest is a random forest class that contains methods and properties
    %for growing a random forest. This class should be simpler than the
    %TreeBagger class. Only properties about the trees themselves are
    %saved. Training the model is handled in a separate code that uses this
    %class. Data should be stored as a numerical or cell matrix where rows
    %are participants and columns are features. 
    %   The class comprises a forest object with two associated structures:
    %       Nodes -- comprise three scalars and a two-column numerical
    %       matrix
    %           Tree: a 1X3 vector for inherited tree, number of prior
    %           nodes, and number of prior branches.
    %           Level: Scalar index for level of particular tree.
    %           NodeID: Scalar index for node number; the leftmost node on every
    %           level is node 1 and it increases to the right.
    %           training_cases: outcomes and indexes for all training cases. Cases are moved
    %           towards terminal nodes, limiting the total data saved to
    %           2*N where N is the number of cases.
    %       Branches -- comprise two scalars and two cells
    %           evaluation mode: scalar number representing the evaluation
    %           rule: (1) continuous, (2) string matching (categorical)
    %           value: a cell representing the value for
    %           the evaluation -- may be number or string
    %           feature: a scalar denoting the column from the data to use
    %           for evaluation
    %           surrogate: If the case is missing the feature, a surrogate split will be
    %           used and is defined here within a cell.
    %   The class contains methods to: 
    %       Plant(training_cases,Tree) --  initiate a tree in the forest, will
    %       generate a new forest if tree equals 1.
    %       GrowBranch(Tree,Level,NodeID,feature,mode,value) -- grow branches,
    %       calls Eval to send training data down branches
    %       EvalCases(data,Tree,Level,NodeID,training_flag) -- evaluate cases, and send
    %       down a branch, if training_flag is set to 1, store cases in the
    %       child Nodes.
    %       GrowForest(data,outcomes,ntrees,nsamples,nfeatures,nterminals)
    %       -- Grows a random forest object using the data and outcomes as
    %       training data. Can specify the number of trees (ntrees), the
    %       number of training samples to use (nsamples), the number
    %       of features to select per branch (nfeatures), and the number of
    %       terminal nodes (nterminals). Defaults can be found in the
    %       function below.
    %       predicted_outcomes = Predict(testing_cases) -- calls Eval iteratively until a terminal
    %       nodes is reached, a vector containing the predicted outcomes is
    %       returned.
    %       
    %
    
    properties
        Nodes = struct('Tree',zeros(1,3),'Level',[],'NodeID',[],'cases',zeros(1,2));
        Branches = struct('EvalMode',[],'Value',cell(1),'Feature',[],'Surrogate',cell(1));
    end
    
    methods
        function obj = Plant(obj,training_cases,treenum)
            if treenum(1) == 1;
                obj.Nodes(1).Tree = treenum;
                obj.Nodes(1).NodeID = 1;
                obj.Nodes(1).Level = 1;
                obj.Nodes(1).cases = training_cases;
            else
                node_index = length(obj.Nodes) + 1;
                obj.Nodes(node_index).Tree = treenum;
                obj.Nodes(node_index).NodeID = 1;
                obj.Nodes(node_index).Level = 1;
                obj.Nodes(node_index).cases = training_cases;
            end   
        end
        function obj = GrowBranch(obj,treenum,levelnum,nodeid,feature,modenum,value,surrogate)
            current_node_in_tree = 0;
            for j = 1:levelnum - 1
                current_node_in_tree = current_node_in_tree + 2^(j-1);
            end
            current_node_in_tree = current_node_in_tree + nodeid + treenum(2);
            obj.Branches(current_node_in_tree).Feature = feature;
            obj.Branches(current_node_in_tree).Value = value;
            obj.Branches(current_node_in_tree).EvalMode = modenum;
            obj.Branches(current_node_in_tree).Surrogate = surrogate;
        end
        function [obj,out] = EvalCases(obj,data,data_index,treenum,levelnum,nodeid,training_flag)
            current_node_in_tree = 0;
            for j = 1:levelnum - 1
                current_node_in_tree = current_node_in_tree + 2^(j-1);
            end
            if isempty(j)
                future_node_in_tree = current_node_in_tree + 2*(nodeid-1)+2;
            else
                future_node_in_tree = current_node_in_tree + 2*(nodeid-1)+1 + 2^j;
            end
            current_node_in_tree = current_node_in_tree + nodeid;
            if training_flag == 0
                obj.Nodes(treenum(2)+future_node_in_tree).NodeID = 2*(nodeid-1)+ 1;
                obj.Nodes(treenum(2)+future_node_in_tree+1).NodeID = 2*(nodeid-1) + 2;
                obj.Nodes(treenum(2)+future_node_in_tree).Level = levelnum + 1;
                obj.Nodes(treenum(2)+future_node_in_tree+1).Level = levelnum + 1;
                obj.Nodes(treenum(2)+future_node_in_tree).Tree = treenum;
                obj.Nodes(treenum(2)+future_node_in_tree+1).Tree = treenum;
            end
            branch_used = treenum(3) + current_node_in_tree;
            switch(obj.Branches(branch_used).EvalMode)
                case(1)
                    thresh_vector = data(data_index,obj.Branches(branch_used).Feature) <= obj.Branches(branch_used).Value;
                case(2)
                    thresh_vector = strcmp(data(data_index,obj.Branches(branch_used).Feature),obj.Branches(branch_used).Value);                
            end
            for i = 1:length(thresh_vector)
                if isnan(data(data_index(i),obj.Branches(branch_used).Feature)) || isempty(data(data_index(i),obj.Branches(branch_used).Feature))
                    if isnan(data(data_index(i),obj.Branches(branch_used).Surrogate{1}{1}(1))) || isempty(data(data_index(i),obj.Branches(branch_used).Surrogate{1}{1}(1)))
                        if isnan(data(data_index(i),obj.Branches(branch_used).Surrogate{2}{1}(1))) || isempty(data(data_index(i),obj.Branches(branch_used).Surrogate{2}{1}(1)))
                            switch(obj.Branches(branch_used).Surrogate{3}{1}(2))
                                case(1)
                                    thresh_vector(i) = data(data_index(i),obj.Branches(branch_used).Surrogate{3}{1}(1)) <= obj.Branches(branch_used).Surrogate{3}{1}(3);
                                case(2)
                                    thresh_vector(i) = strcmp(data(data_index(i),obj.Branches(branch_used).Surrogate{3}{1}(1)),obj.Branches(branch_used).Surrogate{3}{1}(3));
                            end
                        else
                            switch(obj.Branches(branch_used).Surrogate{2}{1}(2))
                                case(1)
                                    thresh_vector(i) = data(data_index(i),obj.Branches(branch_used).Surrogate{2}{1}(1)) <= obj.Branches(branch_used).Surrogate{2}{1}(3);
                                case(2)
                                    thresh_vector(i) = strcmp(data(data_index(i),obj.Branches(branch_used).Surrogate{2}{1}(1)),obj.Branches(branch_used).Surrogate{2}{1}(3));
                            end                           
                        end
                    else
                        switch(obj.Branches(branch_used).Surrogate{1}{1}(2))
                            case(1)
                                thresh_vector(i) = data(data_index(i),obj.Branches(branch_used).Surrogate{1}{1}(1)) <= obj.Branches(branch_used).Surrogate{1}{1}(3);
                            case(2)
                                thresh_vector(i) = strcmp(data(data_index(i),obj.Branches(branch_used).Surrogate{1}{1}(1)),obj.Branches(branch_used).Surrogate{1}{1}(3));
                        end                       
                    end
                end
            end
            if training_flag == 0
                out = treenum(2)+future_node_in_tree+1 - double(thresh_vector);
            elseif training_flag == 1 && size(find(thresh_vector == 0),1) ~= 0 && size(find(thresh_vector == 1),1) ~= 0                
                out = treenum(2)+future_node_in_tree+1 - double(thresh_vector);
                obj.Nodes(treenum(2)+future_node_in_tree).NodeID = 2*(nodeid-1)+ 1;
                obj.Nodes(treenum(2)+future_node_in_tree+1).NodeID = 2*(nodeid-1) + 2;
                obj.Nodes(treenum(2)+future_node_in_tree).Level = levelnum + 1;
                obj.Nodes(treenum(2)+future_node_in_tree+1).Level = levelnum + 1;
                obj.Nodes(treenum(2)+future_node_in_tree).Tree = treenum;
                obj.Nodes(treenum(2)+future_node_in_tree+1).Tree = treenum;
                try
                    obj.Nodes(treenum(2)+future_node_in_tree).cases = obj.Nodes(treenum(2)+current_node_in_tree).cases(thresh_vector==1,:);
                    obj.Nodes(treenum(2)+future_node_in_tree+1).cases = obj.Nodes(treenum(2)+current_node_in_tree).cases(thresh_vector==0,:);
                catch
                end
            else
                out = NaN;
            end
        end
        function [outcomes,proxmat] = Predict(obj,testing_cases)
            vote_vector = nan(length(testing_cases),obj.Nodes(end).Tree(1));
            proxmat = zeros(size(testing_cases,1));
            current_node_in_tree = 1;
            for current_tree = 1:obj.Nodes(end).Tree(1)
                current_node = 1;
                current_level = 1;
                prior_nodes = obj.Nodes(current_node_in_tree).Tree(2);
                total_level = 1;
                out = ones(size(testing_cases,1),1);
                current_node_in_tree = 0;
                while isnan(sum(vote_vector(:,current_tree)))
                    current_node_in_tree = current_node_in_tree + 1;
                    out_index = (find(out == prior_nodes + current_node_in_tree));
                    if isempty(obj.Nodes(prior_nodes + current_node_in_tree).Tree) == 0 && isempty(obj.Nodes(prior_nodes + current_node_in_tree).cases(:,1)) == 0
                        try
                            [~,out(out_index)] = obj.EvalCases(testing_cases,out_index,obj.Nodes(prior_nodes + current_node_in_tree).Tree,current_level,current_node,0);
                        catch
                            vote_vector(out_index,current_tree) = round(mean(obj.Nodes(prior_nodes+current_node_in_tree).cases(:,1)));
                            proxmat(out_index,out_index) = proxmat(out_index,out_index) + 1;
                        end
                    end
                    current_node = current_node + 1;
                    if current_node_in_tree == total_level
                        current_level = current_level + 1;
                        current_node = 1;
                        total_level = total_level + 2^(current_level-1);
                    end
                end
                if current_tree < obj.Nodes(end).Tree(1)
                    same_tree = 1;
                    node_structindex = prior_nodes + current_node_in_tree;
                    while same_tree
                        node_structindex = node_structindex + 1;
                        if isempty(obj.Nodes(node_structindex).Tree) == 0 && isempty(obj.Nodes(node_structindex-1).Tree) == 0
                            same_tree = obj.Nodes(node_structindex-1).Tree(1) == obj.Nodes(node_structindex).Tree(1);
                        end
                    end
                end
            end
            outcomes = round(sum(vote_vector,2)/current_tree);
            proxmat = proxmat./current_tree;
        end
        function impurity = EvalNode(obj,treenum,levelnum,nodeid)
            current_node_in_tree = 0;
            for j = 1:levelnum - 1
                current_node_in_tree = current_node_in_tree + 2^(j-1);
            end
            current_node_in_tree = current_node_in_tree + nodeid + treenum(2);
            outcomes = obj.Nodes(current_node_in_tree).cases(:,1);
            sump = 0;
            for i = unique(outcomes)'
                sump = sump + (length(find(outcomes == i))/length(outcomes))^2;
            end
            impurity = 1 - sump;           
        end
        function obj = GrowForest(obj,data,outcomes,ntrees,nsamples,nfeatures,nterminals)
            rng('Shuffle');
            [ncases, num_features] = size(data);
            if exist('nsamples','var') == 0
                nsamples = round(2*ncases/3);
            elseif isempty(nsamples)
                nsamples = round(2*ncases/3);               
            end
            if exist('nfeatures','var') == 0
                nfeatures = floor(sqrt(num_features));
            elseif isempty(nsamples)
                nfeatures = floor(sqrt(num_features));
            end
            if exist('nterminals','var') == 0
                nterminals = 10;
            elseif isempty(nterminals)
                nterminals = 10;
            end
            prior_nodes = 0;
            prior_branches = 0;
            for current_tree = 1:ntrees
                current_features = (1:num_features)';
                current_terminals = 0;
                current_level = 1;
                current_node_in_tree = 0;
                locked_cases = NaN(nsamples,1);
                boot_vector = randi(ncases,nsamples,1);
                boot_data = data(boot_vector,:);
                boot_outcomes = [outcomes(boot_vector), (1:nsamples)'];
                %initiate the first node
                obj = obj.Plant(boot_outcomes,[current_tree prior_nodes prior_branches]);
                while isnan(sum(locked_cases)) && current_terminals < nterminals && length(current_features) >= nfeatures
                    %iterate through nodes on the current level
                    for current_node = 1:2^(current_level-1)
                        use_node = 1;
                        current_node_in_tree = current_node_in_tree + 1;
                        %check if current node is a terminal node operate
                        %in a try/catch if the node is empty (i.e. beyond a
                        %terminal node)
                        try
                            obj.EvalNode([current_tree prior_nodes prior_branches],current_level,current_node);
                        catch
                            use_node = 0;
                        end
                        if use_node == 1;
                            if(obj.EvalNode([current_tree prior_nodes prior_branches],current_level,current_node)) == 0
                                current_terminals = current_terminals + 1;
                                locked_cases(obj.Nodes(current_node_in_tree+prior_nodes).cases(:,2)) = 0;
                            else
                                unbiased_selection = 1;
                                %not a terminal node 
                                % randomly select the number of features to
                                % evaluate for the cases in this node
                                while unbiased_selection
                                feature_impurity_and_value = zeros(nfeatures,3);
                                randomly_selected_features = current_features(randi(length(current_features),nfeatures,1));
                                for current_feature = 1:nfeatures
                                    temp_data = boot_data(obj.Nodes(prior_nodes+current_node_in_tree).cases(:,2),randomly_selected_features(current_feature));
                                    temp_outcomes = boot_outcomes(obj.Nodes(prior_nodes+current_node_in_tree).cases(:,2),1);
                                    modenum = 1;
                                    if iscell(temp_data(1))
                                        if ischar(temp_data{1})
                                            modenum = 2;
                                        else
                                            temp_data = cell2mat(temp_data);
                                        end
                                    end
                                    feature_impurity_and_value(current_feature,3) = modenum;
                                    switch(modenum)
                                        case(1)
                                            boot_outcome_impurity = zeros(length(unique(temp_data)),1);
                                            temp_data_sorted = unique(temp_data);
                                            logical_mat = repmat(temp_data,1,length(unique(temp_data))) - repmat(unique(temp_data).',length(temp_data),1) <= 0;
                                            for value_index = 1:size(logical_mat,2)
                                                boot_outcomes_left = temp_outcomes(logical_mat(:,value_index) == 1);
                                                boot_outcomes_right = temp_outcomes(logical_mat(:,value_index) == 0);
                                                boot_purity_left = 0;
                                                boot_purity_right = 0;
                                                if isempty(boot_outcomes_left) == 0
                                                    for outcome_type_left = unique(boot_outcomes_left).'
                                                        boot_purity_left = boot_purity_left + (length(find(boot_outcomes_left == outcome_type_left))/length(boot_outcomes_left))^2;
                                                    end
                                                else
                                                    boot_purity_left = -10;
                                                    boot_outcomes_left = zeros(length(boot_outcomes_right),1);
                                                end
                                                if isempty(boot_outcomes_right) == 0
                                                    for outcome_type_right = unique(boot_outcomes_right).'
                                                        boot_purity_right = boot_purity_right + (length(find(boot_outcomes_right == outcome_type_right))/length(boot_outcomes_right))^2;
                                                    end
                                                else
                                                    boot_purity_right = -10;
                                                    boot_outcomes_right = zeros(length(boot_outcomes_left),1);
                                                end
                                                boot_outcome_impurity(value_index) = ((1 - boot_purity_left)*length(boot_outcomes_left) + (1 - boot_purity_right)*length(boot_outcomes_right))/length(temp_data);
                                            end
                                            [feature_impurity_and_value(current_feature,1),feature_value_index] = min(boot_outcome_impurity);
                                            feature_impurity_and_value(current_feature,2) = temp_data_sorted(feature_value_index);
                                        case(2)
                                            boot_outcome_impurity = zeros(length(unique(temp_data)),1);
                                            temp_data_sorted = unique(temp_data);
                                            for value_index = 1:length(temp_data_sorted)
                                                value_vector = strcmp(temp_data,temp_data_sorted{value_index});
                                                boot_outcomes_left = temp_outcomes(value_vector == 1);
                                                boot_outcomes_right = temp_outcomes(value_vector == 0);
                                                boot_purity_left = 0;
                                                boot_purity_right = 0;
                                                for outcome_type_left = unique(boot_outcomes_left).'
                                                    boot_purity_left = boot_purity_left + (length(find(boot_outcomes_left == outcome_type_left))/length(boot_outcomes_left))^2;
                                                end
                                                for outcome_type_right = unique(boot_outcomes_right).'
                                                    boot_purity_right = boot_purity_right + (length(find(boot_outcomes_right == outcome_type_right))/length(boot_outcomes_right))^2;
                                                end
                                                boot_outcome_impurity(value_index) = ((1 - boot_purity_left)*length(boot_outcomes_left) + (1 - boot_purity_right)*length(boot_outcomes_right))/length(temp_data);
                                            end
                                            [feature_impurity_and_value(current_feature,1),feature_value_index] = min(boot_outcome_impurity);
                                            feature_impurity_and_value(current_feature,2) = temp_data_sorted(feature_value_index); 
                                    end
                                end
                                [~,sorted_features] = sort(feature_impurity_and_value(:,1),'ascend');
                                feature_impurity_and_value = feature_impurity_and_value(sorted_features,:);
                                temp_obj = obj.GrowBranch([current_tree prior_nodes prior_branches],current_level,current_node,randomly_selected_features(sorted_features(1)),feature_impurity_and_value(1,3),feature_impurity_and_value(1,2),{{[randomly_selected_features(sorted_features(2)),feature_impurity_and_value(2,3),feature_impurity_and_value(2,2)]},{[randomly_selected_features(sorted_features(3)),feature_impurity_and_value(3,3),feature_impurity_and_value(3,2)]},{[randomly_selected_features(sorted_features(4)),feature_impurity_and_value(4,3),feature_impurity_and_value(4,2)]}});
                                [temp_obj,out] = temp_obj.EvalCases(boot_data,obj.Nodes(prior_nodes+current_node_in_tree).cases(:,2),[current_tree prior_nodes prior_branches],current_level,current_node,1);
                                if isnan(out)
                                else
                                    unbiased_selection = 0;                                    
                                    current_features = current_features(find(current_features ~= randomly_selected_features(sorted_features(1))));
                                    obj = temp_obj;
                                end
                                end
                            end
                        end
                    end
                    current_level = current_level + 1;
                end
               prior_branches = max([length(obj.Branches) length(obj.Nodes)]);
               prior_nodes = prior_branches;
            end
                
        end
    end
end

