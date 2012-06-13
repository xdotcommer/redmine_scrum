module ScrumboardsHelper
  def image_or_name_for(developer)
    if File.exists?("#{RAILS_ROOT}/public/images/#{developer.name}.png")
      image_tag("#{developer.name}.png")
    else
      developer.name
    end
  end
end