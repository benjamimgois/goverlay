## Kraft Physics Engine

Kraft Physics Engine is an open source Object Pascal physics engine library that can be used in 3D games.

Author : Benjamin 'BeRo' Rosseaux

Compatible with: Delphi 7-XE7 (but not with the Android and iOS targets), FreePascal >= 2.6.2 (with almost all FPC-supported targets including Android and iOS) 

## Support me

[Support me at Patreon](https://www.patreon.com/bero)

## Features

Kraft Physics Engine has the following features:

- Rigid body dynamics
- Discrete collision detection
- Optional additional continuous collision detection with Motion Clamping or with Box2D-style time of impact sub stepping, either with Bilateral Advancement or Conservative Advancement.  
- Optional additional support for speculative contacts as faster and more inaccurate fake continuous collision detection mode.
- Full one-shot contact manifold collision shapes (spheres, capsules, convex hulls, boxes, and for static geometries also triangle meshes) based on combinations of for-warm-start-simplex-caching-able GJK, Gauss-Map optimized Clipping-SAT and implicit collision algorithms.
- Optional MPR-based (Minkowski Portal Refinement) incremental persistent contact manifold work mode (see TKraft.PersistentContactManifold boolean), but its usage isn't recommended, because the full one-shot contact manifold work mode is faster, more robust and more tested. It is implemented only as comparison reference (for example for debugging purposes), and for more reasons against incremental persistent contact manifold real usage, see http://media.steampowered.com/apps/valve/2015/DirkGregorius_Contacts.pdf .
- Multiple collision shapes per rigid body without the need for a compound shape
- Broadphase collision detection with a dynamic AABB tree
- Fast mid phase for static triangle mesh geometries
- The choice of either Box2D-style post position correction/projection or alternately baumgarte stabilization
  - Post position correction/projection is slower but it's more precise, so it's also the default enabled setting
  - Baumgarte stabilization (which is also the old-school way) is faster but it can be inaccurate in some situations
- Narrowphase collision detection
- Collision response and friction (Sequential impulses with post projection)
- Joint constraints (Grab, Distance, Rope, Ball Socket, Hinge, Slider, Fixed)
- Collision filtering with groups
- Ray casting and sphere casting (ray "with" spherical thickness)
- Sleeping of inactive rigid bodies
- Island-based multithreading
- It can be used also for 1D and 2D physics, and not only for 3D physics
- SIMD optimizations for x86-32 and x86-64

## Future possibly possible features

- Linear casting
- More joint constraint types (for example cone twist, universal and/or general 6DOF)
- Cloths / Soft body

## License

The Kraft Physics Engine is released under the open-source [ZLib license](http://opensource.org/licenses/zlib).

## PasMP

For to use Kraft with PasMP, you must set a project global define called KraftPasMP (or use -dKraftPasMP as compiler command line parameter)

## Documentation

Later . . .

## Branches

The "master" branch contains the development state of the physics engine, which is frequently updated and can be quite unstable. The "release" branch contain the last stable released version and some possible bug fixes, which is then the most stable version. 

## Issues

If you find any issue with the library, you can report it on the issue tracker [here](https://github.com/BeRo1985/kraft/issues).
