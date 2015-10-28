require 'rspec/expectations'

RSpec::Matchers.define :be_active do
  match do |job|
    job.active? == true
  end
  failure_message do |job|
    "expected that job with id #{job.id} would be active"
  end
end

RSpec::Matchers.define :be_stopping do
  match do |job|
    job.active? == false
  end
  failure_message do |job|
    "expected that job with id #{job.id} would be stopping"
  end
end

Given(/^JobLauncher is running$/) do
  @job_launcher = JobLauncher.new("./JobLauncher.jar")
  @job_launcher.start!
  expect(@job_launcher.running?).to be_truthy
end

When(/^I launch a job$/) do
  @job = @job_launcher.job_for('extractRelevantFeatures')
  @job.launch!
end

Then(/^the job will start running$/) do
  expect(@job).to be_active
end

Then(/^the job can be stopped$/) do
  @job.terminate!

  @job.wait_while :active?, poll: 10

  expect(@job).to be_stopping
  @job = nil
end
