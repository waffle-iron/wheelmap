class SearchController < ApplicationController
  
  URL = "http://nominatim.openstreetmap.org/search"
  # URL = "http://open.mapquestapi.com/nominatim/v1/search"
  DEFAULT_PARAMS = {:'accept-language' => I18n.locale, :limit => 10, :osm_type => 'N', :email => 'info@wheelmap.org'}
  USERAGENT = "Wheelmap v1.0, (http://wheelmap.org)"
  
  TIMEOUT = 1
  
  before_filter :check_for_search_term
  
  rescue_from Timeout::Error,     :with => :timeout
  rescue_from SocketError,        :with => :timeout
  
  def index
    @search_url   = URI.parse(URL)
    @http = Net::HTTP.new(@search_url.host, @search_url.port)
    @http.read_timeout = 2
    @http.open_timeout = 2
    @query = DEFAULT_PARAMS.reverse_merge({:q => params[:q]})
    respond_to do |wants|
      wants.js  {
        resp = make_request(:json)
        @result = ActiveSupport::JSON.decode(resp.body)
        render
      }
      wants.xml {
        resp = make_request(:xml)
        render :xml => resp.body
      }
      wants.json{
        resp = make_request(:json)
        render :json => ActiveSupport::JSON.decode(resp.body)
      }
      wants.html{
        resp = make_request(:json)
        @result = ActiveSupport::JSON.decode(resp.body)
        render
      }
    end
  end
  
private

  def make_request(format)
    @query.reverse_merge!(:format => format)
    resp = nil
    cache_key = "#{@search_url.path}?#{@query.to_param}"
    logger.info("Exist fragment? #{cache_key}")
    Rails.cache.fetch("#{cache_key}") do
      @http.start do |http|
        logger.info("Write fragment #{cache_key}")
        req = Net::HTTP::Get.new("#{cache_key}", {'User-Agent' => USERAGENT})
        resp = http.request(req)
      end
    end
    return resp
  end
    
  def check_for_search_term
    if params[:q].blank?
      @message = I18n.t('nodes.errors.param_missing', :param => 'q')
      render :action => 'shared/error', :status => 406
    end
  end
  
end
