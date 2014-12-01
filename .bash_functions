tenv() {
    PARAM_ENV=$1
    PARAM_JBOSS=$2

    if [[ $PARAM_JBOSS == "" ]]; then
        export PARAM_JBOSS=wildfly
    fi    
    if [[ $PARAM_ENV == "" ]]; then
        echo "Current Environment is: $TENV and $TJBOSS"
        return;
    fi
    
    TENV=$PARAM_ENV
    TJBOSS=$PARAM_JBOSS
    export TENV
    export TJBOSS
    export JBOSS_STANDALONE=standalone

    export DEPLOYMENT_SOURCE=*war/target/*.war  
    export PATH="$JAVA_HOME"/bin:"$JBOSS_HOME"/bin:$PATH
    if [[ $TJBOSS == "wildfly" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.8.0_20"
        export JBOSS_HOME="E:\workarea\tools\server\wildfly-8.1.0.Final"
        export MAVEN_OPTS="-Xmx1024m -Duser.name=toni.tassani"
        case $TENV in
            api|apiw) export JBOSS_STANDALONE=standaloneapi ;;
        esac
    elif [[ $TJBOSS == "jboss6" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.7.0_71"
        export JBOSS_HOME="E:\workarea\tools\server\jboss-eap-6.3"
        export MAVEN_OPTS="-Xmx1024m"
    elif [[ $TJBOSS == "jboss5" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.6.0_20"
        export JBOSS_HOME="e:\workarea\tools\server\jboss-5.1.0.GA"
        export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=256m"
    fi
    
    MSG=$TENV
    if [[ $TENV == "api" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\api\whole_api_to_rename\cga-api-src\trunk"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\api\whole_api_to_rename\cga-api-conf\trunk"
        export APP_CONF=$PROJECT_CONF"\app-conf\local"
        export JBOSS_CONSOLE_LOG="$JBOSS_HOME"/$JBOSS_STANDALONE/log/api.log
    elif [[ $TENV == "retrieve" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\services\whole_services_to_rename\cgs-retrieve\cgs-retrieve-src\trunk"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\services\whole_services_to_rename\cgs-retrieve\cgs-retrieve-conf\trunk"
        export APP_CONF=$PROJECT_CONF"\app-conf\dev-dtc"  
        export JBOSS_CONSOLE_LOG="$JBOSS_HOME"/$JBOSS_STANDALONE/log/retrieve.log
    elif [[ $TENV == "apiw" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\api\api-wildfly\cga-api-src"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\api\api-wildfly\cga-api-conf"
        export APP_CONF=$PROJECT_CONF"\app-conf\toni"
        export JBOSS_CONSOLE_LOG="$JBOSS_HOME"/$JBOSS_STANDALONE/log/apiw.log
    elif [[ $TENV == "retrievew" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\services\retrieve-wildfly\cgs-retrieve-src"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\services\retrieve-wildfly\cgs-retrieve-conf"
        export APP_CONF=$PROJECT_CONF"\app-conf\dev-dtc"  
        export JBOSS_CONSOLE_LOG="$JBOSS_HOME"/$JBOSS_STANDALONE/log/retrievew.log
    else
        MSG="UNKNOWN";
    fi
    echo "Environment: $MSG and $TJBOSS" 
}

tcleandeploy() {
    if _isEnvironmentSet; then return; fi
    case $JBOSS in
        jboss5)
            rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/deploy/* ;;
        *)
            rm -rf "$JBOSS_HOME"/$JBOSS_STANDALONE/deployments/*
    esac    
}

tdep() {
    if _isEnvironmentSet; then return; fi
    case $JBOSS in
        jboss5)
            DESTINATION="$JBOSS_HOME"/server/$JBOSS_CONFIG/deploy;;
        *)
            DESTINATION="$JBOSS_HOME"/$JBOSS_STANDALONE/deployments;;
    esac

    cp -v "$PROJECT_SRC"/$DEPLOYMENT_SOURCE $DESTINATION
    echo "WAR file copied to JBOSS folder"
}

tcd () {
    if _isEnvironmentSet; then return; fi
    cd "$PROJECT_SRC"
}

tfull() {  
    if _isEnvironmentSet; then return; fi
    pushd .
    tcd
    cd $PROJECT_SRC
    mvn clean install
    tdep
    popd
    trun
}

tsvn() {
    if _isEnvironmentSet; then return; fi
    pushd .
    cd "$PROJECT_SRC"  && svn "$@"
    cd "$PROJECT_CONF" && svn "$@"
    popd
}

trecycle() {
    if _isEnvironmentSet; then return; fi
    case $TJBOSS in
        jboss5)
            echo "Recycling $JBOSS_HOME/server/$JBOSS_CONFIG ..."
            rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/log      && echo "log" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/data && echo "data" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/work && echo "work" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/tmp  && echo "tmp" && echo "DONE."
            ;;
        *) 
            echo "Recycling $JBOSS_HOME/$JBOSS_STANDALONE ..."
            rm -rf "$JBOSS_HOME"/$JBOSS_STANDALONE/log      && echo "log" && \
                rm -rf "$JBOSS_HOME"/$JBOSS_STANDALONE/data && echo "data" && \
                rm -rf "$JBOSS_HOME"/$JBOSS_STANDALONE/tmp  && echo "tmp" && echo "DONE."        
            ;;
    esac
}

trun() {
  if _isEnvironmentSet; then return; fi
  case $TJBOSS in
    jboss5) "$JBOSS_HOME"/bin/run.bat -c cgt ;;
    *) 
        OLD_JAVA_OPTS=$JAVA_OPTS
        case $TENV in
            apiw|api) 
                export JAVA_OPTS=$JAVA_OPTS" -Djboss.socket.binding.port-offset=100"
                export JAVA_OPTS=$JAVA_OPTS" -Djboss.server.base.dir=""$JBOSS_HOME"/$JBOSS_STANDALONE
                export JAVA_OPTS=$JAVA_OPTS" -Djboss.log.file=""$JBOSS_CONSOLE_LOG"
                #export JAVA_OPTS=$JAVA_OPTS" -Dlog4j.debug"   
                #export JAVA_OPTS=$JAVA_OPTS" -Djboss.node.name=host1"
                #export JAVA_OPTS=$JAVA_OPTS" -b=0.0.0.0"
                ;;
            retrievew|retrieve)  
                export JAVA_OPTS=$JAVA_OPTS" -Djboss.log.file=""$JBOSS_CONSOLE_LOG"
                ;;
        esac
        "$JBOSS_HOME"/bin/standalone.bat 
        JAVA_OPTS=$OLD_JAVA_OPTS
  esac
}

_isEnvironmentSet() {
   if [[ $PROJECT_SRC = "" ]]; then
      echo "Environment has not been set. Run tenv"
      return 0
    fi
    return 1
}

# We will set up initially the environment
tenv retrieve wildfly