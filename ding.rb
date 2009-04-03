require 'rubygems'
require 'sinatra'

require 'environment'

helpers do
  def root_path
    "/"
  end
  def session_path(session)
    "/#{session.name}"
  end
  def session_timers_path(session)
    "#{session_path(session)}/timers"
  end

end

get '/' do
  redirect session_path(Session.create)
end

get '/:session' do
  @session = Session.first(:name => params[:session])
  redirect root_path unless @session
  haml :timers
end

post '/:session/timers' do
  session = Session.first(:name => params[:session])
  session.timers.create(:timer => params[:timer])
  redirect session_path(session)
end

