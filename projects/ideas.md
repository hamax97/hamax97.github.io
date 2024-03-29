# Project Ideas

- Aiming at learning how to make advanced Mongo queries:
  - Some sort of search engine?
  - Some tool that translates SQL into Mongo queries?
  - Would be nice to implement some searching algorithm, e.g: Google's page rank ...
  - How about searching over the Bible ??

- Aiming at learning how to use GraphQL:
  - Proxy to PokeAPI.

- Implement a GraphQL API Server that serves as proxy to all my other side projects:
   * The server and the services (side projects) will communicate using gRPC.
   * The clients of the API Server could be anything (CLI, APIs, GUIs, ...)
   * Implement some authentication and authorization mechanism.

- Make performance testing fun:
   * Create a video game that would allow you to:
   * Create a script by planning an "invasion";
   * Represent services as fortresses;
   * Constantly monitor services and show that as the health of the fortress;
   * Represent threads as multiple warriors/ships/guns/...;
   * Connect to a different server and execute the script;
   * Communicate constantly to check if the script failed/finished/...;
   * Execute distributedly as multiple armies/...;
   * View interactions between these warrios/ships and fortresses when the script starts;

- Use the New Relic student license to monitor all the services you've created:
   * [Node.js](https://newrelic.com/blog/best-practices/nodejs-application-monitoring)

- Create my own blockchain to fully understand how it works. Try using go.

- Contribute to the project containerd.

- Create an app that would map pencil strokes in your Galaxy tab to mouse interactions in your computer (for Linux, PC, and Tablet)

- Find a usecase for [Emotiv](https://www.emotiv.com/emotivpro/) and build something, I think it has an API. Endava has partnership too.

- To improve my Ruby skills:
  * A basic performance testing tool.

- A basic web app that allows to:
  * Search for a Bible passage.
  * If the user scrolls up/down further the passage requested, the app will request the passages required to fill the scroll.
  * The user can select the Bible version.
  * The search bar will be pinned to the top so that if the user scrolls dows the search bar will still be visible.
  * Use the API: https://scripture.api.bible/

- A hybrid web app that helps memorizing the Scriptures:
  * Read the booklet: An Approach to Extended Memorization of Scripture.
  * Include a feature to record the voice and compare against the Scripture verse, if the record matches the verse at least in 90% (or something), then it was successful.
  * The voice recording and comparison with the verse should happen real-time, like Google translator.
  * Include daily quotes from the Scriptures or old brothers in the faith as encouragement.
  * How about this technique of writing the first letters: https://www.youtube.com/watch?v=k8k_rNTDjJM

- A web app that helps creating meal plannings and custom recipes.

- A web app that shows in boxes a Rails application and when each box is clicked a more detailed view
of what's happening pops up.
  * To teach Rails?
  * Or to debug rails?

- A performance testing framework that easily integrates into CI/CD pipelines:
  - Tools: RSpec, Ruby.
  - Lets you tag specs with something like: `fail_if_slower_than: 0.5`.
  - Abstract away the concept of spec to something more general like: performance test case, ...
    - These specs would be something like integration/acceptance specs, but it could also be used with unit specs.
  - How about adding a memory threshold too?

  - The spec would run:
    - Ruby code.
    - A JMeter script.
    - A k6 script.
    - ...

  - Idea from Exercises for Chapter 9 in Effective Testing with RSpec 3: https://learning.oreilly.com/library/view/effective-testing-with/9781680502770/f_0080.xhtml#d24e24567

  - Important to consider, comment from reddit:

    ```
    I think failing right on CI will be disruptive. Somebody could try to get a bug fix in and got interrupted by a slow/flaky test of another person.

    I recommend that you aggregate the test results over many runs and identify which one is consistently slow. Sometimes the CI machine just randomly slows down and a single slow run won't lead you down wrong path.

    Some CI vendor may have this feature of aggregations already. Look into Insights of CircleCI.
    ```
