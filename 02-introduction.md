---
title: Introduction
author: Tim Mensinger
---

In this section we introduce the core concepts of the dynamic problem and the
corresponding notation.
If not otherwise stated, we use capital letters ($X_t$) to denote random variables, and
lowercase letters ($x_t$) to denote their deterministic counterparts.
The examples in this section roughly follow {cite}`Iskhakov2017`.

## The State and Action Spaces

The **state space** $\mathbb{X}_t$ describes the set of all potential state combinations
in period $t$.
The state space can contain both discrete and continuous variables.

```{admonition} Example
An example of a discrete state variable is whether the agent is *employed* or not,
modelled as a binary variable that is 1 if the agent is employed and 0 otherwise. For
continuous state variables an example is the agent's *wealth*, for which the interval
$[5, 10]$ covers all relevant data points. The state space is then simply the Cartesian
product of the two spaces, i.e. $\mathbb{X} = \{0, 1\} \times [5, 10]$.
```

Similarly, the **action space** $\mathbb{A}_t$ describes the set of all potential action
combinations in period $t$. An action $a_t \in \mathbb{A}_t$ can be any combination of
discrete and continuous variables.
We denote **continuous actions** by $c_t \in \mathbb{A}_t^c$ and **discrete actions** by
$d_t \in \mathbb{A}_t^d$, such that
$$a_t = (d_t, c_t) \in \mathbb{A}_t^d \times \mathbb{A}_t^c = \mathbb{A}_t.$$

```{admonition} Example
A discrete action (or choice variable) is the *retirement* decision, modelled as a binary variable that is 1 if the agent retires and 0 otherwise. A continuous action variable is the agent's *savings* decision, modelled, for example, as a real variable that lives in the interval $[0, 10]$. The action space is then given by $\mathbb{A} = \{0, 1\} \times [0, 10]$.
```

The **state-action space** describes all possible combinations of states and actions. In period $t$, we have $(x_t, a_t) \in \mathbb{X}_t \times \mathbb{A}_t$.

<!--
TODO: Think about this paragraph. Currently it is not correct since we do interpolate.

```{important}
In the current implementation of LCM, there is no one-to-one mapping between the space of continuous state or action variables and what we work with on the computer. For continuous variables we discretize the space. For example, with a discretization step of 0.1, we would store the interval $[5, 10]$ as the set of values $\{5, 5.1, ..., 9.9, 10\}$.
```
-->

:::{warning}
**Not implemented in LCM yet.**

While $\mathbb{X}_t$ is a very concise general notation, for practical applications and memory efficiency, it is often useful to divide it into $\mathbb{X}_t = \mathbb{X}_t^{\text{xm}} \times \mathbb{X}_t^{\text{xc}}$, where $\text{xm}$ stands for state-modifying and $\text{xc}$ for state-constant variables.

That is, $\text{xm}$ collects those state variables that lead to a completely different state-choice space in terms of the remaining state-constant state variables.

A prime example for $\text{xm}$ variables would be the vital status: If an agent dies between periods $t$ and $t+1$, all that matters for the continuation value is her wealth should utility from bequests be modelled as in {cite}`DeNardi2004`, all other state variables are irrelevant.

Another example would be marital status when household maximize joint utility (e.g., {cite}`Borella2022`). The state-space conditional on being married is much larger than conditional on being single.
:::

## Constraints

Restrictions on the action space can be modelled using **constraints**. Formally, constraints are functions that map state-action pairs and the current period into a Boolean value 

$$\mathcal{C}_t : \mathbb{X}_t \times \mathbb{A}_t \to \{\text{True}, \text{False}\}.$$

A value of "True" indicates that the constraint is satisfied, and "False" indicates that it is violated; that is, a feasible action is one that satisfies the constraint.

Constraints can be parametrized by a real vector $\theta_\mathcal{C}$, so that $\mathcal{C}_{t}(x_t, a_t) = \mathcal{C}_{t}(x_t, a_t | \theta_\mathcal{C})$. For constraints that act upon the discrete and continuous actions separately, we write

$$
\begin{align}
\mathcal{C}_{t}^{c} &: \mathbb{X}_t \times \mathbb{A}_t^c \to \{\text{True}, \text{False}\}, \\
\mathcal{C}_{t}^{d} &: \mathbb{X}_t \times \mathbb{A}_t^d \to \{\text{True}, \text{False}\}.
\end{align}
$$

The feasible action spaces of the agent in period $t$, when facing state $X_t = x_t$, are given by

$$
\begin{align}
\Gamma_{t}(x_t) &= \{a_t \in \mathbb{A} | \mathcal{C}_{t}(x_t, a_t) \text{ is True}\}, \\
\Gamma_{t}^{c}(x_t) &= \{c_t \in \mathbb{A}^c | \mathcal{C}_{t}^{c}(x_t, c_t) \text{ is True}\}, \\
\Gamma_{t}^{d}(x_t) &= \{d_t \in \mathbb{A}^d | \mathcal{C}_{t}^{d}(x_t, d_t) \text{ is True}\}.
\end{align}
$$


:::{admonition} Example
As an example consider a *borrowing constraint*, which restricts the agent's consumption to be bounded from above by her *wealth*. Assume there is only one state variable $x_t$ that represents the agent's wealth, and only one action variable $a_t$ that represents the agent's consumption. The constraint then takes the form $\mathcal{C}_{t}(x_t, a_t) = [a_t \leq x_t]$. A version that depends on model parameters could allow for some borrowing, i.e. consuming more than your current wealth: $\mathcal{C}_{t}(x_t, a_t | \theta_\mathcal{C}) = [a_t \leq x_t + \theta_\mathcal{C}]$.
:::

:::{warning}
**Not implemented in LCM yet.**

Some types of constraints allow us to reduce the state-action space.
For example, forced retirement after a certain age means that labor supply is fixed
after that age.
:::

## Utility Function

The **instantaneous utility function** $u_t$ maps the current state and action into a
real-valued *utility*, i.e.

$$u_t : \mathbb{X}_t \times \mathbb{A}_t \to \mathbb{R}.$$

Using the notation from the introduction, we have $R_t = u_{t}(X_t, A_t)$.

:::{note}
LCM works with utility functions, which are **parametrized** by some parameter
$\theta_u$.
While we suppress this dependence in the following, it is important to keep in mind that
there is a finite-dimensional parameter governing the functional form of the utility
function $u_{t}(X_t, A_t) = u_{t}(X_t, A_t | \theta_u)$.
:::

:::{warning}
Currently, LCM supports only deterministic utility functions. We plan to add support for
certain additive utility shocks (*taste shocks*) in the future.
:::

## State Transition

In the dynamic models under consideration, the state $X_t$ evolves conditional on past information $\{X_{t-1}, A_{t-1}, \dots, X_0, A_0\}$. We assume that the process satisfies the **Markov property**, i.e. the future state $X_{t+1}$ only depends on the current state $X_t$ and the action $A_t$.

This is modelled using the Markov **transition kernel** $P_t$, which describes the distribution of the next state, conditional on the current state and action, i.e.[^2]

$$X_{t+1} \sim P_{t+1}(X_t, A_t).$$

[^2]: In the literature this is called a *controlled* Markov process, as the transition kernel depends on the action taken by the agent.

If the state transition is *deterministic*, we write $X_{t+1} = P_{t+1}(X_t, A_t)$. We will also sometimes write $P_{t+1}(\cdot | X_t, A_t)$ for the cumulative distribution function of the next state given the current state and action. This allows us to write, for example, the expected value of a function $f : \mathbb{X}_{t+1} \to \mathbb{R}$, defined on tomorrow's state space, as

$$\mathbb{E}[f(X_{t+1}) | X_t, A_t] = \int_{\mathbb{X}_{t+1}} f(x_{t+1}) \, dP_{t+1}(x_{t+1} | X_t, A_t).$$

:::{note}
The transition kernel is allowed to depend on a time-dependent parameter $\theta_{P,t}$, so that explicitly, we have $P_{t+1}(X_t, A_t) = P_{t+1}(X_t, A_t | \theta_{P,t})$.
:::

```{warning}
Currently, LCM supports stochastic state transitions only for discrete state variables.
```

## Policy Function

In order to maximize lifetime utility (see e.g., {eq}`eq-lifetime-utility`), the agent needs to take decisions $(A_1, \dots, A_T)$. Given the temporal structure of the dynamic problem outlined in the preface, the agent is aware of the current state $X_t$ when taking the action $A_t$.

A *policy function* $\pi_t$ maps the state in period $t$ to the action that is taken in that period, i.e. $\pi_t : \mathbb{X}_t \to \mathbb{A}_t.$ Using this, we can thus write the agent's action as $A_t = \pi_{t}(X_t)$.