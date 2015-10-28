## Intro

* #When2TestURTest
* @NYCselenium

[slide]
## When to Test the Tests

* There was a discussion in some community forum several years ago about
  whether you should test your tests
* I unfortunately couldn't find it
* The gist of it is that testing your tests is almost certainly an
  anti-pattern, and you shouldn't do it.
* But this talk is about some attempts I made to do so

[slide]
## About Me
[slide]
* Father to Belle.
* This photo has nothing to do with my talk. I am
  shamelessly trying to soften you guys up with my daughter's cuteness.

[slide]
* I was the software testing practice lead at a local ad tech company
  until that company was restructured last week, eliminating my position
  there.
* So I'm currently catching up on reading and conference talks and enjoying
  funemployment.
* If any of you want to hire me, please come talk afterwards.

* That also means I have been very busy, and I haven't practiced this
  talk at all.
* So please give me feedback about it.

* Also, this can be interactive. Ask questions as I go if you want.

[slide]
## Software Testing Practice Lead WTF?

* Yeah, so what is a practice?
* Here's a quote

[slide]
> The term _practice_ is used here in the sense it has in an expression like
  “reasonable medical practice” used to justify a doctor’s action in a
  malpractice lawsuit. It denotes a set of socially defined ways of doing
  things in a specific domain: a set of common approaches and shared standards
  that create a basis for action, communication, problem solving, performance, and accountability.

  Wenger, Etienne; McDermott, Richard A.; Snyder, William (2002-01-08). Cultivating Communities of Practice: A Guide to Managing Knowledge (p. 38). Harvard Business Review Press. Kindle Edition.

* We, in this room, qualify as a community of practice.

* This question is relevant here, because of a recurring theme you will
  hear in my talk.
* That theme is the idea that if you are using tests merely as automated
  quality assurance, you are missing much, or perhaps most of their value.
* So I think that part of my job, both at my former position and in
  my talk here tonight, is to convince the community that this statement is
  true.
[slide]
* If you are using tests merely as automated quality assurance, you are missing much, or perhaps most of their value.


[slide]
## Manifesto for Agile Software Testing

* And so, along those lines...

* We have come to value continuous improvement and emergent design over
  quality assurance and risk mitigation.
* That is, while there is value in the items on the right, we value the
  items on the left more.
* Signatories: Wesley Harris, _Your Name Here_

* As far as I know this is not a thing.
* But maybe it should be.
* Maybe tonight, we the software testing community of New York City
  should decide that this is a thing.

[slide]
## Acceptance-Test-Driven Development

* Before we dive in and start talking about our system under test, let's
  get straight on some terms.
* Who here thinks they have a handle on what ATDD means?
* It's OK if you don't. We are here to learn.
* Who here is working on teams practicing it? Or have done so in the
  past?

[slide]
* What I would call the canonical treatment of the subject is this book
* _Growing Object-Oriented Software Guided by Tests_ by Nat Pryce and Steve
  Freeman.
* Commonly known as GOOS
* I highly recommend this book
* It has a very detailed description of a
  Java project built using ATDD from scratch.

* Who here uses Cucumber or some Gherkin-syntax interpreter?
* And does everyone know what I'm talking about when I say that?
* If you know Cucumber, you are at least aware of Behavior-Driven Development
* BDD is a close relative of ATDD, mixing in concepts from Domain-Driven
  Design
* I'll make reference to a couple of those concepts later.

[slide]
### The ATDD Cycle

* What does ATDD look like?

* To radically oversimply, you start with a failing acceptance test
* You might write that failing acceptance test using something like
  Cucumber
* But that's certainly not required

* You then use the TDD cycle of red-green-refactor
* Write a test, watch it fail, write the code to make it pass
* to build out the functionality to make the acceptance test pass
* And then you do it over again.

* I do want to make one thing clear here, because I come across this
  misconcpetion sometimes.
* Doing TDD does not just mean "I have tests."
* Doing BDD does not just mean "I use Cucumber."

* Instead, they mean theat I write the tests first, and I listen to what those
  tests are telling me about the design of the system under test.

* For the purposes of tonight's example
* It's the failing acceptance test I'm most interested in here.

[slide]
## What might tests be telling you?

* Many things, but in particular:
* If a system is very hard to test, that might be telling you something
  about the system itself.
* And it might be telling you something that you need to know about the
  team dynamics developing in your group.

[slide]
## The System

* Let's talk about our system under test

* I build a test harness for this system

* Our system built predictive models that predicted user behavior on
  the web, specifically on commerce sites.
* The behavior we were trying to predict is
* How likely is it that this user will buy something?
* You can imagine all kinds of reasons why that might be useful
  information, right?

[slide]
* Our system had several components
* Let's talk about them briefly

* JobLauncher: launches batch jobs on EMR to build these predictive models
* ModelBuilder: a MapReduce program to train the models
* MySQL: to persist the models once built
* ElasticMapReduce: Amazon's Hadoop as a service
* EC2: the actual Hadoop nodes in the EMR cluster

[slide]
## The Problem

* Let's talk about the problem we were trying to solve with a test
  harness to test this system

* We had been using a local Hadoop node for testing per the recommendation of
  the interwebs.
* But there were lots of reasons why this approach, which lacked
  production parity, failed to catch a lot of issues with our production
  stack.
[slide]
* As you can see in our system diagram, there are lots of places for
  something to go wrong.

* For the testers in the room, I want to point something out.
* The purpose of these tests isn't actually to evaluate how _useful_ the
  models are at making predictions.
* The models can be automatically backtested on data from a
  different time window than the data with which it was trained.
* So that we can understand their predictive power.

* Rather, we needed a way to easily validate that the whole pipeline was
  correctly integrated.
* And we wanted to validate that certain outputs from steps in our
  workflow were "correct."

* For example, in order to train machine learning models, we must be
  able to [slide] massage our data into a useful format.
* That massaging, or extraction as we called it, was unit tested.
* But occasionally it would fail in unexpected ways.
[slide]
* A failure might manifest as all zero scores for a particular class of
  data in the output of a particular MapReduce step.
* We could test for that. We could look for zeroes in that output.

[slide]
* We also wanted to sample down the data we were using in our tests.
* Hadoop and Hadoop on EMR are slow. We wanted to automatically
  sample down the amount of data we were using to speed up our tests.
* But they were never fast.

[slide]
## What the test harness should do

* Compile and deploy JobLauncher
* Configure JobLauncher for our test environment
* Deploy ModelBuilder to S3, where it would be available to EMR nodes

* We were effectively designing a test environment for this
  system.

[slide]
## Technology Choices

[slide]
### Ruby

* Everything I described above is basically pure automation.
* Ruby is good for automation.
* The techops people often reach for Ruby for that reason.

### Cucumber

* We also chose Cucumber.

* A word about cucumber: I have never seen it used well.
[slide]
* If you are interested in it, read _The Cucumber Book_ by Matt Wynne
  and Aslak Hellesoy.
* In it, you will find the authors directly quoting Eric Evans, the
  author of _Domain Driven Design_
* I mentioned that earlier.
* What they say is this:
* The purpose of cucumber is to facilitate a common language on teams,
  what Evans calls the Ubiquitous Language of the team.

* You should not use cucumber as an awkward scripting language.
* That's how Nat Pryce, one of the authors of GOOS, put it recently in a talk he gave.
* Instead, it is a tool to drive out this Ubiquitous Language, to name
  concepts in the domain that the whole team can use.
* Product people too

[slide]
* You drive out this language in a 3 Amigos Meeting.
* Everyone know about that concept?
* A developer, tester, and product owner get together to describe the
  behavior you want to see in the system.
* And you name the domain concepts relevant to that behavior.
* This happens BEFORE any coding, and you avoid details about the technical
  implementation.

* In practice, 3 Amigos is a simplification.
* You really just need to gather all the expertise you need in a room
  and have a conversation.

* But despite my never having seen Cucumber used well, I was confident in my
  team's ability to do so.
* So we decided to use it. In Ruby, that means that you use Cucumber as
  the test runner.

[slide]
### RSpec

* We chose rspec-expectations for the assertion library.
* And we ended up writing some custom expectations that I'll describe later.

### ActiveRecord

* We also built a couple of simple ActiveRecord models in order to easily make
  assertions about the state of the database.

### ATDD Code Examples

#### JobLauncher abstraction

* In the description for this talk
* I mentioned that one way we can test our tests is use ATDD to develop
  complex test harnesses.
* So let's look at an example of how that's done.

[show feature file]

* We have this JobLauncher driver feature

* In this case, our customers are software engineers
* But we're still avoiding overly technical language

* We know that we will need to be able to drive JobLauncher
* To start it up, launch jobs with it, et cetera

* What happens if we run this without step definitions?
* Cucumber complains

* So we need to fill out some step definitions
* And we're going to do that by writing the code we wished we had

* [Example]

* This scenario is not actually useful.
* JobLauncher itself has tests already.
* This test is only hear to force us to write the code to implement it.

* Now what happens if we run it?


[slide]
#### Testing your tests using ATDD

* Does everybody get the basic idea here?

* I would say this is actually a good idea
* It helps combat the blank page problem
* By forcing you to write some code, any code
* And letting the tests tell you what to do next

* It will encourage good OO in your test harness
* The abstractions that you build around your application under test
  will be easy to understand
* And they will encapsulate information about your application, so that
  you don't find it littered throughout your test suite

* Many of you are already using OO in your test suites
* This is the Selenium Meetup, so many of you will be using Page Object
  Models

* If so, you already know this:
* OO will make your tests easier to write and maintain

[slide]
## V2 and Unit Testing Custom Assertions

* But I promised to talk about another reason to test your tests.
* One that is not such a good idea.

[slide]
* For many reasons, our first attempt was super flaky.
* Tests sometimes passed and sometimes failed because of bugs in the
  test harness.
* Having tests that you don't trust is worse than having no tests at
  all.

[slide]
* We had a lot of race conditions where we failed to wait for the
  correct state in the system before making assertions about it.
* Those of you doing UI testing using Selenium know the kind of race
  condition I'm talking about.
* You make an assertion about an element on a page before it appears.

### Re-implementing tail

* Here's an example of the kind of test I'm talking about here
* We need to read the application log to find out if the JobLauncher application is
  fully initialized and ready to accept requests.
* That's how we wanted to avoid one of the race conditions we had.
* But we also need to parse job state out of the logs.
* In particular, we need to know the job's ID out on EMR so that we can
  poll Amazon about the state of the associated MapReduce job.

[slide]
* In other words, we needed tail

* This log-tailing functionality is complex and needs a test
* [Example]

* I'm calling this a unit test.
* It's not really, because it touches the filesystem.
* We could write it so we didn't use real IO, but there's a much bigger
  problem here.

* Who can tell me what the problem is here?
* What's missing?
[slide]
* A reliable way to find out about system state!
* We just re-implemented tail in Ruby. That's ridiculous.

* Surely testing isn't the only reason somebody would want to know about
  the state of a job?
* In fact no. This functionality belongs in the application!

### Pushing #correct? down into the harness

* Here's another example...

* These tests are as slow as the underlying jobs even with sampled data.
* We need some way to test if our assertions are correct without waiting
  for the entire workflow to run.
* Thus, we began unit testing our assertions using this #correct?
  method.

* [Example]

* ModelStats is a subclass of JobOutput.
* By the way, using #correct? in our custom expectation is an example of the Liskov Substitution
  Principle.
* That principle states that we should be able to use the methods on a
  derived class just as if we were using the base class.

* In other words, they share an interface.
* That allows us to write generic helper methods and expectations about
  job output that can be used with any type of job output
* We simply need to define the #correct? method on the new type of job
  output to make use of those generic helpers.

* Creating new step definitions with new output types becomes simple.

* If you are using Cucumber, remember this.
* You know what I don't want to see in step definitions?
* Logic.

* [Example step definition]

* Step definitions should be composed using helper objects.
* The test for this is that it should be fairly trivial for me to
  replace Cucumber with another test runner in your suite.
* What I call the test harness, which is the library of abstractions you use to
  drive the application under test, this remains stable.
* Some of you out there already hate Cucumber and probably like this
  idea specifically because it makes Cucumber easy to deprecate in your
  stack.
* But probably the best reason for doing so is that when you want to write _new_ step
  definitions, this becomes very easy to do because you can just reach
  for your helper methods.
* If you have ever tried to factor smaller tests out of a tangle of
  helper objects and logic inside step definitions, you know what I'm
  talking about.

* Step definitions should read like little stories.

### What's wrong here?

* But does anybody see what's wrong here?
* It's actually the same problem but a little harder to see.

* It turns out that just like job state, testing for correctness in these job outputs also belongs in the application.
* It actually does not belong in the test harness.

* Let me explain.
* The ability to make sanity checks about the correctness of a predictive model
  actually belongs in the modeling pipeline itself.

[slide]
* Test in production.
* That's what I'm saying.

* Here's why.
[slide]
* Machine learning experts have a constellation of algorithms available
  to them to solve different kinds of problems.
* And they combine these models in novel ways to increase the predictive
  power of their systems.
* But we need to experiment to determine how best to do so.
[slide]
* That means getting production data flowing through the models as
  quickly as possible.
[slide]
* Then we can iterate.

* Building these models in test before deploying the code to production
  is really just duplication.
[slide]
* It happens to be pretty expensive duplication, because Hadoop
  clusters don't run cheap.

## What we learned about our stack

* What did we learn about our system by writing these tests?

[slide]
* We were tolerating too much risk in our workflow.
* Those sanity checks I mentioned belonged in the workflow itself.
* The testing for correctness in job outputs.
* They don't belong in the test harness.

* We learned that if you implement application logic in your tests, that's a major
  test smell.

* If it's duplicated in your app, you might have a testing silo.
* The person responsible for testing on your team might not know enough
  about the internals of the application.
* In fact, old-school blackbox testing suggests they shouldn't.
* I don't agree.

* What if you're writing application logic in your tests that isn't
  duplicated in the application?
* If it doesn't exist in your app, you might need it!

[slide]
* We needed to have been more sophisticated about "integration testing"
* I don't even like this term, because it's used as a catch-all.
* I suspect that it encourages a style of testing that wants to integrate all the things.

* Instead...
* Endeavor to test integrations along one boundary, not several all in one go.
* But that requires a system design that exposes those boundaries for
  testing.

[slide]
* So...
* We replaced our system with a small service-oriented architecture.
* The services attempt to follow a version of the single-responsibility
  principle. Note that you can do this without services.
* But the handy thing about those services is that they are trivial to test
  because they expose in this case a REST api.
* If you want to test the actual compiled artifact, you can do so with
  whatever simple HTTP client is available in your language.

* In this case, the UI came packaged with the REST API in the Clojure
  library the team chose.
* Also, this UI was not customer facing.
* So, how many UI tests did we write for this new solution? Who wants to
  guess?
[slide]
* Zero.

* One of the services that the team created was a single-purpose
  application to persist those models in the database.
* But it runs our sanity checks against them first.
[slide]
* That makes experimentation much less risky.

* Test in production.

* I don't want to leave the impression that we made these changes simply
  to make our system more easily testable.
* Instead, the point I'm trying to make is that in every case, there
  were good design and business reasons to make the same changes to the
  system that also made it easier to test.

## What we learned about our team

* We also learned some things about our team.

[slide]
* We got good about kickoff meetings. That was our version of the 3 amigos.
* We didn't usually pull out the Gherkin syntax in those meetings.
* Although I occasionally did. It's a simple way to get really explicit
  about what you want the system to do and what you want to call its
  components
* Even if you don't automate it.

* We also got better about avoiding details about technical
  implementations in these meetings.
* Instead we tried to focus on how the behavior of the system
  would change. The requirements for acceptance became clear
  collaboratively.

[slide]
* I would say that we discovered we had a testing silo.
[slide]
* And we ended up with a related problem: the hourglass problem
[slide]
* Do all of you know this diagram? The testing pyramid?
* Should we talk about it?
[slide]
* In the hourglass anti-pattern, our pyramid looks more like an hourglass.
* With lots of end-to-end tests on top.

[slide]
* Even though we have relatively few of these end-to-end tests for our
  machine-learning modeling pipeline, it's still an hourglass.
* The tests required a lot of development time.
* And they required a lot of maintenance.
* And they are very, very slow, even with the data sampling that we
  implemented.

* One way in which this problem arises is by having a totally separate
  function for writing these end-to-end tests.
* It is exacerbated in situations where the people in that function are
  manual QAs who have been taught to automate.
[slide]
* We should be testing, not automating.

* However...
* This problem is a better problem than the one many of us have had at
  some point.
* That problem is trying to get people to care about testing at all.
[slide]
* This is a situation where the convincing is done, but your tests have
  become a millstone around your neck, as Sandi Metz put it in a
  talk at RailsConf a couple of years ago.

* The danger in this situation is that you decide that testing isn't
  worth the effort.
[slide]
* When (not if) you find yourselves in this situation, don't let the
  pendulum swing too far back in the opposite direction.
* There are solutions to these problems.
* But they mean you will have to get even more sophisticated about
  testing.

* I was promoted out of that team where we built this test harness.
* But the tester who replaced me learned enough Clojure so
  that he was pairing on writing unit tests for their code.
* That is one model that I would promote for moving forward.
* I'll talk about that a little more in a second.

## How you can profit from our lessons

* How can you all profit from what we learned?

[slide]
* QAs and testers: learn to code, not script

* In our example, we transitioned to a service-oriented architecture.
* I wouldn't necessarily recommend doing that. Many people make the argument
  that it creates as many problems as it fixes.
* It certainly creates new testing and deployment challenges.

* But imagine that we had achieved that same decomposition of our system
  using libraries instead of services.
* In order to test along the boundaries --
* I mean the seams of the bounded contexts in the domain model
* That's the language of domain driven design again
* In order to test along these boundaries, we all need to be
  comfortable working with software libraries and writing tightly-scoped
  integration tests between them.

* We have to think of testing as a software engineering problem.
* For many organizations, that requires a shift in mindset.

[slide]
* For those of you who aren't QAs or testers: collaborate closely with
  them
* There is a tremendous amount of expertise inside their heads.
* So benefit from it.

[slide]
* One way to encourage collaboration is to use ATDD
[slide]
* with a tester and a developer pair programming.

* Not only will it bring acceptance testing expertise to the developer
* The tester will become better acquainted with the code
* And you will produce more maintanable tests (Don't go lean on your product and fat on your tests.)
* And hopefully you will produce more extensible code
* Because you will build testability into your applications

[slide]
* But you have to listen to your tests.

[slide]
* Questions?





## Don't use test simply as automated quality assurance

* Kinds of tests that you might write (budgeting reality)


### Tests serve many purposes
http://www.everytalk.tv/talks/2184-OreDev-Budgeting-Reality-a-New-Approach-to-Mock-Objects

* Justin Searls, in a talk he gave about mock objects, enumerates
  several purposes for tests:

* Acceptance: prove the app works as promised (and continues to work)
  * We have talked a little about this one tonight.
* Specification: examples of how the code behaves
  * If any of you use RSpec or one of its clones, you might be familiar
    with this one
* Regression: prevent bugs from coming back
  * This one is quite common, right?
* Design: shape code by listening to tests
  * That is TDD.
* Characterize: safely improve legacy code
  * This last idea comes from Michael Feathers, and there's an interesting
    discussion of how to use Cucumber for this purpose near the end of
    _The Cucumber Book_


