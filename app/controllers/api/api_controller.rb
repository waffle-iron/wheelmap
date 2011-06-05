class Api::ApiController < ApplicationController

  # Include Inherited Resources behaviour
  inherit_resources
  
  custom_actions :collection => :not_found
  
  # The order is essential, catch all exception first, fine grained exceptions to the bottom
  rescue_from Exception, :with => :render_500
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  
  PER_PAGE= 200
  PER_PAGE_MAX=500
  PAGE    = 1
  
  layout false
  
  # Allow requests withouth authenticity token
  skip_before_filter :verify_authenticity_token

  # If nothing is set, default to JSON
  before_filter :set_default_response_format

  # Make sure a valid API Key is provided
  before_filter :authenticate_by_token

  # If no param is set, default to PAGE
  before_filter :set_default_page
  
  # If no param is set, default to PER_PAGE
  before_filter :set_default_per_page
  
  def index
    @resources = [
      {
        :categories => {
          :description => 'The categories Collection Resource',
          :href => api_categories_path
        }
      },{
        :nodes => {
          :description => 'The nodes Collection Resource',
          :href => api_nodes_path
        }
      },{
        :node_types => {
          :description => 'The node_type Resource',
          :href => api_node_types_path
        }
      },{
        :locales => {
          :description => 'The locales Resource',
          :href => api_locales_path
        }
      }
      
    ]

    respond_to do |format|
      format.xml      {render :xml  => @resources.to_xml(:root => :resources)}
      format.json     {render :json => {:resources => @resources}.to_json}
    end
    
  end

  def not_found
    render_404(ActionController::RoutingError.new("No route matches '#{request.path}', check API root url for available resources: #{api_url(:locale => false)}"))
  end
  
  protected
  
  def set_default_response_format
    request.format = nil if request.format.to_sym == :html
    request.format ||= :json if params[:format].blank?
  end
  
  def set_default_page
    params[:page] ||= PAGE
    params[:page] = params[:page].to_i
  end
  
  def set_default_per_page
    params[:per_page] ||= PER_PAGE
    params[:per_page] = params[:per_page].to_i
    params[:per_page] = [params[:per_page], PER_PAGE_MAX].min
  end
  
  def render_404(exception)
    Rails.logger.error "404"
    render_exception(exception, 404)
  end
  
  def render_500(exception)
    render_exception(exception, 500)
  end
  
  def render_exception(exception, status)
    HoptoadNotifier.notify(exception, :component => self.class.name, :parameters => params)
    Rails.logger.error "[API] Exception #{exception.class}: #{exception.message}"#{}"\n#{exception.backtrace}"
    respond_to do |format|
      format.xml{render :xml => {:error => exception.message}.to_xml(:root => false), :status => status}
      format.json{render :json => {:error => exception.message}.to_json, :status => status}
    end
    
  end
  
  def current_user
    @current_user
  end
  
  def authenticate_by_token
    @current_user = User.find_by_authentication_token(params[:api_key])
    render_exception(Exception.new('invalid API key.'), 401) unless @current_user
  end
end