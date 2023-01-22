# TakeHomeSimple

This is a sample implementation of a relatively simple take home project received from a well known company whose
identity will be left private.

## A Brief History of Take Homes

I've had as of this writing a reasonably successful career as a software developer spanning over 15 years. The following
observations about take home projects have remained constant throughout:

- I have never gotten a position that required a take home project during the interview process.
- I have applied to a number of opportunities that required a take home project during the interview process.
- Most take home projects I have gotten have been mostly the same app: Fetch JSON data from a backend and display it
on a table.
- Every time I did a take home project, it took far far longer than the ostensible "5 or 6 hours" that they all
assume is the expected workload for the project.
- Every time I did a take home project it took at least two full work days to build up to a reasonable standard.
- Every time I did a take home project I delivered it to the requesting company and I never heard of it ever again but
for a curt "we are no longer considering you for the position" e-mail some time later. Normally because some other
candidate had already gotten the position.

As a result of the above I'm declaring myself done with the practice. It's a disrespectful way to deal with candidates
and appears to have about as little bearing on the future success of an employee as leetcode tests (that is, none).

However having done several of these during my last job search and not being against the ostensible goal of these
projects, that being the delivery of some work authored by the candidate for evaluation, I figured out I can just
publish the last set publically and point future take-home requesters to the pool of them. If they insist on getting
some other project done instead, I will happily let them go employ some other candidate.

## The project:

This was a relatively simple and well scoped project as far as these things go. Ostensibly the company wanted something
that wasn't fully built so more work could be done on top during later interview practices. In practice it fell to the
same fate as all others (as detailed above).

The project description made it clear that a best possible effort wasn't the goal of the exercise, and this
implementation took that to heart, taking care of the basics and building no more than the requested functionality but
in a way that would make further build up work easy to get on.

The project aim was to build a dummy "employee directory" based on data fetched from a backend. The "backend" in this
case was a set of URLs that returned a plain JSON file. I included those files —there were several samples— in the
project as assets for unit testing data decoding, but company-identifying information has been removed.

Company-identifying information has also been removed from the URLs in the app. As a result the app can be built but
will not work as is. Search and replace for `<private>` to find the places where you would need to fill in the real
information.

The recruitment process requested a questionnaire be filled up and returned with the take home project. It has been
included here as "Questionnaire.md"
