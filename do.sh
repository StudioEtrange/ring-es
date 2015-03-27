#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include

# TODO
# snapshot/restore : http://www.elastic.co/guide/en/elasticsearch/guide/current/backing-up-your-cluster.html

function usage() {
    echo "USAGE :"
    echo "----------------"
    echo "List of commands"
    echo " o-- product management :"
    echo " L     ring <install|uninstall> : install/uninstall everything"
    echo " L     ring register : register every data, visualization, etc.."
    echo " L     ring purge : delete every data, visualization, etc.."
    echo " L     ring info : print some informations"
    echo " L     ring ui : open all web application"
    echo " o-- es management :"
    echo " L     es run : run elasticsearch"
    echo " L     es purge : erase everything in es"
    echo " L     es get --resource=<uri> : get a ressource"
    echo " L     es delete --resource=<uri> : delete a ressource"
    echo " L     es register-index --index=<index> : create an index"
    echo " L     es delete-index --index=<index> : delete an index"
    echo " L     es get-doc --index=<index> --type=<doctype> [--maxsize=<integer>] : print a list of documents"
    echo " L     es get-id --index=<index> --doctype=<doctype> [--maxsize=<integer>] : print a list of documents id"
    echo " o-- kibana management :"
    echo " L     kibana run : run kibana"
    echo " L     kibana register-all : register all kibana data"
    echo " L     kibana register-viz : register all kibana visualization"
    echo " L     kibana register-dash : register all kibana dashboard"
    echo " L     kibana register-index : register all kibana index pattern"
    echo " L     kibana save-all : save all kibana data"
    echo " L     kibana save-dash : save all kibana dashboard"
    echo " L     kibana save-viz : save all kibana visualization"
    echo " L     kibana save-index : save all kibana index pattern"
    echo " L     kibana save-search : save all kibana search"
    echo " L     kibana purge : erase all kibana data"
    echo " L     kibana delete-dash : erase all kibana dashboard"
    echo " L     kibana delete-viz : erase all kibana visualization"
    echo " L     kibana delete-index : erase all kibana index pattern"
    echo " L     kibana delete-search : erase all kibana index pattern"

}



# COMMAND LINE -----------------------------------------------------------------------------------
PARAMETERS="
ACTION=											'action' 			a				'ring es kibana'
ID=												'target'			a 				'delete get get-doc get-id ui install uninstall purge info register register-all register-index register-viz register-dash register-search register-index delete-viz delete-dash run delete-index delete-search save-all save-viz save-dash save-search save-index'
"
OPTIONS="
FORCE=''							      'f'		  ''					b			0		'1'					  Force.
DEBUG=''                                  'd'         ''                    b           0       '1'                     Debug mode.
INDEX=''                             'i'         'index'                s           0       ''                      Index name.
DOCTYPE=''                             't'         'type'                s           0       ''                      Document type.
RESOURCE=''                             'r'         'uri'                s           0       ''                      elasticsearch resource.
MAXSIZE=''                              's'         'integer'           s           0       ''                      Max number of result.
ESURL='http://localhost:9200'        'e'         'http://host:port'           s           0       ''              elasticsearch endpoint
KURL='http://localhost:5601'        'k'         'http://host:port'           s           0       ''              kibana endpoint
"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "Ring SEL" "$(usage)" "" "$@"


# FUNCTIONS -----------------------------------------------------------------------------------

function info() {
    
    echo " ** RING ES ** "
    echo ""

    echo "* ELASTICSEARCH"
    echo "** home : $ES_HOME"
    echo "** URL : $ES_URL"
    echo "** settings : $ES_URL/_nodes?settings=true&pretty=true"
    echo "** nodes info : $ES_URL/_nodes"
    echo ""

    echo "* KIBANA"
    echo "** home : $KIBANA_HOME"
    echo "** URL : $KIBANA_URL"
    echo ""

    echo "** ELASTICSEARCH PLUGINS"
    echo "** marvel UI : $MARVEL_UI"
    echo "** marvel sense UI : $SENSE_UI"
    echo "** kopf UI : $KOPF_UI"
    echo "** bigdesk UI : $BIGDESK_UI"
    echo "** head UI : $HEAD_UI"
    echo "** HQ UI : $HQ_UI"
    echo ""
}


# eval a file content (might be used to evaluate variable inside a file)
#   example 1 :  _eval_file file.original file.destination
#   example 2 :  var=$(_eval_file file.original) && echo "$var"
function _eval_file() {
    local _file=$1
    local _output_file=$2

    if [ "$_output_file" == "" ]; then
        echo "$(eval echo -e "\"$(cat "$_file" | sed "s/\\\/\\\\\\\/g" | sed "s/\"/\\\\\"/g")\"")"
    else
        echo "$(eval echo -e "\"$(cat "$_file" | sed "s/\\\/\\\\\\\/g" | sed "s/\"/\\\\\"/g")\"")" >$_output_file
    fi
}

function _eval_json_file() {
    local _json_file=$1

    #cat "$JSON_ROOT"/"$_json_file" | jq -r '.' | eval
    eval echo -e $(cat "$JSON_ROOT"/"$_json_file" | sed "s/\\\/\\\\\\\/g" | sed "s/\\\/\\\\\\\/g" | sed "s/\*/\\\\\*/g" | sed "s/\"/\\\\\"/g" | sed "s/{/\\\{/g" | sed "s/}/\\\}/g" | sed "s/(/\\\(/g" | sed "s/)/\\\)/g" | sed "s/\\[/\\\\\\[/g" | sed "s/\\]/\\\\\\]/g" | sed "s/\\</\\\\\\</g" | sed "s/\\>/\\\\\\>/g")
}


function ES_put() {
    local _target=$1
    local _json_file=$2

    local result=
    [ "$DEBUG" == "1" ] && echo $(_eval_json_file $_json_file)

    [ "$_json_file" == "" ] && result=$(curl -s -XPUT $ES_URL/$_target)
    [ ! "$_json_file" == "" ] && result=$(curl -s -XPUT $ES_URL/$_target -d "$(_eval_json_file $_json_file)")
    echo $result

}

function ES_del() {
    local _target=$1

    local result=
    result=$(curl -s -XDELETE $ES_URL/$_target)
    echo $result
}


function ES_get() {
     local _target=$1
     local _json_file=$2

     local result=

    [ "$_json_file" == "" ] && result=$(curl -s -XGET $ES_URL/$_target)
    [ ! "$_json_file" == "" ] && result=$(curl -s -XGET $ES_URL/$_target -d "$(_eval_json_file $_json_file)")

    echo $result
}


function ES_get_nb_doc_by_type() {
    local _index=$1
    local _type=$2

    echo $(ES_get "/$_index/$_type/_count") | jq '.count'
}

function ES_get_doc_by_type() {
    local _index=$1
    local _type=$2
    local _maxsize=$3

    [ ! "$_maxsize" == "" ] && echo $(ES_get "/$_index/$_type/_search?size=$_maxsize" "es_search.json")
    [ "$_maxsize" == "" ] && echo $(ES_get "/$_index/$_type/_search" "es_search.json")
    
}

function ES_get_id_by_type() {
    local _index=$1
    local _type=$2
    local _maxsize=$3

    FIELDS='"id"'

    [ ! "$_maxsize" == "" ] && echo $(ES_get "/$_index/$_type/_search?size=$_maxsize" "es_search_fields.json") | jq -r '.hits.hits[]._id'
    [ "$_maxsize" == "" ] && echo $(ES_get "/$_index/$_type/_search" "es_search_fields.json") | jq -r '.hits.hits[]._id'
}

function ES_save_all_doc_by_type() {
    local _index=$1
    local _type=$2
    local _path=$3

    local _maxsize=$(ES_get_nb_doc_by_type "$_index" "$_type")
    
    echo " ** Saving $_maxsize document(s) of type $_type from index $_index **"
    
    mkdir -p $JSON_ROOT/$_path/$_index/$_type

    FIELDS='"id"'
    ES_get "/$_index/$_type/_search?size=$_maxsize" "es_search_fields.json" |  jq -r '.hits.hits[]._id | @uri' | while read id
    do
        $(ES_get "/$_index/$_type/$id" | jq -r '._source' > "$JSON_ROOT/$_path/$_index/$_type/$id.json")
    done
}

function ES_load_all_doc_by_type() {
    local _index=$1
    local _type=$2
    local _path=$3

    local _maxsize=$(ES_get_nb_doc_by_type "$_index" "$_type")
    
    echo " ** Loading  document(s) of type $_type into index $_index **"
    
    cd $JSON_ROOT/$_path/$_index/$_type
    local _id=
    for f in *; do
        _id=$(echo $f | sed "s/.json//g")
        [ -f "$f" ] && echo $(ES_put "/$_index/$_type/$_id" "$_path/$_index/$_type/$f")
    done

}

# INIT -----------------------------------------------------------------------------------

export FORCE=$FORCE


# PATH
JSON_ROOT=$STELLA_APP_ROOT/pool/json

$STELLA_API feature_info elasticsearch#1_5_0
export ES_HOME=$FEAT_INSTALL_ROOT
$STELLA_API feature_info kibana#4_0_1
export KIBANA_HOME=$FEAT_INSTALL_ROOT



# URL
ES_URL=$ESURL
KIBANA_URL=$KURL
MARVEL_UI=$ES_URL/_plugin/marvel
SENSE_UI=$MARVEL_UI/sense/index.html
KOPF_UI=$ES_URL/_plugin/kopf
BIGDESK_UI=$ES_URL/_plugin/bigdesk
HEAD_UI=$ES_URL/_plugin/head
HQ_UI=$ES_URL/_plugin/hq

# MAIN -----------------------------------------------------------------------------------

case $ACTION in
    ring)
        case $ID in


            info)
                info
            ;;

            ui)           
                open "$KIBANA_URL"
                sleep 1
                open "$KOPF_UI"
                open "$HEAD_UI"
                sleep 1
                open "$BIGDESK_UI"
                open "$HQ_UI"
                sleep 1
                open "$SENSE_UI"
            ;;
            purge)
                $0 kibana purge
                $0 es purge
            ;;

            register)
                $0 es register-all
                $0 river register-all
                $0 kibana register-all
            ;;

            uninstall)
                $STELLA_API del_folder $STELLA_APP_WORK_ROOT
            ;;

            install)
                echo "** get all requirement"
                $STELLA_API get_all_data

                echo "** install all features"
                $STELLA_API get_features

                cd $STELLA_APP_WORK_ROOT

                echo "** install plugin river jdbc"
                $ES_HOME/bin/plugin --remove jdbc 
                $ES_HOME/bin/plugin --install jdbc --url file:///$STELLA_APP_WORK_ROOT/es_plugin/river_jdbc/elasticsearch-river-jdbc-1.4.0.10.zip

                echo "** install plugin marvel"
                $ES_HOME/bin/plugin --remove marvel 
                $ES_HOME/bin/plugin --install marvel --url file:///$STELLA_APP_WORK_ROOT/es_plugin/marvel/marvel-1.3.0.zip

                echo "** install plugin bigdesk"
                $ES_HOME/bin/plugin --remove bigdesk
                $ES_HOME/bin/plugin --install bigdesk --url file:///$STELLA_APP_WORK_ROOT/es_plugin/bigdesk/bigdesk-2.5.0.zip

                echo "** install plugin kopf"
                $ES_HOME/bin/plugin --remove kopf
                $ES_HOME/bin/plugin --install kopf --url file:///$STELLA_APP_WORK_ROOT/es_plugin/kopf/elasticsearch-kopf-1.4.6.zip

                echo "** install plugin head"
                $ES_HOME/bin/plugin --remove head
                $ES_HOME/bin/plugin --install head --url file:///$STELLA_APP_WORK_ROOT/es_plugin/head/elasticsearch-head-master.zip

                echo "** install plugin HQ"
                $ES_HOME/bin/plugin --remove hq
                $ES_HOME/bin/plugin --install hq --url file:///$STELLA_APP_WORK_ROOT/es_plugin/hq/elasticsearch-HQ-master.zip


                if [ "" == "$(cat $ES_HOME/config/elasticsearch.yml | grep 'marvel.agent.enabled')" ]; then
                    echo 'marvel.agent.enabled: true' >> $ES_HOME/config/elasticsearch.yml
                fi
                # marvel : disable data collection 
                sed -i.bak 's/^\(marvel\.agent\.enabled:\).*/\1 false/' $ES_HOME/config/elasticsearch.yml 

                # for kibana 3.1.2
                if [ "" == "$(cat $ES_HOME/config/elasticsearch.yml | grep 'http.cors.enabled')" ]; then
                    echo 'http.cors.enabled: true' >> $ES_HOME/config/elasticsearch.yml
                    echo 'http.cors.allow-origin: http://localhost:8888' >> $ES_HOME/config/elasticsearch.yml
                else
                    sed -i.bak 's/^\(http\.cors\.enabled:\).*/\1 true/' $ES_HOME/config/elasticsearch.yml
                    sed -i.bak 's/^\(http\.cors\.allow-origin:\).*/\1 http:\/\/localhost:8888/' $ES_HOME/config/elasticsearch.yml 
                fi

                echo "** install mysql connector java"
                cp -f $STELLA_APP_WORK_ROOT/mysql-connector-java-5/*.jar $ES_HOME/plugins/jdbc/               
                
            ;;
        esac
    ;;
   



    es)
        case $ID in
            run)
                elasticsearch
            ;;

            purge)
                echo $(ES_del)
            ;;
            delete-index)
                echo $(ES_del "$INDEX")
            ;;

            register-index)
                echo $(ES_put "$INDEX")
            ;;

            delete)
                echo $(ES_del "$RESOURCE")
                ;;
            get)
                echo $(ES_get "$RESOURCE")
                ;;
            get-doc)
                echo $(ES_get_doc_by_type "$INDEX" "$DOCTYPE" "$MAXSIZE") | jq '.'
            ;;
            get-id)
                echo $(ES_get_id_by_type "$INDEX" "$DOCTYPE" "$MAXSIZE") | jq '.'
            ;;
        esac
    ;;

    




    kibana)
        case $ID in
            run)
                kibana
            ;;



            purge)
                echo " ** Delete kibana objects"
                $0 kibana delete-viz
                $0 kibana delete-dash
                $0 kibana delete-search
                $0 kibana delete-index
            ;;
            delete-viz)
                echo $(ES_del .kibana/visualization)
            ;;
            delete-dash)
                echo $(ES_del .kibana/dashboard)
            ;;
            delete-index)
                echo $(ES_del .kibana/index-pattern)
            ;;
            delete-search)
                echo $(ES_del .kibana/search)
            ;;



            register-all)
                echo " ** Register kibana objects"
                $0 kibana register-index
                $0 kibana register-search
                $0 kibana register-viz
                $0 kibana register-dash
            ;;
            register-viz)
                ES_load_all_doc_by_type ".kibana" "visualization"
            ;;
            register-dash)
                ES_load_all_doc_by_type ".kibana" "dashboard"
            ;;
            register-search)
                ES_load_all_doc_by_type ".kibana" "search"
            ;;
            register-index)
                ES_load_all_doc_by_type ".kibana" "index-pattern"
            ;;



            save-all)
                $0 kibana save-index
                $0 kibana save-search
                $0 kibana save-viz
                $0 kibana save-dash
            ;;
            save-viz)
                ES_save_all_doc_by_type ".kibana" "visualization"
            ;;
            save-dash)
                ES_save_all_doc_by_type ".kibana" "dashboard"
            ;;
            save-search)
                ES_save_all_doc_by_type ".kibana" "search"
            ;;
            save-index)
                ES_save_all_doc_by_type ".kibana" "index-pattern"
            ;;
            

           
        esac

    ;;




esac 
exit




