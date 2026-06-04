# TpvSceneNode

A scene node can be an entity or even a component for an entity node. The scene graph pattern is a tree structure, where each node
can have zero or more child nodes, but only one parent node. The root node has no parent node. Each node can have zero or more data
objects, which can be used for any purpose, even as components for an entity node. Here, there is no distinction for simplicity.

This approach is different from the entity-component-system pattern, which is also implemented in the PasVulkan framework (see the 
PasVulkan.EntityComponentSystem.pas unit). You have the flexibility to choose whether to use the entity-component-system pattern, the 
scene graph pattern, or both, depending on your specific needs.

## Methods

- `Add`: Adds a node to the children of the current node.
- `Remove`: Removes a node from the children of the current node.
- `GetNodeListOf`: Returns a list of all child nodes of the specified node class. This can be used to retrieve all nodes of a certain
  type.
- `GetNodeOf`: Returns the child node of the specified node class at the specified index, which is zero by default, and nil if there
  is out of bounds. This can be used to retrieve a specific node of a certain type.
- `GetNodeCountOf`: Returns the count of child nodes of the specified node class. This can be used to count the number of nodes of a
  certain type.

## Loading Methods

These methods are used for loading of data, which can be done in parallel, like loading of textures, meshes, etc. They should be called
just once before the beginning of a level or game together with a loading screen. For other resources, which are loaded during the game,
like textures, meshes, etc. should be loaded in another way, for example, with the resource manager of the PasVulkan framework (see the
PasVulkan.Resources.pas unit). These loading functions here are just for to simplify the initial loading of a level or game without the 
actual mess of loading of resources during the game with a resource manager.

- `StartLoad`: Called before the background loading of the scene graph. It's called in the main thread. This is the first step in the
  loading process.
- `BackgroundLoad`: Called in a background thread and should be used for loading of data, which can be done in parallel. This is where
  the actual loading of data occurs.
- `FinishLoad`: Called after the background loading of the scene graph. It's called in the main thread. This is the final step in the
  loading process.
- `WaitForLoaded`: Waits until the scene graph or node is loaded. This can be used to pause the execution of the program until the
  loading is complete.
- `IsLoaded`: Returns true, if the scene graph or node is loaded. This can be used to check if the loading process is complete.

## Update and Render Methods

These methods are used for interpolation of the scene graph for the "Fix your timestep" pattern, which means, that the scene graph is
updated with a fixed timestep, but rendered with a variable timestep, which is interpolated between the last and the current scene graph
state for smooth rendering.

- `Store`: Stores the current state of the scene graph. This can be used to save the state of the scene graph for later use.
- `Update`: Updates the scene graph with a fixed timestep. This is used to update the state of the scene graph based on the elapsed time.
- `Interpolate`: Interpolates the scene graph with a variable timestep. This is used to smoothly transition between different states of
  the scene graph.
- `FrameUpdate`: Updates some stuff just frame-wise, like audio, etc. and is called in the main thread. This is used to update things
  that need to be updated every frame, like audio.

## Rendering and Audio Methods

- `Render`: Renders the scene graph. Can be called in the main or in a render thread, depending on the settings of the PasVulkan main
  loop. This is where the scene graph is drawn to the screen. Be careful with thread-safety.
- `UpdateAudio`: Updates audio and is called in the audio thread. Use it in combination with FrameUpdate, which is called in the main
  thread, with a thread safe data ring buffer or queue for audio data, which is filled in FrameUpdate and read in UpdateAudio. You can
  use the constructs from PasMP for that. Be careful with thread-safety.

# TpvScene

TpvScene is the main class that holds the root node of the scene graph. It provides methods for loading, updating, and rendering the
scene graph.

## Methods

- `StartLoad`: Initiates the loading process for the scene graph. This is the first step in the loading process.
- `BackgroundLoad`: Loads the scene graph in a background thread. This is where the actual loading of data occurs.
- `FinishLoad`: Completes the loading process for the scene graph. This is the final step in the loading process.
- `WaitForLoaded`: Waits until the scene graph is fully loaded. This can be used to pause the execution of the program until the loading
  is complete.
- `IsLoaded`: Checks if the scene graph is fully loaded. This can be used to check if the loading process is complete.
- `Store`: Stores the current state of the scene graph. This can be used to save the state of the scene graph for later use.
- `Update`: Updates the scene graph with a fixed timestep. This is used to update the state of the scene graph based on the elapsed time.
- `Interpolate`: Interpolates the scene graph with a variable timestep. This is used to smoothly transition between different states of
  the scene graph.
- `FrameUpdate`: Updates some stuff just frame-wise, like audio, etc. and is called in the main thread. This is used to update things
  that need to be updated every frame, like audio.
- `Render`: Renders the scene graph. Can be called in the main or in a render thread, depending on the settings of the PasVulkan main
  loop. This is where the scene graph is drawn to the screen. Be careful with thread-safety.
- `UpdateAudio`: Updates audio and is called in the audio thread. Use it in combination with FrameUpdate, which is called in the main
  thread, with a thread safe data ring buffer or queue for audio data, which is filled in FrameUpdate and read in UpdateAudio. You can
  use the constructs from PasMP for that. Be careful with thread-safety.

# Fix Your Timestep

"Fix Your Timestep" is a game loop pattern that decouples the game's rendering rate from the physics update rate. This is crucial for 
maintaining consistent physics in a game, regardless of the frame rate.

In a typical game loop, both the game's physics calculations and rendering are done in the same loop. This means that if the frame rate 
drops or varies, it can directly affect the physics calculations, leading to inconsistent game behavior.

The "Fix Your Timestep" pattern solves this problem by updating the game's physics at a fixed rate (for example, 60 times per second), 
independent of how fast the frames are being rendered. Between each physics update, the game state is interpolated to provide smooth 
rendering.

Here's a simplified breakdown of the pattern:

1. **Store:** The current game state is stored.
2. **Update:** The game state is updated with a fixed timestep.
3. **Interpolate:** The game state is interpolated between the last and current state, based on the render frame's point in time.
4. **Render:** The game is rendered using the interpolated state.

This pattern ensures that the game's physics behave consistently, regardless of the rendering performance.
