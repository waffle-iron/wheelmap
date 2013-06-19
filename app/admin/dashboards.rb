ActiveAdmin::Dashboards.build do

  section "Power taggers", :priority => 1 do
    table_for User.order('tag_counter DESC').limit(10) do
      column :name do |u|
        link_to(u.full_name, admin_user_path(u))
      end
      column 'OSM', :osm_id do |u|
        if u.osm_username.blank?
          span u.osm_id
        else
          link_to u.osm_username, "#{OpenStreetMapConfig.oauth_site}/user/#{u.osm_username}"
        end
      end
      column 'POIs tagged', :tag_counter
    end
  end

  section "Power editors", :priority => 2 do
    table_for User.order('edit_counter DESC').limit(10) do
      column :name do |u|
        link_to(u.full_name, admin_user_path(u))
      end
      column 'OSM', :osm_id do |u|
        if u.osm_username.blank?
          span u.osm_id
        else
          link_to u.osm_username, "#{OpenStreetMapConfig.oauth_site}/user/#{u.osm_username}"
        end
      end
      column 'POIs edited', :edit_counter
    end
  end

  section "Power creators", :priority => 3 do
    table_for User.order('create_counter DESC').limit(10) do
      column :name do |user|
        link_to(user.full_name, admin_user_path(user))
      end
      column 'OSM', :osm_id do |u|
        if u.osm_username.blank?
          span u.osm_id
        else
          link_to u.osm_username, "#{OpenStreetMapConfig.oauth_site}/user/#{u.osm_username}"
        end
      end
      column 'POIs created', :create_counter
    end
  end

  section "Latest users", :priority => 4 do
    table_for User.order('created_at DESC').limit(10) do
      column :name do |user|
        link_to(user.full_name, admin_user_path(user))
      end
      column :created_at
    end
  end



  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.

  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end

  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end