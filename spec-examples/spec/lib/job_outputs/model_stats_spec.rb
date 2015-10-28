require 'spec_helper'
require 'job_outputs/model_stats'

describe JobOutputs::ModelStats do

  before :each do
    model_stats_fixture = Pathname.new(__FILE__).join('../../../files/model_stats_fixture')
    model_stats_file = File.new(model_stats_fixture)
    aws = double("AWS")
    objects = double("ObjectCollection", :[] => model_stats_file)
    aws.stub_chain(:s3, :buckets, :[], :objects).
            and_return(objects)
    @model_stats = JobOutputs::ModelStats.new(aws, "http://some-url.com/path")
  end

  it "returns its area_under_pr" do
    expect(@model_stats.area_under_pr).to eq 0.3241193678379888
  end

  it "returns its area_under_roc" do
    expect(@model_stats.area_under_roc).to eq 0.7764983606342964
  end

  it "knows if it is correct" do
    expect(@model_stats.correct?).to be_truthy
  end

end
