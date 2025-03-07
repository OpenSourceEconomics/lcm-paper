---
title: Preface
author: Tim Mensinger
---


Before diving too deep into the details, let us consider what problems LCM tries to
solve.
This section is heavily influenced by {cite}`Sargent2024`.

Consider the temporal structure of the agents' finite-horizon dynamic programming
problem:

:::{prf:algorithm}
for $t = 0, 1, 2, ..., T$:

1. the agent observes the current **state** $X_t$
2. the agent chooses an **action** $A_t$
3. the agent receives a **utility** $\,\mathcal{U}_t$
4. the state updates to $X_{t+1}$

:::

The state $X_t$ is a vector containing the current realization of observable variables
deemed relevant to choosing the current action.
The action $A_t$ is a vector denoting choices of a set of decision variables.
Here, we only consider the **finite-horizon** case, that is, when $T < \infty$.

The **lifetime utility** aggregates the individual period utilitys $(\mathcal{U}_t)_{t \geq 0}$ into a
single value.
The agents' objective is to maximize their expected lifetime utility, while being
confronted with a dynamical system that maps today's state and the chosen action into
tomorrow's state.

The prime example of a lifetime utility is the discounted sum of period utilitys, leading
to the following objective:

```{math}
:label: eq-lifetime-utility
\mathbb{E}\left[ \sum_{t=s}^T \beta^{t-s} \mathcal{U}_t | X_s\right]
```

for some $s \in \mathbb{N}$ and a discount factor $\beta \in [0, 1)$, though typically
$\beta < 1$.

In the following, we will use this baseline objective {eq}`eq-lifetime-utility` to
illustrate the concepts.
However, note that this objective already uses many implicit assumptions.
For example, we assume that the agent cares about expectations (and is able to correctly
compute them), that the lifetime utility is *time-separable*, or that the agent is
*time-consistent*.

```{note}
LCM allows user to implement custom versions of lifetime utility. Out-of-the-box,
maximization of {eq}`eq-lifetime-utility` is supported.
```
