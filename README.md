# Centralized Salesforce Development Framework
This framework was built using concepts that were first introduced by Dan Appleman in his book **Advanced Apex Programming** (a must-read for any Apex developer) and then further expanded in [a great blog post by Hari Krishnan](http://krishhari.wordpress.com/2013/07/22/an-architecture-framework-to-handle-triggers-in-the-force-com-platform/), with much of the code coming from the latter's open-sourced codebase. All credit for the work done in this project is due to them; all blame for any bugs should be directed to yours truly.

The main goals of this project were to add the following concepts (again taken from Dan's **Advanced Apex Programming**) to Hari's foundational framework:

* Entry Points for Asynchronous, Batch, & Scheduled Apex Operations
* Centralized Async Handling & Chaining via Scheduler Ping-Pong (Scheduled Apex <--> Batch Apex)
* Centralized Diagnostic Infrastructure
* Centralized Exception Handling
* Custom Stack Tracing for Debugging
* Custom Debug Log Storing, Clearing, & Emailing
* Concurrency Handling via Silent Logging & Recovery
* Comprehensive Application KillSwitch

Next Steps - Time permitting here are some other concepts/items I'd like to add to the framework:

* Static Resource Utilization for Loading Test Data & Toggling Features/Tests
* Configuration Page for Updating AppConfig Settings

Documentation was created using ApexDocs (originally developed by Aslam Bari and later improved by Steve Cox) and has been included as a zip file in the project

Happy Coding!