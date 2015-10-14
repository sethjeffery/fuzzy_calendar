module EventHelper
  def click_dates(picker_selector, *dates)
    within picker_selector do
      dates.each do |date|
        find(".picker-cell[data-date='#{date.strftime('%F')}']").click
      end
    end

  end
end
