require File.expand_path(File.join('config', 'application'))


map('/') { run ApplicationController }

# Allows method to be overridden if params[:_method] is set.
use Rack::MethodOverride
