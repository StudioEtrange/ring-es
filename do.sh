#!/bin/bash
_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
_CURRENT_RUNNING_DIR="$( cd "$( dirname "." )" && pwd )"
source $_CURRENT_FILE_DIR/stella-link.sh include


# TODO
# specific plugin shield : https://www.elastic.co/downloads/shield
# add more specific plugin 
function usage() {
    echo "USAGE :"
    echo "----------------"
    echo "List of commands"
    echo " o-- GENERIC management :"
    echo " L     ring install <es|kibana|all> [--esver=<es version>] [--kver=<kibana version>: install ES, KIBANA or both"
    echo " L     ring uninstall all : uninstall everything"
    echo " L     ring purge all : delete every data, visualization, etc.."
    echo " L     ring show info : print some information"
    echo " L     ring show ui : open some web applications"
    echo " L     ring home es : return es home path"
    echo " L     ring home kibana : return kibana home path"
    echo " L     ring list version : list kibana and elasticsearch available version"
    echo " o-- ES management :"
    echo " L     es run <single|daemon> [--folder=<path>] [--heap=<size g>] : run elasticsearch -- folder path for log, if none logs are disabled -- heap set ES_HEAP_SIZE"
    echo " L     es kill now : stop all elasticsearch instances"
    echo " L     es purge all : erase everything in es"
    echo " L     es create <index> : create an index"
    echo " L     es delete <index> : delete an index"
    echo " L     es open <index> : open an index"
    echo " L     es close <index> : close an index"
    echo " L     es listen <ip|interface> : set es listening interface or ip with network.host var. If it is an interface use this format : _eth0_"
    echo " L     es <map-save|map-register> <index> [--folder=<path>] : save|load mapping of an index"
    echo " o-- ES get request :"
    echo " L     es get id --index=<index> --doctype=<doctype> [--maxsize=<integer>] : print a list of id documents"
    echo " L     es get doc --index=<index> --doctype=<doctype> [--maxsize=<integer>] : print a list of documents"
    echo " o-- ES raw request :"
    echo " L     es get <resource> : get a resource from ES"
    echo " L     es <put|post> <resource> [--uri] : put or post a generic resource. uri option may be used to pass a json file"
    echo " L     es delete <resource> : delete a generic resource"
    echo " o-- ES backup management :"
    echo " L     bck save <index> [--repo=<path>] [--snap=<name>] : backup an index into a snapshot inside a repo location"
    echo " L     bck restore <index> [--repo=<path>] [--snap=<name>] : restore an index from a snapshot within a repo location"
    echo " L     bck snapshot list : list all existing snapshot"
    echo " L     bck snapshot status : print status of all current process belonging to back management"
    echo " o-- ES plugin management :"
    echo " L     plugin install <org/user/component/version> [--uri=<uri>] : install plugin. If uri is used, plugin must be a plugin <component> name"
    echo " L     plugin delete <component> : remove plugin. <component> is the plugin name"
    echo " L     plugin specific <marvel|hq|head|kopf|shield> : install a specific plugin"
    echo " L     plugin marvel off : disable data collection for marvel (NOTE : you have to restart ES)"
    echo " L     plugin shield <add|del> --user --pass"
    echo " o-- KIBANA plugin management :"
    echo " L     kplugin install <org/user/component/version> [--uri=<uri>] : install plugin. If uri is used, plugin must be a plugin <component> name"
    echo " L     kplugin delete <component> : remove plugin. <component> is the plugin name"
    echo " o-- KIBANA management :"
    echo " L     kibana run <single|daemon> [--folder=<path>] : run kibana -- folder path for log, if none logs are disabled"
    echo " L     kibana kill now : stop all kibana instances"
    echo " L     kibana register all [--folder=<path>] : register all kibana objects [from a specific root folder]"
    echo " L     kibana register <viz|dash|pattern|search> [--folder=<path>] : register kibana visualization|dashboard|index-pattern|search [from a specific root folder]"
    echo " L     kibana save all [--folder=<path>] : save all kibana obects [into a specific root folder]"
    echo " L     kibana save <viz|dash|pattern|search> [--folder=<path>] : save all kibana visualization|dashboard|index-pattern|search [into a specific root folder]"
    echo " L     kibana delete all : erase all kibana objects"
    echo " L     kibana delete <viz|dash|pattern|search> : erase all kibana visualization|dashboard|index-pattern|search"
    echo " L     kibana connect <http://ip:port> : connect kibana to a specific ES instance"
    

}

# COMMAND LINE -----------------------------------------------------------------------------------
PARAMETERS="
DOMAIN=						'' 			a				'kibana plugin kplugin bck es ring'
ACTION=                     ''            a             'connect listen map-register map-save list shield home kill delete save register purge run install delete specific marvel snapshot restore save get put post close open create show uninstall'
ID=							''			s 				''
"
OPTIONS="
FORCE=''							  'f'		  ''					b			0		'1'					  Force.
ESURL='http://localhost:9200'        'e'         'http://host:port'           s           0       ''              elasticsearch endpoint
KURL='http://localhost:5601'        'k'         'http://host:port'           s           0       ''              kibana endpoint
INDEX=''                             'i'         'index'                s           0       ''                      Index name.
DOCTYPE=''                             't'         'type'                s           0       ''                      Document type.
MAXSIZE=''                              ''         'integer'           s           0       ''                      Max number of result.
REPO=''                             'r'         'repository'                s           0       ''                      Snapshot repository
SNAP=''                             's'         'snapshot'                s           0       ''                      Snapshot id
URI=''                             'u'         ''                s           0       ''                      URI (http:// or file://)
FOLDER=''                             ''         'path'                s           0       ''                      Root folder
ESVER='1_7_3'                       ''         ''           s           0       ''              elasticsearch version
KVER='4_1_2'                        ''         ''           s           0       ''              elasticsearch version
USER=''                             ''         ''           s           0       ''              username
PASS=''                             ''         ''           s           0       ''              password
HEAP=''                             ''          'es heap size'          s           0       ''  set elasticsearch heap size when launch (use ES_HEAP_SIZE)
"

$STELLA_API argparse "$0" "$OPTIONS" "$PARAMETERS" "Ring Elasticsearch" "$(usage)" "" "$@"


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
    echo "** head UI : $HEAD_UI"
    echo "** HQ UI : $HQ_UI"
    echo ""
}



# ------- INTERNAL FUNCTIONS -------------
# eval a file content (might be used to evaluate variable inside a file)
function _eval_file_old() {
    local _json_file=$1

    _json_file=$($STELLA_API rel_to_abs_path "$_json_file" "$STELLA_CURRENT_RUNNING_DIR")

    #cat "$JSON_ROOT"/"$_json_file" | jq -r '.' | eval
    eval echo -e $(cat "$_json_file" | sed "s/\\\/\\\\\\\/g" | sed "s/\\\/\\\\\\\/g" | sed "s/\*/\\\\\*/g" | sed "s/\"/\\\\\"/g" | sed "s/{/\\\{/g" | sed "s/}/\\\}/g" | sed "s/(/\\\(/g" | sed "s/)/\\\)/g" | sed "s/\\[/\\\\\\[/g" | sed "s/\\]/\\\\\\]/g" | sed "s/\\</\\\\\\</g" | sed "s/\\>/\\\\\\>/g")
}

function _eval_file() {
    declare _file="$1"
    _file=$($STELLA_API rel_to_abs_path "$_file" "$STELLA_CURRENT_RUNNING_DIR")

    declare data=$(sed -E 's/\\\\+/\\\\\\/g' < "$_file") # replace two or more \ with three \ -- we need this to keep at least \\ in some vizualisations
    declare delimiter="__apply_shell_expansion_delimiter__"
    declare c="cat <<$delimiter"$'\n'"$data"$'\n'"$delimiter"
    eval "$c"
}


# -------- ES PRIMARY FUNCTIONS ----------------------------------------------------

function ES_put() {
    local _target=$1
    local _json_file=$2

    local result=
    [ "$DEBUG" == "1" ] && echo $(_eval_file $_json_file)

    [ "$_json_file" == "" ] && result=$(curl -s -XPUT $ES_URL/$_target)
    [ ! "$_json_file" == "" ] && result=$(curl -s -XPUT $ES_URL/$_target -d "$(_eval_file $_json_file)")
    echo $result
}


function ES_post() {
    local _target=$1
    local _json_file=$2

    local result=
    [ "$DEBUG" == "1" ] && echo $(_eval_file $_json_file)

    [ "$_json_file" == "" ] && result=$(curl -s -XPOST $ES_URL/$_target)
    [ ! "$_json_file" == "" ] && result=$(curl -s -XPOST $ES_URL/$_target -d "$(_eval_file $_json_file)")
   
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
    [ ! "$_json_file" == "" ] && result=$(curl -s -XGET $ES_URL/$_target -d "$(_eval_file $_json_file)")

    echo $result
}

# ---------- ES REQUEST DOC ----------------------------------------------------
# INDEX/TYPE ===> total number
function ES_get_nb_doc_by_type() {
    local _index=$1
    local _type=$2

    echo $(ES_get "$_index/$_type/_count") | jq '.count'
}

# INDEX/TYPE, [MAX NUMBER] ===> doc list
function ES_get_doc_list_by_type() {
    local _index=$1
    local _type=$2
    local _maxsize=$3

    [ ! "$_maxsize" == "" ] && echo $(ES_get "$_index/$_type/_search?size=$_maxsize" "$JSON_ROOT/es_search.json")
    [ "$_maxsize" == "" ] && echo $(ES_get "$_index/$_type/_search" "$JSON_ROOT/es_search.json")
    
}

# INDEX/TYPE, [MAX NUMBER] ===> id list
function ES_get_id_list_by_type() {
    local _index=$1
    local _type=$2
    local _maxsize=$3

    FIELDS='"id"'

    [ ! "$_maxsize" == "" ] && echo $(ES_get "$_index/$_type/_search?size=$_maxsize" "$JSON_ROOT/es_search_fields.json") | jq -r '.hits.hits[]._id'
    [ "$_maxsize" == "" ] && echo $(ES_get "$_index/$_type/_search" "$JSON_ROOT/es_search_fields.json") | jq -r '.hits.hits[]._id'
}


# ---------- ES SAVE/LOAD -----------------------------------------------------------------
function ES_save_mapping() {
    local _index=$1
    local _path=$2
    [ "$_path" == "" ] && _path=$SAVE_ROOT/json
    
    mkdir -p $_path/$_index

     $(ES_get "$_index/_mapping" | jq -r ".$_index" > "$_path/$_index/_mapping.json")
}

function ES_register_mapping() {
    local _index=$1
    local _path=$2

    [ "$_path" == "" ] && _path=$SAVE_ROOT/json

    echo $(ES_put "$_index" "$_path/$_index/_mapping.json")
}

# INDEX/TYPE, PATH ===> save doc into files
function ES_save_all_doc_by_type() {
    local _index=$1
    local _type=$2
    local _path=$3

    local _maxsize=$(ES_get_nb_doc_by_type "$_index" "$_type")
    
    echo " ** Saving $_maxsize document(s) of type $_type from index $_index **"
    
    [ "$_path" == "" ] && _path=$SAVE_ROOT/json
    
    mkdir -p $_path/$_index/$_type
    

    FIELDS='"id"'
    ES_get "$_index/$_type/_search?size=$_maxsize" "$JSON_ROOT/es_search_fields.json" |  jq -r '.hits.hits[]._id | @uri' | while read id
    do
        $(ES_get "$_index/$_type/$id" | jq -r '._source' > "$_path/$_index/$_type/$id.json")
    done
}

# INDEX/TYPE, PATH ===> load saved doc from files
function ES_load_all_doc_by_type() {
    local _index=$1
    local _type=$2
    local _path=$3

    local _maxsize=$(ES_get_nb_doc_by_type "$_index" "$_type")
    
    echo " ** Loading document(s) of type $_type into index $_index **"
    
    [ "$_path" == "" ] && _path=$SAVE_ROOT/json

    if [ -d "$_path/$_index/$_type" ]; then
        cd $_path/$_index/$_type

        local _id=
        for f in *; do
            _id=$(echo $f | sed "s/.json//g")
            [ -f "$f" ] && echo $(ES_put "$_index/$_type/$_id" "$_path/$_index/$_type/$f")
        done
    fi
}

# REPO_NAME,REPO_PATH ===> create snapshot repository
function ES_repo_create() {
    local _repo_name=$1
    REPO_PATH=$2

    echo $(ES_put "_snapshot/$_repo_name" "$JSON_ROOT/es_create_repo.json")
}

# REPO_NAME,SNAPSHOT_NAME,INDEX_LIST (list with comma separator) ===> snapshot a list of indices
function ES_snapshot_index() {
    local _repo_name=$1
    local _snapshot_name=$2
    local _list_index=$3

    INDEX_LIST=$_list_index

    echo $(ES_put "_snapshot/$_repo_name/$_snapshot_name" "$JSON_ROOT/es_create_snapshot.json")
}

# REPO_NAME,SNAPSHOT_NAME ===> restore a snapshot
function ES_snapshot_restore() {
    local _repo_name=$1
    local _snapshot_name=$2
    echo $(ES_post "_snapshot/$_repo_name/$_snapshot_name/_restore")
}

# ===> get a list of snapshot
function ES_snapshot_list() {
    echo $(ES_get "_snapshot/_all")
}

# REPO_NAME,SNAPSHOT_NAME ===> delete a snapshot
function ES_snapshot_delete() {
    local _repo_name=$1
    local _snapshot_name=$2
    echo $(ES_del "_snapshot/$_repo_name/$_snapshot_name")
}

# ===> get status of all snapshot
function ES_snapshot_status() {
    echo $(ES_get "_snapshot/_status")
}

#-------------- ES HIGH/LEVEL BACKUP -----------------------------------------------------------------------
# INDEX, REPO_PATH, [SNAPSHOT_NAME] ===> make a backup of a whole index. Repo path must be accessible by all ES shards. Snapshot name is the name of the backup.
function ES_index_backup() {
    local _index=$1
    local _repo_path=$2
    local _snapshot_name=$3

    # repository settings
    local _repo_name=repo_$_index
    [ "$_repo_path" == "" ] && _repo_path=$SAVE_ROOT/repositories/repo_$_index
    
    # snapshot settings
    [ "$_snapshot_name" == "" ] && _snapshot_name=snapshot_$_index


    ES_repo_create "$_repo_name" "$_repo_path"
    ES_snapshot_index "$_repo_name" "$_snapshot_name" "$_index"
}

# INDEX, REPO_PATH, [SNAPSHOT_NAME] ===> restore a backup of a whole index. Repo path must be accessible by all ES shards. Snapshot name is the name of the backup.
function ES_index_restore() {
    local _index=$1
    local _repo_path=$2
    local _snapshot_name=$3

    # repository settings
    local _repo_name=repo_$_index
    [ "$_repo_path" == "" ] && _repo_path=$SAVE_ROOT/repositories/repo_$_index

    # snapshot settings
    [ "$_snapshot_name" == "" ] && _snapshot_name=snapshot_$_index
    

    # However, an existing index can be only restored if it’s closed. 
    # The restore operation automatically opens restored indices if they were closed and creates new indices if they didn’t exist in the cluster.
    ES_close_index "$_index"

    ES_repo_create "$_repo_name" "$_repo_path"
    ES_snapshot_restore "$_repo_name" "$_snapshot_name"
}

# ---------- ES ADMINISTRATIVE FUNCTIONS -------------
# INDEX ===> close an index
function ES_close_index() {
    local _index=$1
    echo $(ES_post $_index/_close)
}

# INDEX ===> open an index
function ES_open_index() {
    local _index=$1
    echo $(ES_post $_index/_open)
}

# ===> close all indices
function ES_close_all_index() {
    echo $(ES_close_index _all)
}

# ===> open all indices
function ES_open_all_index() {
    echo $(ES_open_index _all)
}


# --------------------------- PROPERTIES --------------------------------------------------------

export FORCE=$FORCE


# PATH
JSON_ROOT=$STELLA_APP_ROOT/pool/json
SAVE_ROOT=$STELLA_APP_ROOT/pool/save

$STELLA_API feature_inspect elasticsearch
[ "$TEST_FEATURE" == "1" ] && export ES_HOME=$FEAT_INSTALL_ROOT
$STELLA_API feature_inspect kibana
[ "$TEST_FEATURE" == "1" ] && export KIBANA_HOME=$FEAT_INSTALL_ROOT


# URL
ES_URL=$ESURL
KIBANA_URL=$KURL
MARVEL_UI=$ES_URL/_plugin/marvel
SENSE_UI=$MARVEL_UI/sense/index.html
KOPF_UI=$ES_URL/_plugin/kopf
HEAD_UI=$ES_URL/_plugin/head
HQ_UI=$ES_URL/_plugin/hq

_proxy=
if [ ! "$STELLA_PROXY_ACTIVE" == "" ];then 
    _proxy="-DproxyPort=$STELLA_PROXY_PORT -DproxyHost=$STELLA_PROXY_HOST"
fi


# ----------------------------------- MAIN ------------------------------------------------
case $DOMAIN in
    # -----------------------------------------------------------------------------------
    ring)
        case $ACTION in
            list)
                echo "** elasticsearch available version"
                $STELLA_API list_feature_version "elasticsearch"

                echo "** kibana available version"
                $STELLA_API list_feature_version "kibana"
            ;;

            install)
                case $ID in 
                    all)
                        echo "** install all features"
                        $STELLA_API get_feature jq

                        $STELLA_API feature_install elasticsearch#"$ESVER" "HIDDEN"
                        $STELLA_API feature_install kibana#"$KVER" "HIDDEN"
                    ;;

                    es)
                        $STELLA_API get_feature jq
                        echo "** install elasticsearch"
                        $STELLA_API feature_install elasticsearch#"$ESVER" "HIDDEN"
                    ;;

                    kibana)
                        $STELLA_API get_feature jq
                        echo "** install kibana"
                        $STELLA_API feature_install kibana#"$KVER" "HIDDEN"

                    ;;
                esac
                
                cd $STELLA_APP_WORK_ROOT

                # for kibana 3.1.2
                # if [ "" == "$(cat $ES_HOME/config/elasticsearch.yml | grep 'http.cors.enabled')" ]; then
                #     echo 'http.cors.enabled: true' >> $ES_HOME/config/elasticsearch.yml
                #     echo 'http.cors.allow-origin: http://localhost:8888' >> $ES_HOME/config/elasticsearch.yml
                # else
                #     sed -i.bak 's/^\(http\.cors\.enabled:\).*/\1 true/' $ES_HOME/config/elasticsearch.yml
                #     sed -i.bak 's/^\(http\.cors\.allow-origin:\).*/\1 http:\/\/localhost:8888/' $ES_HOME/config/elasticsearch.yml 
                # fi
            ;;

            uninstall)
                $STELLA_API del_folder $STELLA_APP_WORK_ROOT
            ;;

            show)
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
                        open "$HQ_UI"
                        sleep 1
                        open "$SENSE_UI"
                    ;;
                esac           
            ;;

            purge)
                $0 kibana delete all
                $0 es purge all
            ;;

            home)
                case $ID in
                    es)
                        echo $ES_HOME
                    ;;
                    kibana)
                        echo $KIBANA_HOME
                    ;;
                esac
            ;;

            
        esac
    ;;
    # ---------------------------   --------------------------------------------------------
    es)
        case $ACTION in
            map-register)
                ES_register_mapping $ID "$FOLDER"
                ;;

            map-save)
                ES_save_mapping $ID "$FOLDER"
                ;;
            run)
                # https://www.elastic.co/guide/en/elasticsearch/guide/current/heap-sizing.html
                [ ! "$HEAP" == "" ] && export ES_HEAP_SIZE=$HEAP
                case $ID in 
                    single)
                        if [ "$FOLDER" == "" ]; then
                            elasticsearch
                        else
                            elasticsearch 1>$FOLDER/log.es.log 2>&1
                        fi
                    ;;

                    daemon)
                        if [ "$FOLDER" == "" ]; then
                            nohup -- elasticsearch 1>/dev/null 2>&1 &              
                        else
                            nohup -- elasticsearch 1>$FOLDER/log.es.log 2>&1 &
                        fi
                        sleep 1
                        echo " ** elasticsearch started with PID $(ps aux | grep [o]rg.elasticsearch.bootstrap.Elasticsearch | tr -s " " | cut -d" " -f 2)"
                        #echo " ** elasticsearch started with PID $(cat $STELLA_APP_WORK_ROOT/es.pid)"
                    ;;
                esac
            ;;

            kill)
                echo " ** elasticsearch PID $(ps aux | grep [o]rg.elasticsearch.bootstrap.Elasticsearch | tr -s " " | cut -d" " -f 2) stopping"
                kill $(ps aux | grep [o]rg.elasticsearch.bootstrap.Elasticsearch | tr -s " " | cut -d" " -f 2)
            ;;

            purge)
                # "*" means delete all index including hidden index (like .marvel or .kibana)
                # "_all" means delete all regular index
                echo $(ES_del "*")
            ;;

            create)
                echo $(ES_put "$ID")
            ;;

            put)
                echo $(ES_put "$ID" "$URI")
            ;;

            post)
                echo $(ES_post "$ID" "$URI")
            ;;
            
            open)
                ES_open_index $ID
            ;;

            close)
                ES_close_index $ID
            ;;
            delete)
                echo $(ES_del "$ID")
            ;;

            listen)
                echo "** ES will listening on $ID on next start"
                sed -i.bak 's/.*network.host.*//' $ES_HOME/config/elasticsearch.yml
                echo "network.host: $ID" >> $ES_HOME/config/elasticsearch.yml

                echo "** If you use Kibana, dont forget to connect it to this IP"
            ;;

            get)
                case $ID in 
                    id)
                        echo $(ES_get_id_list_by_type "$INDEX" "$DOCTYPE" "$MAXSIZE") | jq '.'
                    ;;
                    doc)
                        echo $(ES_get_doc_list_by_type "$INDEX" "$DOCTYPE" "$MAXSIZE") | jq '.'
                    ;;
                    *)
                         echo $(ES_get "$ID") | jq '.'
                    ;;
                esac

            ;;
        esac
    ;;   
    # -----------------------------------------------------------------------------------
    bck)
        case $ACTION in   
            save)
                ES_index_backup "$ID" "$REPO" "$SNAP"
            ;;

            restore)
                ES_index_restore "$ID" "$REPO" "$SNAP"
            ;;

            snapshot)
                case $ID in 
                    list)
                        echo $(ES_snapshot_list)
                    ;;

                    status)
                        echo $(ES_snapshot_status)
                    ;;
                esac  
            ;;
        esac
    ;;
    # -----------------------------------------------------------------------------------
    plugin)
        # VERS <2.x https://www.elastic.co/guide/en/elasticsearch/reference/1.6/modules-plugins.html
        # VERS >=2.x https://www.elastic.co/guide/en/elasticsearch/plugins/2.0/installation.html
        case $ACTION in  
            install)

                if [ "$URI" == "" ]; then
                    # Note : plugin must be an id (<org>/<user/component>/<version>)
                    if [[ ${ESVER:0:1} == "2" ]]; then
                        $ES_HOME/bin/plugin $_proxy install "$ID"
                    else
                        $ES_HOME/bin/plugin $_proxy --install "$ID"
                    fi
                else
                    # Note : plugin must be a plugin name (component)
                    if [[ ${ESVER:0:1} == "2" ]]; then
                        $ES_HOME/bin/plugin $_proxy install "$ID" "$URI"
                    else
                        $ES_HOME/bin/plugin $_proxy --install "$ID" --url "$URI"
                    fi
                fi
            ;;

            delete)
                if [[ ${ESVER:0:1} == "2" ]]; then
                    $ES_HOME/bin/plugin remove "$ID"
                else
                    $ES_HOME/bin/plugin --remove "$ID"
                fi
            ;;

            # TODO review install specific ES plugin for version => 2.x
            specific)
                case $ID in 
                    kopf)
                        kopf_url=$(curl -sL https://api.github.com/repos/lmenezes/elasticsearch-kopf/releases | jq -r '.[0] | .zipball_url')
                        $ES_HOME/bin/plugin $_proxy --install kopf --url $kopf_url
                        echo " ** GO TO ===> $ES_URL/_plugin/kopf"
                    ;;

                    head)
                        $ES_HOME/bin/plugin $_proxy --install mobz/elasticsearch-head
                        echo " ** GO TO ===> $ES_URL/_plugin/head"
                    ;;

                    hq)
                        $ES_HOME/bin/plugin $_proxy --install royrusso/elasticsearch-HQ
                        echo " ** GO TO ===> $ES_URL/_plugin/HQ"
                    ;;
                    marvel)
                        $ES_HOME/bin/plugin $_proxy --install elasticsearch/marvel/latest
                        if [ "" == "$(cat $ES_HOME/config/elasticsearch.yml | grep 'marvel.agent.enabled')" ]; then
                            echo 'marvel.agent.enabled: true' >> $ES_HOME/config/elasticsearch.yml
                        fi
                        echo " ** GO TO ===> $ES_URL/_plugin/marvel"
                        echo " ** for SenseUI ===> $ES_URL/_plugin/marvel/sense/index.html"
                    ;;
                    shield)
                        $ES_HOME/bin/plugin $_proxy --install elasticsearch/license/latest
                        $ES_HOME/bin/plugin $_proxy --install elasticsearch/shield/latest
                    ;;
                esac
            ;;

            marvel)
                case $ID in
                    off)
                        # marvel : disable data collection 
                        sed -i.bak 's/^\(marvel\.agent\.enabled:\).*/\1 false/' $ES_HOME/config/elasticsearch.yml 
                    ;; 
                esac
            ;;

            shield)
                case $ID in 
                    add)
                        $ES_HOME/bin/shield useradd $USER -p $PASS -r admin
                    ;;
                     del)
                        $ES_HOME/bin/shield userdel $USER
                    ;;
                esac
            ::
        esac
    ;;
    # -----------------------------------------------------------------------------------
    kplugin)
        # WORK with KIBANA VER => 4.2
        # NOTE for proxy, it use http_proxy env var
        case $ACTION in  
            install)

                if [ "$URI" == "" ]; then
                    # Note : plugin must be an id (<org>/<user/component>/<version>)
                    $KIBANA_HOME/bin/kibana plugin --install "$ID"
                else
                    # Note : plugin must be a plugin name (component)
                    $KIBANA_HOME/bin/kibana plugin --install "$ID" --url="$URI"
                fi
            ;;

            delete)
                $KIBANA_HOME/bin/kibana plugin --remove "$ID"
            ;;

            specific)
                case $ID in 
                    timelion)
                        timelion_url="https://github.com/elastic/timelion/archive/master.zip"
                        $KIBANA_HOME/bin/kibana plugin --install timelion --url=$timelion_url
                        echo " ** GO TO ===> $ES_URL/_plugin/timelion"
                    ;;

                esac
            ;;

        esac
    ;;
    # -----------------------------------------------------------------------------------
    kibana)
        case $ACTION in
            connect)
                echo "** Kibana will be connected to ES on $ID"
                sed -i.bak 's/.*elasticsearch.url.*//' $KIBANA_HOME/config/kibana.yml
                echo "elasticsearch.url: \"$ID\"" >> $KIBANA_HOME/config/kibana.yml
                ;;
            run)
                case $ID in 
                    single)
                        if [ "$FOLDER" == "" ]; then
                            kibana
                        else
                            kibana 1>/dev/null 2>&1
                        fi
                    ;;

                    daemon)
                        if [ "$FOLDER" == "" ]; then
                            nohup -- kibana 1>/dev/null 2>&1 &
                        else
                            nohup -- kibana 1>$FOLDER/log.kibana.log 2>&1 &
                        fi
                        echo " ** kibana started with PID $(ps aux | grep $KIBANA_HOME | grep node | tr -s " " | cut -d" " -f 2)"
                    ;;
                esac
            ;;
            kill)
                echo " ** kibana PID $(ps aux | grep $KIBANA_HOME | grep node | tr -s " " | cut -d" " -f 2) stopping"
                kill $(ps aux | grep $KIBANA_HOME | grep node | tr -s " " | cut -d" " -f 2)
            ;;
            register)
                case $ID in 
                    all)
                        echo " ** Register kibana objects"
                        $0 kibana register pattern --folder="$FOLDER"
                        $0 kibana register search --folder="$FOLDER"
                        $0 kibana register viz --folder="$FOLDER"
                        $0 kibana register dash --folder="$FOLDER"
                    ;;
                    
                    viz)
                        ES_load_all_doc_by_type ".kibana" "visualization" "$FOLDER"
                    ;;

                    dash)
                        ES_load_all_doc_by_type ".kibana" "dashboard" "$FOLDER"
                    ;;

                    pattern)
                        ES_load_all_doc_by_type ".kibana" "index-pattern" "$FOLDER"
                    ;;

                    search)
                        ES_load_all_doc_by_type ".kibana" "search" "$FOLDER"
                    ;;
                esac
            ;;
            save)
                case $ID in 
                    all)
                        echo " ** Saving kibana objects"
                        $0 kibana save pattern --folder="$FOLDER"
                        $0 kibana save search --folder="$FOLDER"
                        $0 kibana save viz --folder="$FOLDER"
                        $0 kibana save dash --folder="$FOLDER"
                    ;;
                    
                    viz)
                        ES_save_all_doc_by_type ".kibana" "visualization" "$FOLDER"
                    ;;

                    dash)
                        ES_save_all_doc_by_type ".kibana" "dashboard" "$FOLDER"
                    ;;

                    pattern)
                        ES_save_all_doc_by_type ".kibana" "index-pattern" "$FOLDER"
                         # TODO : hack for scripted fields
                        #sed -i.bak 's/\\\\\\/\\\\\\\\\\/g' $SEL_SAVE_ROOT/.kibana/index-pattern/sel_data.json
                        #rm $SEL_SAVE_ROOT/.kibana/index-pattern/sel_data.json.bak
                    ;;

                    search)
                        ES_save_all_doc_by_type ".kibana" "search" "$FOLDER"
                    ;;
                esac
            ;;
            delete)
                case $ID in 
                    all)
                        echo " ** Delete kibana objects"
                        $0 kibana delete dash
                        $0 kibana delete viz
                        $0 kibana delete search
                        $0 kibana delete pattern
                    ;;
                    viz)
                        echo $(ES_del .kibana/visualization)
                    ;;

                    dash)
                        echo $(ES_del .kibana/dashboard)
                    ;;

                    pattern)
                        echo $(ES_del .kibana/index-pattern)
                    ;;

                    search)
                        echo $(ES_del .kibana/search)
                    ;;
                esac
            ;;
            
        esac
    ;;
    # -----------------------------------------------------------------------------------

esac 
exit




