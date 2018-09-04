function entrez_db_names = get_entrez_db_names()
    import javax.xml.xpath.*;
    import NCBI.xmlreadstring;
    
    entrezDbListURL = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi';
    [dbListXMLStr, status] = urlread(entrezDbListURL);
    if not(status)
        error(['Failed to read entrez database names from url: ''', entrezDbListURL, '''']);
    end
    [dbListXmlDOM] = xmlreadstring(dbListXMLStr);
    listDbNames = xpath.evaluate('eInfoResult/DbList/DbName', searchResultsListXmlDOM, nodeset);
    entrez_db_names = arrayfun(@(k) char(listDbNames.item(k - 1).getFirstChild.getData()), (1:listDbNames.getLength)', 'UniformOutput', false);
end