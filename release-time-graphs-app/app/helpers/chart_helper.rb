module ChartHelper
  def chart_options additional_options
    {
      library: {
        xAxis: {
          tickInterval: 7*24*60*60*1000
        },
             
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