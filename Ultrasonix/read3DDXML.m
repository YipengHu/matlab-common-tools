function   header = read3DDXML(filename)
% for reading data from SonixMDP system, Ultrasonix
% Yipeng Hu (yipeng.hu@ucl.ac.uk) 
% UCL Centre for Medical Image Computing, 2013-06

% look directly for relevant atributes to avoid costly reading-all

%1% the document node
DocNode = xmlread(filename);
% DocNode.getNodeName

%2% get the elements - Params
RootNode = DocNode.getDocumentElement;
% RootNode.getNodeName
% RootNode.hasParamsNode
% RootNode.getLength

%3% children
ParamsNode = RootNode.getChildNodes;
% ParamsNode.getNodeName

% find the FourD class
for  i = 1:ParamsNode.getLength,
    FourDNode = ParamsNode.item(i-1);
    if  strcmp(FourDNode.getNodeName,'FourD'),
        break;
    end
end

% get atributes
FourDAttributes = FourDNode.getAttributes;
for  i = 1:FourDAttributes.getLength,
    FourDAttNode = FourDAttributes.item(i-1);
    header.(char(FourDAttNode.getName)) = char(FourDAttNode.getValue);
end

% all other the child contents and attributs
FourDChildren = FourDNode.getChildNodes;
for  i = 1:FourDChildren.getLength,
    
    ChildNode = FourDChildren.item(i-1);
    ChildName = char(ChildNode.getNodeName);
    
    if  ChildNode.hasAttributes,
        ChildAttributes = ChildNode.getAttributes;
        for  ii = 1:ChildAttributes.getLength,
            ChildAttNode = ChildAttributes.item(ii-1);
            header.(ChildName).(char(ChildAttNode.getName)) = str2double(ChildAttNode.getValue);
        end
        
    elseif  ~strcmp(ChildName(1),'#') % && any(strcmp(methods(ChildNode), 'getTextContent'))
        header.(ChildName) = str2double(ChildNode.getTextContent);         
        
    end
end







