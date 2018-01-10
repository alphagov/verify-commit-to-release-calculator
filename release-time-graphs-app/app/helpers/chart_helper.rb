module ChartHelper
  def chart_options additional_options
    {
      library: {
        plotOptions: {
          series: {
            marker: {
              enabled: true
            }
          }
        },
        chart: {
          zoomType: 'x'
        }
      }
    }.merge(additional_options)
  end

  def date_format
    '%d-%m-%Y %T'
  end
end