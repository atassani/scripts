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

    if [[ $TENV == "api" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\api\whole_api_to_rename\cga-api-src\trunk"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\api\whole_api_to_rename\cga-api-conf\trunk"
        export APP_CONF=$PROJECT_CONF"\app-conf\local"
    elif [[ $TENV == "retrieve" ]]; then
        export PROJECT_SRC="E:\workarea\code\ClinicalGenomics\services\whole_services_to_rename\cgs-retrieve\cgs-retrieve-src\trunk"
        export PROJECT_CONF="E:\workarea\code\ClinicalGenomics\services\whole_services_to_rename\cgs-retrieve\cgs-retrieve-conf\trunk"
        export APP_CONF=$PROJECT_CONF"\app-conf\dev-dtc"  
    else
        MSG="UNKNOWN";
    fi
    echo "Environment: $MSG and $TJBOSS" 
    MSG=$TENV

    export DEPLOYMENT_SOURCE=*war/target/*.war  
    export PATH="$JAVA_HOME"/bin:"$JBOSS_HOME"/bin:$PATH
    if [[ $TJBOSS == "wildfly" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.8.0_20"
        export JBOSS_HOME="E:\workarea\tools\server\wildfly-8.1.0.Final"
        export MAVEN_OPTS="-Xmx1024m -Duser.name=toni.tassani"
    elif [[ $TJBOSS == "jboss6" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.7.0_71"
        export JBOSS_HOME="E:\workarea\tools\server\jboss-eap-6.3"
        export MAVEN_OPTS="-Xmx1024m"
    elif [[ $TJBOSS == "jboss5" ]]; then
        export JAVA_HOME="E:\workarea\tools\jdk1.6.0_20"
        export JBOSS_HOME="e:\workarea\tools\server\jboss-5.1.0.GA"
        export MAVEN_OPTS="-Xmx1024m -XX:MaxPermSize=256m"
    fi
}

tcleandeploy() {
    if _isEnvironmentSet; then return; fi
    rm -rf "$JBOSS_HOME"/standalone/deployments/*
}

tdep() {
    if _isEnvironmentSet; then return; fi
    case $TENV in
        java6)
            DESTINATION="$JBOSS_HOME"/server/$JBOSS_CONFIG/deploy
        ;;
        java7|java8|retrieve|api)
            DESTINATION="$JBOSS_HOME"/standalone/deployments
        ;;
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
    case $TENV in
        java6)
            echo "Recycling $JBOSS_HOME/server/$JBOSS_CONFIG ..."
            rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/log      && echo "log" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/data && echo "data" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/work && echo "work" && \
                rm -rf "$JBOSS_HOME"/server/$JBOSS_CONFIG/tmp  && echo "tmp" && echo "DONE."
            ;;
        java7|java8|retrieve|api) 
            echo "Recycling $JBOSS_HOME/standalone ..."
            rm -rf "$JBOSS_HOME"/standalone/log      && echo "log" && \
                rm -rf "$JBOSS_HOME"/standalone/data && echo "data" && \
                rm -rf "$JBOSS_HOME"/standalone/tmp  && echo "tmp" && echo "DONE."        
            ;;
    esac
}

trun() {
  if _isEnvironmentSet; then return; fi
  case $TENV in
    java6)                     "$JBOSS_HOME"/bin/run.bat -c cgt ;;
    java7|java8|retrieve|api)  "$JBOSS_HOME"/bin/standalone.bat ;;
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