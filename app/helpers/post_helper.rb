module PostHelper
  def humanify(url)
    url.gsub(%r{https?://(www\.)?}, '').gsub(/(?<=^.{25}).+/, '...')
  end
end
