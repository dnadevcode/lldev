function [] = download_batik_rasterizer()
    % DOWNLOAD_BATIK_RASTERIZER
    %   Downloads batik rasterizer jar file dependencies
    %
    % Side effects:
    %   Adds jar files related to rasterization from batik to lib/jar
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    
    appRsrcMgr.download_java_dependency('org.apache.xmlgraphics', 'batik-codec', '1.9');
    appRsrcMgr.download_java_dependency('org.apache.xmlgraphics', 'batik-rasterizer', '1.9');
end

