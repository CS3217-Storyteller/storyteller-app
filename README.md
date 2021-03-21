# CS3217 Project Sprint 1 Report - Storyteller

Marcus | Pan Yongjing | Tian Fang

## Requirements

### Overview

Give an introduction of your project, you can probably copy-paste a lot of stuff from the project proposal. We will however be reading through it carefully so if you simply copy-pasted and didn't bother to fix some minor inconsistencies, we will take off points.

### Features and Specifications

Here is where you list the features and specifications of your project. It should be updated as the project develops.

Be specific. For example, are your gizmos resizable? Are the bounding areas of the triangles triangles or rectangles etc. Highlight some practical issues as well. When a user presses a key and the flipper flips, what happens if the user continues to hold down the key? Does the flipper stay up?

### User Manual

This should be updated for every sprint cycle and documents at least how to use the implemented features. You may document incomplete features as a way to propose how the interactions will be done.

One thing that you can do is to have this section as a separate document altogether and simply say "Refer to 'Ultimate Gizmoball User Manual' attached or something." This manual should be detailed enough for a new user to use and discover all the features of your application.

You should describe how to use your program and include screenshots. Also, describe not just regular operation, but error conditions. If the user does something stupid, how does he/she recover from it.

See also [Documenting a Software System](https://cs3217.github.io/cs3217-docs/final-project-guidelines/documenting-a-software-system): A detailed description of how the user can use the system, what operations the user can perform, what the command line arguments are, etc. Detailed specifications of formats should be relegated to the [Appendix](https://cs3217.github.io/cs3217-docs/final-project-guidelines/sprint-report#appendix). Any environmental assumptions should be made explicit here: For instance, note if the program only runs on certain platforms, assumes a certain directory hierarchy is present, assumes certain other applications are present, etc. Along with the overview, this manual should provide all the information needed by a user of the system.

## Designs

### Overview (0.5 - 3 pages)

- Top-level organization
- Interesting design issues
- Use of libraries and other third party modules
- Describe any aspects that are unsettled or likely to change
- Also include problems with the design: decisions that may turn out to be wrong and tradeoffs between flexibility and performance that may turn out to be ill-judged.

The main thing we want to say here is that it's not about WHAT you do, but WHY you did what you did. Why did you organize your program into three packages? Which class is running the event simulation loop? Why? Why is Gizmo an interface and not an abstract class? Or perhaps it is an abstract class an not an interface, but why?

What are the methods that need to be supported by the Gizmo interface? Why?

How do you do event handling? How do the user inputs from the GUI interact with the main event simulation loop? How do you ensure that there is no lag in the user response? Basically, if the user hits a key, the flipper must flip; if the flipper is slow, it may miss the ball.

The flipper is apparently difficult to get right. Explain the problems and how you solved them.

### Runtime Structure

Representations of data types should be EXPLAINED (along with their abstraction functions and rep. invariants) if those representations are unusual, particularly complex, or crucial to the overall design. Don't simply tell me WHAT you did, tell me WHY you did it. Convince me that you thought about alternatives and what you did is the best thing. At the same time, don't waste time cooking up worthless alternatives for some really simple ADTs for which there is only one obvious way to do it.

This is the test: when we read about how you did what you did and you don't offer alternatives, We will try to think of at least one feasible/reasonable one. If we fail, you win; if we succeed, you lose and we will take off points. :-)

### Module Structure

Your MDD should go here. Remember, your MDD is meant to convey information: you don't have list every single method for each dependency and you don't have to list every single class. Include all the major classes that you define. You can omit inner classes and Exceptions that you define that have very little impact on other classes.

If you organized your classes into packages, explain why you did it that way. You should keep in mind access control. If you end up having to make all your fields and methods public because of this, it may not be a good thing. Remember that having two classes in the same package allows you to use default access.

Explain what you did to decouple your design. What design patterns did you use? (Hint: the observer pattern is something that you will likely find useful) Why did you use that pattern(s)? Now, we must also emphasize that the point here is not to throw in every single pattern that you can think of to impress me; the idea is to use the appropriate patterns to help you in your design. Other patterns that are likely to be useful are Factory, Facade, and the Wrapper family of patterns (Adaptor, Decorator & Proxy).

## Testing

Testing should be done on all implemented features at every sprint cycle. The test strategy should include unit tests, integration tests, stress tests, performance tests and regression tests, where applicable.

Unit and integration tests should be automated using tools like XCodeTest using stubs as needed. Where testing would be infeasible such as lack of resource to do stress testing, it would be sufficient to describe the test strategy without actually running the test. This is to demonstrate that thought has been given to the test and could one day be implemented.

This section should describe the test strategy and give an overview on how to navigate the tests. Details of specific tests can be placed in the Appendix. If you have done some tests, you should include the details about the tests and the results.

## Reflection

### Evaluation

Tell me how you think you're doing so far. Are you able to meet your scheduled deadlines? Have you slipped? What did you do (or what do you plan to do) about the slippage?

If you don't think you're doing well, what went wrong? What are the problems that your group is currently facing? How do you plan to deal with these problems?

### Lessons

What have you learnt in the last two weeks? How are you going to apply that newfound knowledge to the rest of the project?

### Known Bugs and Limitations

Not required for prelim design, but if you have started implementation and found some bugs, you can list them here and explain how you plan to fix them.

## Appendix

### Test cases

You may list all detailed tests in the Appendix. If your testing strategy is complete and has good coverage, this list should be pretty long. If this is a short list, think harder.

### Detailed Schedule + Task List

List not only when things have to be done, but who is responsible for it.

### GUI sketches/screenshot

It is acceptable if you only have sketches at this point. If you have already implemented your GUI, you should capture relevant screenshots.

### Issues still unresolved

List any unresolved issues.

### Specifications

Attach specifications for your classes if you have already written the stubs.