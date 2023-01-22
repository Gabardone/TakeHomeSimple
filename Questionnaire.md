## Build tools & versions used

Xcode 14.2 on macOS Monterey 12.6.2.

## Steps to run the app

Build and run with Xcode 14.2+ on any device or simulator running latest iOS 16.

## What areas of the app did you focus on?

- Ability to test sample flows within the app.
- Build up sensible data flows for ease of further development.
- Build up testable components.

## What was the reason for your focus? What problems were you trying to solve?

Not necessarily in the given order…:
- Thread the line between getting it done and keeping it from being a mess.
- Display how I approach these kinds of tasks (even if in a limited way).
- Make sure it works by the specifications given.

## How long did you spend on this project?

Didn't run a stopwatch but I'd say approaching 20 hours.

## Did you make any trade-offs for this project? What would you have done differently with more time?

Plenty! A few off the top of my head:
- No proper dependency injection setup.
- No snapshot tests for the UI components.
- Not enough unit test coverage for some components (i.e. image cache reentrancy validation).
- Data flows built to fit the very contrived, minimalistic specs, unlikely to survive contact with a real backend.
- FetchViewController could be refactored in easy to reuse components for managing initial data load for most any async
 flow.
  - Very likely to reuse with improvements in future take home projects 🤣
- Image cache does operate on strong assumptions about the format of the image URLs we will be getting.
  - Decomposing that part off should definitely make it reusable for future projects.
- UI very much slapped together (no designer specs tho...).
- _Extremely bonus feature_: A happy path UI test.

## What do you think is the weakest part of your project?

- No real allowances for data update management other than wholesale refresh.
- UI very much slapped together (a bit of storyboard here, some UIKit walls of code there, chunks of SwiftUI elsewhere…).

## Did you copy any code or dependencies? Please make sure to attribute them here!

Didn't end up doing so for this one. Haven't done take homes in a while so I expect to build up code to reuse for
further ones, but this one was the first.

## Is there any other information you’d like us to know?

The fact that the UI is built with pretty much every technology under the Sun is a combination of expediency,
convenience and just, to be honest, wanting to play along with SwiftUI a bit more than I normally get the opportunity
to do. I would make sure to settle for a consistent approach (or at least more consistent criteria) for a larger
project.
