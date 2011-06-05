class Api::NodesController < Api::ApiController
  defaults :resource_class => Poi

 actions :index, :show, :update, :create
 
 custom_actions :collection => :search
 
  
  
  # Make sure user authenticates itself using an api_key
  before_filter :authenticate_user!,        :only => [:update, :create]
  before_filter :authenticate_application!, :only => [:update, :create]
  
  has_scope :bbox
  has_scope :wheelchair
  
  def index
    index! do |format|
      format.xml      {render_for_api :simple, :xml  => @nodes, :root => :nodes, :meta => meta}
      format.json     {render_for_api :simple, :json => @nodes, :root => :nodes, :meta => meta}
      format.geojson  {render :json => @nodes.to_geojson}
    end
  end
  
  def search
    @nodes ||= end_of_association_chain.search(params[:q]).paginate(:page => params[:page], :per_page => params[:per_page])
    respond_to do |format|
      format.xml      {render_for_api :simple, :xml  => @nodes, :root => :nodes, :meta => meta}
      format.json     {render_for_api :simple, :json => @nodes, :root => :nodes, :meta => meta}
    end
  end
  
  def show
    show! do |format|
      format.xml    {render_for_api :simple, :xml  => @node, :root => :node}
      format.json   {render_for_api :simple, :json => @node, :root => :node}
    end
  end
  
  def update
    @node = OpenStreetMap::Node.new(params.stringify_keys!)
    if @node.valid?
      client = OpenStreetMap::OauthClient.new(current_user.access_token) if current_user.oauth_authorized?
      Delayed::Job.enqueue(UpdatingJob.new(@node, current_user, client))
      
      respond_to do |wants|
        wants.json{ render :json => {:message => 'OK'}.to_json, :status => 202 }
        wants.json{ render :xml  => {:message => 'OK'}.to_xml,  :status => 202 }
      end
      
    else
      respond_to do |wants|
        wants.json{ render :json => {:error => @node.errors}.to_json, :status => 400 }
        wants.json{ render :xml  => {:error => @node.errors}.to_xml,  :status => 400 }
      end
    end
  end
  
  def create
    @node = OpenStreetMap::Node.new(params)
    if @node.valid?
      client = OpenStreetMap::OauthClient.new(current_user.access_token) if current_user.oauth_authorized?
      Delayed::Job.enqueue(CreatingJob.new(@node, current_user, client))
      
      respond_to do |wants|
        wants.json{ render :json => {:message => 'OK'}.to_json, :status => 202 }
        wants.json{ render :xml  => {:message => 'OK'}.to_xml,  :status => 202 }
      end
      
    else
      respond_to do |wants|
        wants.json{ render :json => {:error => @node.errors}.to_json, :status => 400 }
        wants.json{ render :xml  => {:error => @node.errors}.to_xml,  :status => 400 }
      end
    end
  end
  
  protected
  
  def collection
    @nodes ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def meta
    @meta ||= {
      :conditions => {
        :page => params[:page],
        :per_page => params[:per_page],      
        :format => params[:format]
      },
      :meta => {
        :page => params[:page],
        :num_pages => collection.total_pages,
        :item_count_total => collection.total_entries,
        :item_count => collection.nitems
        }
      }
      @meta[:conditions][:search] = params[:q]    if params[:q]
      @meta[:conditions][:bbox]   = params[:bbox] if params[:bbox]
      @meta
  end
end