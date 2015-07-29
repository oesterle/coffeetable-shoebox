CoffeeTable code sample
=======================

This is a pretty good representation of my iOS coding style.

It's a focused sample from CoffeeTable, a large, independently-developed project.

CoffeeTable enables users to collaboratively create photo collages, sharing across multiple nearby devices (iPhone, iPad, & iPod touch). It's specifically designed to work without any network infrastructure. It's built for group media sharing, and works well in environments where Wi-Fi or cell data are unavailable, limited, restricted by network policies, or expensive (i.e., when traveling abroad).

![CoffeeTable screenshots](/docs/ct_both_med.png?raw=true "CoffeeTable screenshots")


Bluetooth media transfer: under the hood
----------------------------------------

CoffeeTable creates a PAN based on locally discoverable Bluetooth iOS devices, and automatically establishes sharing roles for participating users. If users have Wi-Fi active, it will prefer connecting and sharing using Apple's implementation of Wi-Fi Direct. Otherwise, it falls back gracefully to Bluetooth. CoffeeTable rescales and compresses images for optimal performance across the PAN.

Apple's implementations of Bluetooth peer-to-peer communication (the **Multipeer Connectivity framework,** and its previous incarnation, **GameKit**) are quite brittle. So, CoffeeTable adds reliable connectivity layers over Apple's nearby-peer foundation, providing seamless automatic discovery, connection establishment, monitoring, and graceful recovery.

UX Design Goals
---------------

The key UX goal in peer-to-peer sharing was to enable a group of nearby users to connect as simply and instantly as possible. Some minimal onboarding helps first-time users be successful – CoffeeTable gently guides the user to share their first photo, and turn on Bluetooth, if necessary. It rewards them with both visual progress and sonic feedback around connection and media transfer.


The *Shoebox, Stack,* and *Pic* classes
-----------------------------------------

The code I'm sharing here focuses on the less arcane tasks of creating, managing, and persisting photo collections.

The `Shoebox` object manages `Stacks` of `Pics`.

A `Stack` is a collage that contains images, and their layout.

Users can add a `Pic` to the current `Stack`, and freely move, rotate, and resize the `Pic` using easily discoverable pinch and drag gestures. I built CoffeeTable UX on low-level raw touches for better performance, instead of high-level gestures, and so that CoffeeTable doesn't lock users into single-gesture modes of scale, rotate, or translate.

The `Shoebox` is serialized to a `plist`, and similarly, on opening the app, reconstituted to a hierarchical `NSMutableDictionary`.

Dual Project Targets
--------------------

CoffeeTable targets both iPhone/iPod touch devices, and larger iPads, where collages are built.

The `Shoebox` and `Stack` code specifically targets the iPad.
`Pic` code is shared between both targets.
