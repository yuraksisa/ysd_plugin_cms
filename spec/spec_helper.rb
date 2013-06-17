require 'sinatra/base'
require 'sinatra/r18n'
require 'data_mapper'
require 'ysd_plugin_cms'
require 'ysd_yito_core'

class TestingSinatraApp < Sinatra::Base
  register Sinatra::R18n
  helpers  Sinatra::YitoJsonRequestExtractor
  set :raise_errors, true
  set :dump_errors, false
  set :show_exceptions, false
end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup :default, "sqlite3::memory:"
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize 

DataMapper.auto_migrate!