#!/bin/bash
_STELLA_LINK_CURRENT_FILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ "$STELLA_ROOT" == "" ] && export STELLA_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR/../stella
[ "$STELLA_APP_ROOT" == "" ] && STELLA_APP_ROOT=$_STELLA_LINK_CURRENT_FILE_DIR

if [ "$1" == "include" ]||[ "$1" == "chaining" ]; then
	if [ ! -f "$STELLA_ROOT/stella.sh" ]; then
		if [ -f "$(dirname $STELLA_ROOT)/stella-link.sh" ]; then
			[ "$STELLA_SILENT" == "" ] && echo " ** Try to chain link stella from $(dirname $STELLA_ROOT)"
			source $(dirname $STELLA_ROOT)/stella-link.sh chaining
		else
			[ "$STELLA_SILENT" == "" ] && echo "** WARNING Stella is missing -- bootstraping stella"
			$_STELLA_LINK_CURRENT_FILE_DIR/stella-link.sh bootstrap
		fi
	else
		[ "$STELLA_SILENT" == "" ] && echo " ** Stella found : $STELLA_ROOT"
	fi
fi

ACTION=$1
case $ACTION in
	include)
		source "$STELLA_ROOT/conf.sh"
		__init_stella_env
		;;

	bootstrap)
		cd "$_STELLA_LINK_CURRENT_FILE_DIR"
		curl -sSL https://raw.githubusercontent.com/StudioEtrange/stella/master/nix/pool/stella-bridge.sh -o stella-bridge.sh
		chmod +x stella-bridge.sh
		./stella-bridge.sh bootstrap
		rm -f stella-bridge.sh
		;;
	nothing|chaining)
		;;
	*) 
		$STELLA_ROOT/stella.sh $*
		;;
esac
