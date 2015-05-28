COPT="-s"
MLUSER=${MLUSER-admin}
MLPASS=${MLPASS-admin}
AUTH="--digest -u $MLUSER:$MLPASS"
BASE=http://localhost:8002/manage

function pkg_help {
    echo "The following packaging commands are defined:"
    echo " "
    echo "pkg_help"
    echo "pkg_database_configuration      [-xml|-json] database [filename]"
    echo "pkg_all_database_configurations [-xml|-json] [filename]"
    echo "pkg_server_configuration        [-xml|-json] [-modules] group server [filename]"
    echo "pkg_all_server_configurations   [-xml|-json] [filename]"
    echo "pkg_list                   [-xml|-json] [start] [length]"
    echo "pkg_create                 [-xml|-json] pkgname [filename]"
    echo "pkg_exists                 pkgname"
    echo "pkg_get                    pkgname [filename]"
    echo "pkg_add                    [-xml|-json] pkgname filename"
    echo "pkg_delete                 pkgname"
    echo "pkg_list_databases         [-xml|-json] pkgname [start] [length]"
    echo "pkg_database_exists        [-xml|-json] pkgname database"
    echo "pkg_get_database           [-xml|-json] pkgname database [filename]"
    echo "pkg_add_database           [-xml|-json] pkgname database filename"
    echo "pkg_add_database_config    [-xml|-json] pkgname database [database...]"
    echo "pkg_delete_database        [-xml|-json] pkgname database"
    echo "pkg_list_servers           [-xml|-json] pkgname [start] [length]"
    echo "pkg_server_exists          [-xml|-json] pkgname group server"
    echo "pkg_get_server             [-xml|-json] [-modules] pkgname group server [filename]"
    echo "pkg_add_server             [-xml|-json] [-modules] pkgname group server filename"
    echo "pkg_add_server_config      [-xml|-json] [-modules] pkgname group server [server...]"
    echo "pkg_delete_server          [-xml|-json] pkgname group server"
    echo "pkg_post                   pkgname filename"
    echo "pkg_diff                   [-xml|-json] [-only] pkgname [filename]"
    echo "pkg_errors                 [-xml|-json] [-installable] pkgname"
    echo "pkg_valid                  [-xml|-json] pkgname"
    echo "pkg_install                [-xml|-json] pkgname"
    echo "pkg_revert                 [-xml|-json] ticketnumber"
    echo " "
    echo "-xml|-json specifies the required return type. The format of data"
    echo "posted is determined by the filename (.json=JSON, anything else=XML)"
}

function pkg_database_configuration {
    # [-xml|-json] dbname [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 1 -o $# -gt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] database [filename]"
    else
        DB=$1
        FN=${2--}

        echo "Download database configuration: $DB" 1>&2

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/databases/$DB?view=package&format=$FMT" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/databases/$DB?view=package&format=$FMT"
    fi
}

function pkg_all_database_configurations {
    # [-xml|-json] [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -gt 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [filename]"
    else
        FN=${1--}

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/databases?view=package&format=$FMT" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/databases?view=package&format=$FMT"
    fi
}

function pkg_server_configuration {
    # [-xml|-json] [-modules] group server [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    local MOD=false

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-modules" ]; then
        MOD=true
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    else
        MOD=false
    fi

    if [ $# -lt 2 -o $# -gt 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-modules] group server [filename]"
    else
        GRP=$1
        SRV=$2
        FN=${3--}

        echo "Download server configuration: $SRV [$GRP]" 1>&2

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/servers/$SRV?view=package&format=$FMT&group-id=$GRP&modules=$MOD" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/servers/$SRV?view=package&format=$FMT&group-id=$GRP&modules=$MOD"
    fi
}

function pkg_all_server_configurations {
    # [-xml|-json] [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -gt 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [filename]"
    else
        FN=${1--}

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/servers?format=$FMT&view=package" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/servers?format=$FMT&view=package"
    fi
}

function pkg_list {
    # [-xml|-json] [start] [length]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -gt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] start [length]"
    else
        ACCEPT="application/$FMT"
        START="${1:-1}"
        LENGTH="${2:-10}"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages?start=$START&pageLength=$LENGTH&format=$FMT" 1>&2
        fi

        curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages?start=$START&pageLength=$LENGTH&format=$FMT"
    fi
}

function pkg_create {
    # [-xml|-json] pkgname [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 1 -o $# -gt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname [filename]"
    else
        PKG=$1
        CT="application/xml"
        DFLAG="--data-ascii"
        FN=${2-/dev/null}
        if [[ $FN == *json* ]]; then
            CT="application/json"
        fi
        if [[ $FN == *zip* ]]; then
            DFLAG="--data-binary"
            CT="application/zip"
        fi

        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST $AUTH $DFLAG @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages?pkgname=$PKG&format=$FMT" 1>&2
        fi

        curl $COPT -X POST $AUTH $DFLAG @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages?pkgname=$PKG&format=$FMT"
    fi
}

function pkg_exists {
    # pkgname
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME pkgname"
    else
        if [ $DEBUG = 1 ]; then
            echo curl $COPT --head $AUTH "$BASE/v2/packages/$1" 1>&2
        fi

        if [ `curl $COPT --head $AUTH "$BASE/v2/packages/$1" 2>/dev/null | grep "200 OK" | wc -l` = "1" ]; then
            echo "$1 exists"
        else
            echo "$1 does not exist"
        fi
    fi
}

function pkg_get {
    # pkgname [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    if [ $# -lt 1 -o $# -gt 2 ]; then
        echo "Usage: $FUNCNAME pkgname [filename]"
    else
        FN=${2--}
        echo "Download $1"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1"
    fi
}

function pkg_add {
    # [-xml|-json] pkgname filename
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname filename"
    else
        FN=$2
        CT="application/xml"
        if [[ $FN == *json* ]]; then
            CT="application/json"
        fi

        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1" 1>&2
        fi

        curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1"
    fi
}

function pkg_delete {
    # [-xml|-json] pkgname
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME pkgname"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X DELETE $AUTH -d /dev/null -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1" 1>&2
        fi

        curl $COPT -X DELETE $AUTH -d /dev/null -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1"
    fi
}

function pkg_list_databases {
    # [-xml|-json] pkgname [start] [length]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname start [length]"
    else
        ACCEPT="application/$FMT"
        START="${2:-1}"
        LENGTH="${3:-10}"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/databases?start=$START&pageLength=$LENGTH&format=$FMT" 1>&2
        fi

        curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/databases?start=$START&pageLength=$LENGTH&format=$FMT"
    fi
}

function pkg_database_exists {
    # [-xml|-json] pkgname database
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname database"
    else
        if [ $DEBUG = 1 ]; then
            echo curl $COPT --head $AUTH "$BASE/v2/packages/$1/databases/$2" 1>&2
        fi

        if [ `curl $COPT --head $AUTH "$BASE/v2/packages/$1/databases/$2" 2>/dev/null | grep "200 OK" | wc -l` = "1" ]; then
            echo "$2 exists in $1"
        else
            echo "$2 does not exist in $1"
        fi
    fi
}

function pkg_get_database {
    # [-xml|-json] pkgname database [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 2 -o $# -gt 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname database [filename]"
    else
        FN=${3--}
        echo "Download: $2 from $1" 1>&2

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1/databases/$2?format=$FMT" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1/databases/$2?format=$FMT"
    fi
}

function pkg_add_database {
    # [-xml|-json] pkgname database filename
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname database filename"
    else
        FN=$3
        CT="application/xml"
        if [[ $FN == *json* ]]; then
            CT="application/json"
        fi

        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/databases/$2" 1>&2
        fi

        curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/databases/$2"
    fi
}

function pkg_add_database_config {
    # [-xml|-json] pkgname database [database...]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname database [database...]"
    else
        # no debug support here
        PKG=$1
        shift
        for db in $*; do
            pkg_database_configuration -$FMT $db > /tmp/pkg.temp.$$.$FMT
            pkg_add -$FMT $PKG /tmp/pkg.temp.$$.$FMT
        done
        rm -f /tmp/pkg.temp.$$.$FMT
    fi
}

function pkg_delete_database {
    # [-xml|-json] pkgname database
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname database"
    else
        ACCEPT="application/$FMT"
        CT="application/xml"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X DELETE $AUTH -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/databases/$2" 1>&2
        fi

        curl $COPT -X DELETE $AUTH -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/databases/$2"
    fi
}

function pkg_list_servers {
    # [-xml|-json] pkgname [start] [length]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname start [length]"
    else
        ACCEPT="application/$FMT"
        START="${2:-1}"
        LENGTH="${3:-10}"

        if [ $DEBUG = 1 ]; then
            echo curl $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/servers?start=$START&pageLength=$LENGTH&format=$FMT" 1>&2
        fi

        curl $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/servers?start=$START&pageLength=$LENGTH&format=$FMT"
    fi
}

function pkg_server_exists {
    # [-xml|-json] pkgname group server
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname group server"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl --head $AUTH "$BASE/v2/packages/$1/servers/$3?group-id=$2" 1>&2
        fi

        if [ `curl --head $AUTH "$BASE/v2/packages/$1/servers/$3?group-id=$2" 2>/dev/null | grep "200 OK" | wc -l` = "1" ]; then
            echo "$2/$3 exists in $1"
        else
            echo "$2/$3 does not exist in $1"
        fi
    fi
}

function pkg_get_server {
    # [-xml|-json] [-modules] pkgname group server [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    local MOD=false

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-modules" ]; then
        MOD=true
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    else
        MOD=false
    fi

    if [ $# -lt 3 -o $# -gt 4 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-modules] pkgname group server [filename]"
    else
        FN=${4--}
        echo "Download: $2/$3 from $1" 1>&2

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1/servers/$3?group-id=$2&format=$FMT&modules=$MOD" 1>&2
        fi

        curl $COPT -o $FN $AUTH "$BASE/v2/packages/$1/servers/$3?group-id=$2&format=$FMT&modules=$MOD"
    fi
}

function pkg_add_server {
    # [-xml|-json] [-modules] pkgname group server filename
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    local MOD=false

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-modules" ]; then
        MOD=true
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    else
        MOD=false
    fi

    if [ $# != 4 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-modules] pkgname group server filename"
    else
        FN=$4
        CT="application/xml"
        if [[ $FN == *json* ]]; then
            CT="application/json"
        fi

        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/servers/$3?group-id=$2&modules=$MOD" 1>&2
        fi

        curl $COPT -X POST $AUTH -d @$FN -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/servers/$3?group-id=$2&modules=$MOD"
    fi
}

function pkg_add_server_config {
    # [-xml|-json] [-modules] pkgname group server [server...]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    local MOD=""

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-modules" ]; then
        MOD="-modules"
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    else
        MOD=""
    fi

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# -lt 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-modules] pkgname group server"
    else
        # no debug support here
        PKG=$1; shift
        GRP=$1; shift
        for srv in $*; do
            pkg_server_configuration -$FMT $MOD $GRP $srv > /tmp/pkg.temp.$$.$FMT
            pkg_add -$FMT $PKG /tmp/pkg.temp.$$.$FMT
        done
        rm -f /tmp/pkg.temp.$$.$FMT
    fi
}

function pkg_delete_server {
    # [-xml|-json] pkgname group server
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 3 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname group server"
    else
        ACCEPT="application/$FMT"
        CT="application/xml"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X DELETE $AUTH -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/servers/$3?group-id=$2" 1>&2
        fi

        curl $COPT -X DELETE $AUTH -H "Accept: $ACCEPT" -H "Content-Type: $CT" "$BASE/v2/packages/$1/servers/$3?group-id=$2"
    fi
}

function pkg_post {
    # pkgname filename
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    if [ $# -lt 2 -o $# -gt 2 ]; then
        echo "Usage: $FUNCNAME pkgname filename"
    else
        echo "Upload $1"

        DFLAG="--data-ascii"
        CT="application/xml"
        if [[ $2 == *zip* ]]; then
            DFLAG="--data-binary"
            CT="application/zip"
        fi

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST $AUTH $DFLAG @$2 -H "Content-Type: $CT" "$BASE/v2/packages?pkgname=$1" 1>&2
        fi

        curl $COPT -X POST $AUTH $DFLAG @$2 -H "Content-Type: $CT" "$BASE/v2/packages?pkgname=$1"
    fi
}

function pkg_diff {
    # [-xml|-json] [-only] pkgname [filename]
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    local VIEW=differences

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-only" ]; then
        VIEW=only-differences
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    fi

    if [ $# -lt 1 -o $# -gt 2 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-only] pkgname [filename]"
    else
        FN=${2--}
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -o $FN $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=$VIEW&format=$FMT" 1>&2
        fi

        curl $COPT -o $FN $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=$VIEW&format=$FMT"
    fi
}

function pkg_errors {
    # [-xml|-json] pkgname
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml
    INST=

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ "$1" = "-installable" ]; then
        INST="&installable=true"
        shift
        if [ "$1" = "-json" -o "$1" = "-xml" ]; then
            FMT=xml
            if [ $1 = "-json" ]; then FMT=json; fi
            shift
        fi
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] [-installable] pkgname"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=errors&format=$FMT$INST" 2>&1
        fi

        curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=errors&format=$FMT$INST"
    fi
}

function pkg_valid {
    # [-xml|-json] pkgname
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=valid&format=$FMT" 2>&1
        fi

        curl $COPT $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1?view=valid&format=$FMT"
    fi
}

function pkg_install {
    # [-xml|-json] pkgname
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] pkgname"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT --data-binary @/dev/null $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/install?format=$FMT" 1>&2
        fi

        curl $COPT --data-binary @/dev/null $AUTH -H "Accept: $ACCEPT" "$BASE/v2/packages/$1/install?format=$FMT"
    fi
}

function pkg_revert {
    # [-xml|-json] ticketnumber
    local DEBUG=0
    if [ "$1" = "-d" ]; then
        DEBUG=1
        shift
    fi

    local FMT=xml

    if [ "$1" = "-json" -o "$1" = "-xml" ]; then
        FMT=xml
        if [ $1 = "-json" ]; then FMT=json; fi
        shift
    fi

    if [ $# != 1 ]; then
        echo "Usage: $FUNCNAME [-xml|-json] ticketnumber"
    else
        ACCEPT="application/$FMT"

        if [ $DEBUG = 1 ]; then
            echo curl $COPT -X POST --data-binary @/dev/null $AUTH -H "Accept: $ACCEPT" "$BASE/v2/tickets/$1/revert" 1>&2
        fi

        curl $COPT -X POST --data-binary @/dev/null $AUTH -H "Accept: $ACCEPT" "$BASE/v2/tickets/$1/revert" 1>&2
    fi
}
