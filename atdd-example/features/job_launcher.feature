Feature: JobLauncher driver
  As a Data Engineer
  I want to run JobLauncher locally
  So that I know I haven't broken it

  Scenario: It launches a job
    Given JobLauncher is running
    When I launch a job
    Then the job will start running
    And the job can be stopped
