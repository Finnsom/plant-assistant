module ApplicationHelper
  def render_markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text)
  end

  def watering_status(plant)
    return "Never watered" if plant.last_watered_on.nil?

    days = (Date.today - plant.last_watered_on).to_i

    case days
    when 0 then "Watered today"
    when 1 then "Watered yesterday"
    else "Watered #{days} days ago"
    end
  end

  def watering_overdue?(plant)
    plant.last_watered_on.nil? || (Date.today - plant.last_watered_on).to_i > 7
  end
end
