# Centralized Salesforce Development Framework
This framework was originally built using concepts introduced by Dan Appleman in **Advanced Apex Programming** and then further expanded using the Domain, Selector, & Service layer patterns discussed in Andy Fawcett's **Force.com Enterprise Architecture** (both are must-reads for any Apex developer). 

Much of the original codebase came from an open-sourced respository that was developed by Hari Krishnan and discussed in further detail within [his great blog post](http://krishhari.wordpress.com/2013/07/22/an-architecture-framework-to-handle-triggers-in-the-force-com-platform/).

All credit for the work done in this project is due to them; all blame for any bugs should be directed to yours truly.

The main goals of this project were to add the following concepts (again taken from Dan's **Advanced Apex Programming** and Andy's **Force.com Enterprise Architecture**) to Hari's foundational framework:

* Entry Points for Asynchronous, Batch, & Scheduled Apex Operations
* Centralized Async Handling & Chaining via Queueable Apex
* Centralized Diagnostic Infrastructure
* Centralized Exception Handling
* Custom Stack Tracing for Debugging
* Custom Debug Log Storing, Clearing, & Emailing
* Concurrency Handling via Silent Logging & Recovery
* Comprehensive Application KillSwitch
* Apex Enterprise Patterns: Domain, Selector, & Service Layer
* Centralized Factory for Test Data Generation
* Custom Metadata Type Utilization for Obeying Org-Specific Field Requirements
* Custom Metadata Type Utilization for Disabling Tests on an Org-Specific Basis

Next Steps - Time permitting here are some other concepts/items I'd like to add to the framework:

* Configuration Page for Updating Config Settings

[Documentation](http://scottbcovert.github.io/Centralized-Salesforce-Dev-Framework/) was created using ApexDocs (originally developed by Aslam Bari and later improved by Steve Cox) and has been included in the project

Happy Coding!