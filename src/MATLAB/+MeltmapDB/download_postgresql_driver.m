function [] = download_postgresql_driver()
    % DOWNLOAD_POSTGRESQL_DRIVER
    %   Downloads postgresql jdbc driver jar file dependencies
    %
    % Side effects:
    %   Adds jar files related to postgresql to lib/jar
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appRsrcMgr.download_java_dependency('org.postgresql', 'postgresql', '9.4.1212.jre7');
end