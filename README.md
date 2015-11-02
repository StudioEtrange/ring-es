# ring-es
Simple bash elasticsearch management

_built upon stella toolkit_

## Installation

	git clone https://github.com/StudioEtrange/ring-es

NOTE : At first launch, stella will be auto downloaded and installed. Or you can bootstrap stella by yourself with

	cd ring-es
	./stella-link.sh bootstrap

## Usage

	cd ring-es
	./do.sh --help


## Command line

	o-- GENERIC management :
	L     ring install <es|kibana|all> [--esver=<es version>] [--kver=<kibana version>: install ES, KIBANA or both
	L     ring uninstall all : uninstall everything
	L     ring purge all : delete every data, visualization, etc..
	L     ring show info : print some information
	L     ring show ui : open some web applications
	L     ring home es : return es home path
	L     ring home kibana : return es home path
	o-- ES management :
	L     es run <single|daemon> [--folder=<path>] [--heap=<size g>] : run elasticsearch -- folder path for log, if none log are disabled
	L     es kill now : stop all elasticsearch instances
	L     es purge all : erase everything in es
	L     es create <index> : create an index
	L     es delete <index> : delete an index
	L     es open <index> : open an index
	L     es close <index> : close an index
	o-- ES get request :
	L     es get id --index=<index> --doctype=<doctype> [--maxsize=<integer>] : print a list of id documents
	L     es get doc --index=<index> --doctype=<doctype> [--maxsize=<integer>] : print a list of documents
	o-- ES raw request :
	L     es get <resource> : get a resource from ES
	L     es <put|post> <resource> [--uri] : put or post a generic resource. uri option may be used to pass a json file
	L     es delete <resource> : delete a generic resource
	o-- ES backup management :
	L     bck save <index> [--repo=<path>] [--snap=<name>] : backup an index into a snapshot inside a repo location
	L     bck restore <index> [--repo=<path>] [--snap=<name>] : restore an index from a snapshot within a repo location
	L     bck snapshot list : list all existing snapshot
	L     bck snapshot status : print status of all current process belonging to back management
	o-- ES plugin management :
	L     plugin install <org/user/component/version> [--uri=<uri>] : install plugin. If uri is used, --plugin must be a plugin <component> name
	L     plugin delete <component> : remove plugin. <component> is the plugin name
	L     plugin specific <marvel|hq|head|kopf|shield> : install a specific plugin
	L     plugin marvel off : disable data collection for marvel
	L     plugin shield <add|del> --user --pass
	o-- KIBANA management :
	L     kibana run <single|daemon> [--folder=<path>] : run kibana -- folder path for log, if none log are disabled
	L     kibana kill now : stop all kibana instances
	L     kibana register all [--folder=<path>] : register all kibana objects [from a specific root folder]
	L     kibana register <viz|dash|pattern|search> [--folder=<path>] : register kibana visualization|dashboard|index-pattern|search [from a specific root folder]
	L     kibana save all [--folder=<path>] : save all kibana obects [into a specific root folder]
	L     kibana save <viz|dash|pattern|search> [--folder=<path>] : save all kibana visualization|dashboard|index-pattern|search [into a specific root folder]
	L     kibana delete all : erase all kibana objects
	L     kibana delete <viz|dash|pattern|search> : erase all kibana visualization|dashboard|index-pattern|search

