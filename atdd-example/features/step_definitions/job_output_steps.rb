RSpec::Matchers.define :be_correct do

  match do |job_outputs|
    job_outputs.all? { |o| o.correct? }
  end

  failure_message do |job_outputs|
    if job_outputs[0].output_url
      "expected job output at #{job_outputs[0].output_url} to be correct"
    elsif job_outputs[0]
      "the output url for job output #{job_outputs[0].class} is nil"
    else
      "no job outputs were created for this job"
    end
  end

end

def expect_output_to_be_correct(job)
    expect(job.job_outputs).to be_correct
end

Then /^the job output will be correct$/ do
  expect_output_to_be_correct(@job)
end
