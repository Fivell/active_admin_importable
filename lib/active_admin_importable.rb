require 'active_admin_importable/version'
require 'active_admin_importable/engine'
require 'active_admin_importable/dsl'

require 'active_admin_importable/importer'
require 'active_admin_importable/importer/csv'


::ActiveAdmin::DSL.send(:include, ActiveAdminImportable::DSL)
