## ADAPTED FROM THE EICU DATABASE CREATION.

## --------------------------------------------------------------------------
## Description: Automated creation of the eICU database and importing of data
## --------------------------------------------------------------------------

# Set the following parameters to defaults
# These will be overwritten by settings passed to the makefile
DBNAME := mimiciv
DBUSER := mimiciv
DBPASS := mimiciv

export PGPASSWORD=$(DBPASS)

# NOTE: you do not need to specify localhost/port
# in fact, this is detrimental if you want to use peer (operating system level) authentication
# "localhost" uses a loopback, so peer authentication doesn't work with it
DBHOST :=
DBPORT :=

# when connecting, we use a single variable: DBSTRING
# **do not modify this**
# the create_mimic_user.sh script uses the above variables to create the DB/users
# so it's important to keep this DBSTRING consistent
DBSTRING := dbname=$(DBNAME) user=$(DBUSER)
ifneq ($(DBHOST),)
DBSTRING +=  host=$(DBHOST)
endif
ifneq ($(DBPORT),)
DBSTRING +=  port=$(DBPORT)
endif
# add ON_ERROR_STOP so scripts stop when they fail
DBSTRING +=  options=--search_path=$(DBSCHEMA)

initialize:
	@echo ''
	@echo '------------------'
	@echo '-- Initializing --'
	@echo '------------------'
	@echo ''
	@echo 'This creates the user, database, and schema, as necessary.'
	DBUSER="$(DBUSER)" DBNAME="$(DBNAME)" DBPASS="$(DBPASS)" DBHOST="$(DBHOST)" DBPORT="$(DBPORT)" ./create_mimiciv_user.sh

build-gz:
	@echo ''
	@echo '-----------------------'
	@echo '-- Building MIMIC-IV --'
	@echo '-----------------------'
	@echo ''
	@echo '---------------------'
	@echo '-- Creating tables --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f create.sql
	@echo ''
	@echo '-------------------------------------'
	@echo '-- Loading data from gzipped files --'
	@echo '-------------------------------------'
	@echo ''
	@sleep 2
	psql -a "$(DBSTRING)" -v ON_ERROR_STOP=1 -v mimic_data_dir=${mimic_data_dir} -f load_gz.sql

