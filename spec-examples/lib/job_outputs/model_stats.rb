require 'job_outputs'
require 'json'

class JobOutputs::ModelStats < JobOutputs::JobOutput
  def initialize(aws, output_url)
    @validation_functions = [
            lambda { area_under_pr > 0},
            lambda { area_under_roc > 0 }
    ]
    super(aws, output_url)
  end

  def output_path
    'model_stats'
  end

  def area_under_pr
    model_stats['area-under-pr']
  end

  def area_under_roc
    model_stats['area-under-roc']
  end

  private
  def model_stats
    @model_stats ||= begin
      {}.tap do |ms_hash|
        model_stats_array.each { |(k, v)| ms_hash[k] = v }
      end
    end
  end

  def model_stats_array
    @model_stats_array ||= JSON.parse(part_file.read.strip.gsub(/\s/, ',').insert(0, '[').insert(-1, ']'))
  end
end
