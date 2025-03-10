---
title: Dynamic Programming Problem
author: Tim Mensinger
---

In this section, we introduce the dynamic programming problem in the context of
discrete-time and finite-horizon models. The section concludes with the derivation of
the Bellman equation for the value function and equivalent versions thereof, which helps
us draw the connection between the mathematical problem and the LCM codebase. As a
reference, consider {cite}`Rust2018`.

## Sequence Problem

Using the notation from the previous section, we can formalize
{eq}`eq-lifetime-utility`. We assume that the agent aims to solve the following problem:

:::{math}
---
label: eq-sequence-problem
---

\begin{align}
\max_{\pi_s, \dots, \pi_T} \mathbb{E}\left[ \sum_{t=s}^T \beta^{t-s} u_{t}(X_t, A_t) | X_s = x_s\right] \\
\text{such that } X_{t+1} \sim P_{t+1}(X_t, A_t) \text{ and } A_t \in \Gamma_{t}(X_t),
\end{align}

:::

with $x_0$ denoting a deterministic initial state, and $A_t = \pi_{t}(X_t)$.

In the following, we will always assume that $X_{t+1} \sim P_{t+1}(X_t, A_t)$ and only
mention it when necessary.

:::{important}

As stated in the introduction, this baseline objective is only one of
many possible objectives that LCM can handle. {eq}`eq-sequence-problem` can be solved
out-of-the-box with LCM. Other objectives require the user to implement the concrete
solution method themselves.

:::

## Optimal Policy and Action

We write $\{\pi^*_{1}, \dots, \pi^*_{T}\}$ to denote the **optimal policy**, that is,
the solution to {eq}`eq-sequence-problem`. Correspondingly, we write
$A^*_t = \pi^*_{t}(X_t)$ or $a^*_t = \pi^*_{t}(x_t)$ for the optimal action.

## Value Function

The **value function** in period $t$ is defined as the expected lifetime utility, given
the agent finds itself in state $X_t = x_t$ and follows the optimal policy thereafter:

$$
\begin{align}
V_{t}(x_t) \\
&= \mathbb{E}_{X_{r+1} \sim P_{r+1}(X_r, A_r^*)}\left[ \sum_{r=t}^T \beta^{r-t} u_{r}(X_r, A_r^*) | x_t\right] \\
&= u_{t}(x_t, a_t^*) + \mathbb{E}_{X_{r+1} \sim P_{r+1}(X_r, A_r^*)}\left[ \sum_{r=t+1}^T \beta^{r-t} u_{r}(X_r, A_r^*)  | x_t\right] \\
&= u_{t}(x_t, a_t^*) + \beta \cdot \mathbb{E}_{X_{r+1} \sim P_{r+1}(X_r, A_r^*)}\left[ \sum_{r=t+1}^T \beta^{r-t-1} u_{r}(X_r, A_r^*)  | x_t\right] \\
&= u_{t}(x_t, a_t^*) + \beta \cdot \mathbb{E}_{X_{t+1}} \left[\mathbb{E}_{X_{r+1} \sim P_{r+1}(X_r, A_r^*)}\left[ \sum_{r=t+1}^T \beta^{r-t-1} u_{r}(X_r, A_r^*)  | X_{t+1}, x_t\right]\right] \\
&= u_{t}(x_t, a_t^*) + \beta \cdot \mathbb{E}_{X_{t+1}}\left[ V_{t+1}(X_{t+1})\right] \\
&= u_{t}(x_t, a_t^*) + \beta \cdot \int_{\mathbb{X}_{t+1}} V_{t+1}(x_{t+1}) \, dP_{t+1}(x_{t+1} | x_t, a_t^*).
\end{align}
$$

LCM currently assumes that all value functions beyond the last period are zero. Using
this, the last period value function simplifies to $V_{T}(X_T) = u_{T}(X_T, A_T^*)$.

## Recursive Problem

In the previous subsection, we have derived the **Bellman equation** for the value
function from the *sequence problem* {eq}`eq-sequence-problem`. The Bellman equation is
given by

:::{math}
---
label: eq-bellman
---

\begin{align}
V_{t}(x_t)
&= &&u_{t}(x_t, a_t^*) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t^*)}\left[ V_{t+1}(X_{t+1})\right] \\
&= \max_{a_t \in \Gamma_{t}(x_t)} \{&&u_{t}(x_t, a_t) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t)}\left[ V_{t+1}(X_{t+1})\right]\}
\end{align}

:::

Because the problem has a finite-horizon, the last period $t=T$ is a boundary condition
that can be solved directly:

:::{math}
---
label: eq-bellman-boundary
---

V_{T}(x_T) = \max_{a_T \in \Gamma_{T}(x_T)} u_{T}(x_T, a_T).

:::

This allows us to solve for the other value functions using backward induction.

Given the value functions $(V_1, \dots, V_T)$, we can solve for the optimal policy

:::{math}
---
label: eq-bellman-policy
---

\pi^*_{t}(x_t)
    = a_t^*
    = \argmax_{a_t \in \Gamma_{t}(x_t)} \{u_{t}(x_t, a_t) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t)}\left[ V_{t+1}(X_{t+1})\right]\},

:::

and for the last period

:::{math}
---
label: eq-bellman-boundary-policy
---

\pi^*_{T}(x_T) = a_T^* = \argmax_{a_T \in \Gamma_{T}(x_T)} u_{T}(x_T, a_T).

:::

## Additional Definitions

In this section, we introduce some additional definitions that are useful to understand
LCM internals.

The **continuation value** is the expected value from the next period onwards, given
that the agent is today in state $x_t$ and takes action $a_t$, and assuming that the
agent follows the optimal policy thereafter:

$$
F_{t}(x_t, a_t)
    = \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t)}\left[ V_{t+1}(X_{t+1})\right].
$$

The **action-value function** $Q_t : \mathbb{X}_t \times \mathbb{A}_t \to \mathbb{R}$
assigns a value to each state-action pair $(x_t, a_t)$ considering the instantaneous
utility and the continuation value conditional on this state and action:

$$
\begin{align}
Q_{t}(x_t, a_t)
    &= u_{t}(x_t, a_t) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t)}\left[ V_{t+1}(X_{t+1})\right] \\
    &= u_{t}(x_t, a_t) + \beta \cdot F_{t}(x_t, a_t).
\end{align}
$$

It is related to the value function by

$$V_{t}(x_t) = \max_{a_t \in \Gamma_{t}(x_t)} Q_{t}(x_t, a_t).$$

The **conditional-continuous-action-value function**
$Q_{t}^{c}: \mathbb{X}_t \times \mathbb{A}_t^{d} \to \mathbb{R}$ maps a state and a
discrete action to the maximum of the action-value function over the continuous actions:

$$Q_{t}^{c}(x_t, d_t) = \max_{c_t \in \Gamma_{t}^{c}(x_t)} Q_{t}(x_t, (d_t, c_t)).$$

It is related to the value function by

$$V_{t}(x_t) = \max_{d_t \in \Gamma_{t}^{d}(x_t)} Q_{t}^{c}(x_t, d_t).$$

Similary, we can also define the **conditional-continuous-policy function**
$\pi_{t}^{c}: \mathbb{X}_t \times \mathbb{A}_t^{d} \to \mathbb{A}_t^{c}$ as the optimal
continuous action given a state and a discrete action:

$$
\pi_{t}^{c}(x_t, d_t) = \argmax_{c_t \in \Gamma_{t}^{c}(x_t)} Q_{t}(x_t, (d_t, c_t)).
$$

It is related to the optimal policy by

$$
\pi^*_{t}(x_t)
    = \argmax_{d_t \in \Gamma_{t}^{d}(x_t)} Q_{t}(x_t, (d_t, \pi_{t}^{c}(x_t, d_t))).
$$

## Maximization

In {eq}`eq-bellman` to {eq}`eq-bellman-boundary-policy` we are maximizing over the joint
action space of discrete and continuous actions. From a computational perspective, it is
easier to think of this problem as first finding the maximum over the continuous action
{u}`conditional` on the discrete actions, and then finding the discrete action that
achieves the overall maximum.

We can rewrite the Bellman equation {eq}`eq-bellman` as

$$
\begin{align}
V_{t}(x_t)
&= &&u_{t}(x_t, a_t^*) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t^*)}\left[ V_{t+1}(X_{t+1})\right] \\
&= \max_{a_t \in \Gamma_{t}(x_t)} \{&&u_{t}(x_t, a_t) + \beta \cdot \mathbb{E}_{X_{t+1} \sim P_{t+1}(x_t, a_t)}\left[ V_{t+1}(X_{t+1})\right]\} \\
& = \max_{a_t \in \Gamma_{t}(x_t)} \{&&u_{t}(x_t, a_t) + \beta \cdot F_{t}(x_t, a_t)\} \\
& = \max_{a_t \in \Gamma_{t}(x_t)} &&Q_{t}(x_t, a_t) \\
& = \max_{d_t \in \Gamma_{t}^{d}(x_t)} &&\max_{c_t \in \Gamma_{t}^{c}(x_t)} Q_{t}(x_t, c_t, d_t) \\
& = \max_{d_t \in \Gamma_{t}^{d}(x_t)} &&Q_{t}^{c}(x_t, d_t).
\end{align}
$$

This restatement is important to understand the LCM codebase, as we make heavy use of
it.
