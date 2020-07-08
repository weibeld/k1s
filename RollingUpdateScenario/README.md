
# Rolling Update Scenario

Building upon the Rolling Update Scenario already present in k1s, this folder contains a couple of scripts to facilitate running a nice Rolling Update demo.

Ideally run the scripts using a tmux multi-pane layout as shown below.
Alternatively separate windows could be used for each pane.

## Demo scenario scripts

This is composed of 2 scripts
- ./rollout_demo.sh: Runs through a scenario showing/pausing (most) commands before running them
  - an initial deployment
  - scale up
  - rolling upgrade to v2
    - rollout status
    - rollout history
  - rolling upgrade to v3
    - rollout status
    - rollout history
  - rollout undo
- ./rollout_demo_curl.sh: Loops
  - determining the Service IP address
  - Making a curl request to the Service

The default image repo has tags 1, 2, 3 which report container hostname, image name:tag, requesting IP
where the image "name:tag" text changes colour dependent upon the image.

Thus the effect of a rolling update is clearly seen.

See below for thoughts about possible variations.

## Suggested Window/Pane layout

```txt
+--------------------------------------------------------------------------------+
| $ ./rollout_demo.sh                                                            |
|                                                                                |
|                                                                                |
|                                                                                |
+--------------------------------------------------------------------------------+
| $ ./rollout_demo_curl.sh                                                       |
|                                                                                |
|                                                                                |
|                                                                                |
+--------------------------+--------------------------+--------------------------+
| $ ./k1s "" deploy        | $ ./k1s "" rs            | $ ./k1s "" pod           |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
|                          |                          |                          |
+--------------------------+--------------------------+--------------------------+
```

## Possible Variations:

- Vary Rolling upgrade parameters (MaxSurge/MaxUnavailable)
- Different Upgrade Strategies
  - Recreate
  - "*Traffic Shift*" - requires 1 ReplicaSet per version, modify Service label selector to point to "new" or "old" ReplicaSet
- Implement HealthChecks to prevent occasional "connection refused"
  - Useful to demonstrate with/without healthchecks

