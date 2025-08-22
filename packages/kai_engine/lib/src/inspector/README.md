# Kai Inspector: Architecture Overview

This document outlines the architecture of the Kai Inspector, a system designed to provide deep insight into the execution of the `kai_engine`.

The goal of this system is to go beyond simple debugging. It is a comprehensive tool for:
- **Understanding:** Seeing the exact data (like prompts) that flows through the engine.
- **Optimizing:** Tracking performance and costs (like token usage) for analysis.
- **Experimenting:** Providing the foundation for tools (like a "Playground") that can re-run parts of the engine's process with modified inputs.

---

## Core Architecture

The Inspector system is split into two packages to maintain a clean separation of concerns and keep the core engine lean.

1.  **`kai_engine` (This Package):**
    -   Contains the core, platform-agnostic chat engine.
    -   Defines the **abstractions** (interfaces and data models) for the Inspector system.
    -   It knows *that* it can be inspected, but contains no UI or concrete implementation details.

2.  **`kai_inspector` (External Package):**
    -   An optional Flutter package that developers add to their `dev_dependencies`.
    -   Provides the default, in-memory **implementation** of the Inspector service.
    -   Contains pre-built Flutter widgets for displaying the Inspector UI.

---

## Key Components

These are the main classes that make up the Inspector's abstraction layer within `kai_engine`.

### `KaiInspector` (Abstract Class)
-   **Role:** The central Service Contract. This is the main "plug-in point" for the entire inspection system.
-   **Flow:** The `ChatController` will interact with this abstract class, decoupling the engine from any specific inspector implementation. A developer can provide their own implementation (e.g., for custom storage) or use the default one provided in the `kai_inspector` package.

### `KaiPhase<Input, Output>` (Abstract Class)
-   **Role:** The base class for all major, "inspectable" operations in the engine, such as `QueryEngineBase` or `GenerationServiceBase`.
-   **Flow:** A core engine component (e.g., `GenerationServiceBase`) will extend this class. This provides two benefits:
    1.  It standardizes the operation under a single `execute(Input)` method.
    2.  It seamlessly provides developer-facing helper methods (`withStep`, `addLog`) that they can use. These helpers get the context they need from the private `PhaseController`.

### `PhaseController` (Internal Class)
-   **Role:** An internal, short-lived context carrier object.
-   **Flow:** This class is not intended for public use. The `ChatController` creates an instance of this class before it runs a `KaiPhase`. It bundles together a reference to the main `KaiInspector` service and the IDs for the current session and timeline. It is then passed to an internal `run` method on the `KaiPhase`, giving the phase's helper methods the context they need to record data to the correct place.

### The Data Model Hierarchy

These are the immutable data structures that form the recorded log.

-   **`TimelineSession`**: The main container for an entire conversation. It contains a list of `ExecutionTimeline`s.
-   **`ExecutionTimeline`**: Represents the complete lifecycle of a single message submission. It contains a list of `TimelinePhase`s.
-   **`TimelinePhase`**: Represents a major stage corresponding to a `KaiPhase` execution (e.g., "AI Generation"). It contains a list of `TimelineStep`s.
-   **`TimelineStep`**: Represents a granular, timed operation within a phase. It is created by the `withStep()` helper and contains detailed metadata and logs.

---

## End-to-End Workflow

This is how all the pieces work together when a user sends a message.

1.  **Injection:** The developer initializes a `DefaultKaiInspector` (from the `kai_inspector` package) and injects it into the `ChatController`'s constructor.

2.  **Execution Starts:** The `chatController.submit()` method is called.

3.  **Context is Created:** The `ChatController` tells the `KaiInspector` service to ensure a session is active. It then prepares to run the first `KaiPhase` (e.g., the `QueryEngine`). It creates a `PhaseController` instance, bundling it with the `inspector` service reference and the current session/timeline IDs.

4.  **A Phase Runs:** The `ChatController` calls an internal `run(input, phaseController)` method on the `_queryEngine` instance. The `KaiPhase` base class saves the controller and then calls the `execute(input)` method that the developer implemented.

5.  **Steps are Tracked:** Inside `execute()`, the developer's code uses the `withStep` helper:
    ```dart
    await withStep('Fetch RAG documents', (step) async {
      step.addLog('Found 3 documents.');
    });
    ```

6.  **Data is Recorded:** The `withStep` and `step.addLog` methods use the saved `PhaseController` to get the main `inspector` instance and all the necessary IDs. They call the appropriate recording methods on the inspector service.

7.  **UI is Notified:** The `KaiInspector` service receives this new data, updates its internal state (e.g., adds the `TimelineStep` to the current `TimelinePhase`), and broadcasts the new, updated `TimelineSession` object on its public `Stream`.

8.  **UI Reacts:** The `KaiInspectorScreen` widget, which is listening to the stream, receives the new `TimelineSession` object and rebuilds its UI to display the new step or log in near real-time.
