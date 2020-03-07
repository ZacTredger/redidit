module ApplicationHelper
  # Appends ' | Redidit' to title, or returns homepage title
  def full_title(title)
    site_name = 'Redidit'
    return site_name if title.blank?

    title + ' | ' + site_name
  end
end
