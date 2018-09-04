function [searchResultsStruct] = search_entrez(db, term, retStart, retMax, usehistory, field)
    import java.net.URLEncoder;
    import javax.xml.xpath.*;
    import NCBI.get_entrez_db_names;
    import NCBI.xmlreadstring;
    
    baseSearchURL = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?';
    
    factory = XPathFactory.newInstance;
    xpath = factory.newXPath;
    nodeset =  XPathConstants.NODESET;
    
    entrez_db_names = get_entrez_db_names();
    if not(any(strcmp(entrez_db_names, db)))
        error('The database specified appears to be invalid');
    end
    if nargin < 3
        retStart = 0;
    else
        validateattributes(retStart, {'numeric'}, {'nonnegative', 'integer'});
    end
    if nargin < 4
        retMax = 20;
    else
        validateattributes(retMax, {'numeric'}, {'positive', 'integer'});
    end
    if nargin < 5
        usehistory = true;
    end
    
    paramComponentsStruct = struct;
    paramComponentsStruct.db = db;
    paramComponentsStruct.term = term;
    paramComponentsStruct.retstart = num2str(retStart);
    paramComponentsStruct.retmax = num2str(retMax);
    if usehistory
        paramComponentsStruct.usehistory = 'y';
    end
    
    paramNames = fieldnames(paramComponentsStruct);
    numParams = length(paramNames);
    queryParams = cell(numParams, 1);
    for paramNum=1:numParams
        paramKey = paramNames{paramNum};
        paramValue = char(encode(paramComponentsStruct.(paramKey)));
        queryParam = [paramKey, '=', paramValue];
        queryParams{paramNum} = queryParam;
    end
    queryParamsStr = strjoin(queryParams, '&');
    
    searchURL = [baseSearchURL, queryParamsStr];
    [searchReportXMLStr, status] = urlread(searchURL);
    if not(status)
        error('Entrez search failed');
    end
    
    [searchResultsListXmlDOM] = xmlreadstring(searchReportXMLStr);
    resultsObject = xpath.evaluate('eSearchResult', searchResultsListXmlDOM, nodeset);
    if resultsObject.getLength ~= 1
        error('Unexpected number of XML format with respect to ''eSearchResult''');
    end
    scalarNumericFields = {'Count'; 'RetMax'; 'RetStart'};
    scalarNumericFieldsMatlabFriendly =  matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(scalarNumericFields));
    numScalarNumericFields = length(scalarNumericFields);
    for scalarNumericFieldNum=1:numScalarNumericFields
        scalarNumericField = scalarNumericFields{scalarNumericFieldNum};
        scalarNumericFieldMatlabFriendly = scalarNumericFieldsMatlabFriendly{scalarNumericFieldNum};
        fieldObject = xpath.evaluate(['eSearchResult/', scalarNumericField], searchResultsListXmlDOM, nodeset);
        if fieldObject.getLength ~= 1
            warning(['Unexpected number of XML format with respect to ''', scalarNumericField, '''']);
        else
            fieldObject = fieldObject.item(0);
            searchResultsStruct.(scalarNumericFieldMatlabFriendly) = str2double(char(fieldObject.getFirstChild.getData()));
        end
    end
    idListFieldName = 'IdList';
    idListFieldObject = xpath.evaluate(['eSearchResult/', idListFieldName], searchResultsListXmlDOM, nodeset);
    if idListFieldObject.getLength ~= 1
         error(['Unexpected number of XML format with respect to ''', idListFieldName, '''']);
    end
    idListFieldObject = idListFieldObject.item(0);
    idsObjects = idListFieldObject.getElementsByTagName('Id');
    searchResultsStruct.IdList = arrayfun(@(k) str2double(char(idsObjects.item(k - 1).getFirstChild.getData())), (1:idsObjects.getLength)');
end