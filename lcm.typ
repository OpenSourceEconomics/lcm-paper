#import "@preview/algo:0.3.3": algo, i
#import "@preview/note-me:0.2.1": note, important, warning, todo, admonition

// #set
// =====================================================================================
#set par(justify: true)
#set quote(block: true)
#set text(
  size: 12pt,
  font: "Bitstream Charter",
)
#set raw(lang: "python")
#set heading(numbering: "1.")

// #let
// =====================================================================================
#let uni_bonn_blue_hex_code = "#07529a"
#let uni_bonn_blue = color.rgb(uni_bonn_blue_hex_code)

#let lcm = text(uni_bonn_blue)[`LCM`]
#let statespace = $bb(X)$
#let actionspace = $bb(A)$
#let constraints = $cal(C)$
#let FeasibleActionSpace = $Gamma$
#let argmax = $op("argmax", limits: #true)$

#let citet(reference) = {
  set text(uni_bonn_blue)
  cite(reference, form: "prose")
}
#let cites(reference) = {
  show cite: underline
  cite(reference, form: "prose")
}
#let citep(reference) = {
  cite(reference, form: "normal")
}

#let italic(body) = text(body, style: "italic")

#let small_block_quote(attribution, content) = {
  set text(size: 9pt)
  quote(block: true, quotes: true, attribution: attribution, content)
}

#let numbered_eq(content) = math.equation(
    block: true,
    numbering: "(1)",
    content,
)
#let eq(content) = math.equation(
    block: true,
    content,
)

#let example(content) = {
  admonition(
    icon: "icons/info.svg",
    color: color.olive,
    title: "Example",
    foreground-color: color.black,
    background-color: color.white,
    content,
  )
}

// #show
// =====================================================================================
#show link: underline
#show ref: set text(fill: color.rgb("#990000"))
#show heading: it => {
  it.body
  v(1em)
}
#show emph: it => {
  text(uni_bonn_blue, it.body, weight: "semibold")
}


// =====================================================================================
// Title
// =====================================================================================

#align(center)[
  #text(size: 16pt, weight: "semibold")[
    #text(size: 18pt)[#lcm: Mathematical Background]
    ] \
  #line(length: 85%)
  #text(size: 12pt)[Tim Mensinger] \
  Version: #datetime.today().display()
]

// Abstract / Intent
// =====================================================================================
#v(2em)

#align(center)[
  *Abstract & Intent* \
  #v(0.1em)
  #box(
    width: 85%,
    text[
      #align(left)[
      These notes aim to showcase the explicit mathematical problem that #lcm solves,
      and tries to connect the mathematical concepts to the codebase. We introduce the
      basic concepts of dynamic programming and then derive the Bellman equation for the
      value functions. #lcm can be used to solve for these value functions numerically
      (#italic[model solution]) or to find the optimal policy given such a model
      solution (#italic[model simulation]). These notes are intended to be a reference
      for developers working on the #lcm codebase, and for users who want to improve
      their understanding of the connection between the mathematical model and #lcm.
      ]
    ]
  )
]

// Outline
// =====================================================================================

#outline(indent: 4%, depth: 2)
#pagebreak()


// =====================================================================================
// Main text
// =====================================================================================


// Introduction
// =====================================================================================

= Preface

Before diving too deep into the details, let us consider what problems #lcm tries to
solve. This section is heavily influenced by #citet(<Sargent2024>).

Consider the temporal structure of the agents' finite-horizon dynamic programming
problem:

#algo[
  for $t = 0, 1, 2, dots, T$:#i\
    the agent observes the current _state_ $X_t$\
    the agent chooses an _action_ $A_t$\
    the agent receives a _reward_ $R_t$\
    the state updates to $X_(t+1)$\
]

The state $X_t$ is a vector containing the current realization of observable variables
deemed relevant to choosing the current action. The action $A_t$ is a vector denoting
choices of a set of decision variables. Here, we only consider the _finite-horizon_
case, that is, when $T < infinity$.

The _lifetime reward_ aggregates the individual period rewards $(R_t)_(t gt.eq.slant 0)$
into a single value.
The agents' objective is to maximize their expected lifetime reward, while being
confronted with a dynamical system that maps today's state and the chosen action into
tomorrow's state. 

The prime example of a lifetime reward is the discounted sum of period rewards, leading
to the following objective:  

#numbered_eq($
  bb(E)[ sum_(t=s)^T beta^(t-s) R_t | X_s],
$) <eq-lifetime-reward>

for some $s in bb(N)$ and a discount factor $beta in [0, 1)$, though
typically $beta < 1$.

In the following, we will use this baseline objective (@eq-lifetime-reward) to
illustrate the concepts. However, note that this objective already uses many implicit
assumptions. For example, we assume that the agent cares about expectations (and is able
to correctly compute them), that the lifetime reward is #italic[time-separable], or that
the agent is #italic[time-consistent].

#note[
#lcm allows user to implement custom versions of lifetime reward. Out-of-the-box,
maximization of @eq-lifetime-reward is supported.
]

// Notation
// =====================================================================================
#pagebreak()

= Introduction

In this section we introduce the core concepts of the dynamic problem and the
corresponding notation. If not otherwise stated, we use capital letters ($X_t$) to
denote random variables, and lowercase letters ($x_t$) to denote their deterministic
counterparts. The examples in this section roughly follow #citet(<Iskhakov2017>).

== The State and Action Spaces

The _state space _ $statespace_t$ describes the set of all potential state combinations
in period $t$. The state space can contain both discrete and continuous variables.

#example[
  An example of a discrete state variable is whether the agent is #italic[employed] or not,
  modelled as a binary variable that is 1 if the agent is employed and 0 otherwise.
  For continuous state variables an example is the agent's #italic[wealth], for which
  the interval $[5, 10]$ covers all relevant data points. The state space is then simply
  the Cartesian product of the two spaces, i.e. $statespace = {0, 1} times [5, 10]$.
]

Similarly, the _action space_ $actionspace_t$ describes the set of all potential action
combinations in period $t$.
An action $a_t in actionspace_t$ can be any combination of discrete and continuous
variables.
We denote _continuous actions_ by $c_t in actionspace_t^c$ and _discrete actions_ by
$d_t in actionspace_t^d$, such that $a_t = (c_t, d_t) in actionspace_t^c times
actionspace_t^d = actionspace_t$.

#example[
  A discrete action (or choice variable) is the #italic[retirement] decision, modelled
  as a binary variable that is 1 if the agent retires and 0 otherwise. A continuous
  action variable is the agent's #italic[savings] decision, modelled, for example, as a
  real variable that lives in the interval $[0, 10]$.
  The action space is then given by $actionspace = {0, 1} times [0, 10]$.
]

The _state-action space_ describes all possible combinations of states and actions. In
period $t$, we have $(x_t, a_t) in statespace_t times actionspace_t$.

#important[
  In the current implementation of #lcm, there is no one-to-one mapping between the
  space of continuous state or action variables and what we work with on the computer.
  For continuous variables we discretize the space. For example, with a discretization
  step of 0.1, we would store the interval $[5, 10]$ as the set of values ${5, 5.1, ...,
  9.9, 10}$.
]

#todo[
  *Not implemented in #lcm yet.*

  While $statespace_t$ is a very concise general notation, for practical applications
  and memory efficiency, it is often useful to divide it into
  $statespace_t = statespace_t^("xm") times statespace_t^("xc")$, where $"xm"$
  stands for state-modifying and $"xc"$ for state-constant variables. That is, $"xm"$
  collects thse state variables that lead to a completely different state-choice space
  in terms of the remaining state-constant state variables. A prime example would be the
  vital status: If an agent dies between periods $t$ and $t+1$, all that matters for the
  continuation value is her wealth, all other state variables are irrelevant. Another
  example would be marital status when household maximize joint utility (e.g.,
  #citet(<Borella2022>)). The state-space conditional on being married is much larger
  than conditional on being single.
]


=== Constraints

Restrictions on the action space can be modelled using _constraints_.
Formally, constraints are functions that map state-action pairs and the current period
into a Boolean value 

#eq[$
  constraints_t : statespace_t times actionspace_t -> {"True", "False"}.
$]

A value of "True" indicates that the constraint is satisfied, and "False" indicates
that it is violated; that is, a feasible action is one that satisfies the constraint.

Constraints can be parametrized by a real vector $theta_constraints$, so that
$constraints_(t)(x_t, a_t) = constraints_(t)(x_t, a_t | theta_constraints)$. For
constraints that act upon the discrete and continuous actions separately, we write

#eq[$
constraints_(t)^(c) &: statespace_t times actionspace_t^c -> {"True", "False"}, \
constraints_(t)^(d) &: statespace_t times actionspace_t^d -> {"True", "False"}.
$]


The feasible action spaces of the agent in period $t$, when facing state $X_t = x_t$,
are given by
#footnote[
  In the literature, this is also often written as $a_t in Gamma_(t)(x_t)$.
]

#eq[$
  FeasibleActionSpace_(t)(x_t) &= {a_t in actionspace | constraints_(t)(x_t, a_t) "is True"}, \ \
  FeasibleActionSpace_(t)^(c)(x_t) &= {c_t in actionspace^c | constraints_(t)^(c)(x_t, c_t) "is True"}, \ \
  FeasibleActionSpace_(t)^(d)(x_t) &= {d_t in actionspace^d | constraints_(t)^(d)(x_t, d_t) "is True"}.
$]

#example[
  As an example consider a #italic[borrowing constraint], which restricts the
  agent's consumption to be bounded from above by her #italic[wealth].
  Assume there is only one state variable $x_t$ that represents the agent's wealth, and
  only one action variable $a_t$ that represents the agent's consumption.
  The constraint then takes the form $constraints_(t)(x_t, a_t) = [a_t lt.eq.slant x_t]$.
  A version that depends on model parameters could allow for some borrowing, i.e.
  consuming more than your current wealth:
  $constraints_(t)(x_t, a_t | theta_constraints) = [a_t lt.eq.slant x_t + theta_constraints]$.
]

#todo[
  *Note:* Not implemented yet. 

  Some types of constraints allow to reduce the state-action space. For example, a
  forced-retirement constraint could reduce the feasible actions to a single point.
]

== Utility Function

The _instantaneous utility function_ $u_t$ maps the current state and action into a
real-valued #italic[reward], i.e.

#eq[$u_t : statespace_t times actionspace_t -> bb(R).$]

Using the notation from the introduction, we have $R_t = u_(t)(X_t, A_t)$.

#note[
  #lcm can #underline[not] handle non-parametric functions. Instead, the
  utility function is _parametrized_ by a real vector $theta_u$. While we suppress
  this dependence in the following, it is important to keep in mind that there is a
  finite-dimensional parameter governing the functional form of the utility function
  $u_(t)(X_t, A_t) = u_(t)(X_t, A_t | theta_u)$.
]

#warning[
  Currently, #lcm supports only deterministic utility functions. We plan to add support
  for certain additive utility shocks (#italic[taste shocks]) in the future.
]

== State Transition

In the dynamic models under consideration, the state $X_t$ evolves conditional on past
information ${X_(t-1), A_(t-1), dots, X_0, A_0}$. We assume that the process satisfies
the _Markov property_, i.e. the future state $X_(t+1)$ only depends on the current state
$X_t$ and the action $A_t$.

This is modelled using the Markov _transition kernel_ $P_t$, which describes the
distribution of the next state, conditional on the current state and action, i.e.
#footnote[In the literature this is called a #italic[controlled] Markov process, as the
transition kernel depends on the action taken by the agent.]

#eq[$
  X_(t+1) tilde.op P_(t+1)(X_t, A_t).
$]

If the state transition is #italic[deterministic], we write $X_(t+1) = 
P_(t+1)(X_t, A_t)$. We will also sometimes write $P_(t+1)(dot | X_t, A_t)$ for the
cumulative distribution function of the next state given the current state and action.
This allows us to write, for example, the expected value of a function
$f : statespace_(t+1) -> bb(R)$, defined on tomorrow's state space, as

#eq[$
  bb(E)[f(X_(t+1)) | X_t, A_t] = integral_statespace_(t+1) f(x_(t+1)) dif P_(t+1)(x_(t+1) | X_t, A_t).
$]

#note[
The transition kernel is allowed to depend on a time-dependent parameter $theta_(P,t)$,
so that explicitly, we have $P_(t+1)(X_t, A_t) = P_(t+1)(X_t, A_t | theta_(P,t))$.
]

#warning[
  Currently, #lcm supports stochastic state transitions only for discrete state
  variables.
]

== Policy Function

In order to maximize lifetime reward (see e.g., @eq-lifetime-reward), the agent
needs to take decisions $(A_1, dots, A_T)$. Given the temporal structure of the dynamic
problem outlined in the preface, the agent is aware of the current state $X_t$ when
taking the action $A_t$.

A _policy function_ $pi_t$ maps the state in period $t$ to the action that is
taken in that period, i.e. $pi_t : statespace_t -> actionspace_t.$ Using this, we can
thus write the agent's action as $A_t = pi_(t)(X_t)$.

= The Problem

In this section, we introduce the dynamic programming problem in the context of
discrete-time and finite-horizon models. The section concludes with the derivation of
the Bellman equation for the value function and equivalent versions thereof, which helps
us in drawing the connection between the mathematical problem and the #lcm codebase. As
a reference, consider #citet(<Rust2018>).


== Sequence Problem

Using the notation from the previous section, we can formalize
@eq-lifetime-reward. We assume that the agent aims to solve the following problem:


#numbered_eq($
  max_{pi_s, dots, pi_T} bb(E)[ sum_(t=s)^T beta^(t-s) u_(t)(X_t, A_t) | X_s = x_s] \
  "such that" X_(t+1) tilde.op P_(t+1)(X_t, A_t) "and" A_t in FeasibleActionSpace_(t)(X_t),
$) <eq-sequence-problem>

with $x_0$ denoting deterministic initial state, and $A_t = pi_(t)(X_t)$.

In the following, we will always assume that $X_(t+1) tilde.op P_(t+1)(X_t, A_t)$ and
only mention it when necessary.


#important[
As stated in the introduction, this baseline objective is only one of many possible
objectives that #lcm can handle. @eq-sequence-problem can be solved
out-of-the-box with #lcm. Other objectives require the user to implement the
concrete solution method themselves.
]

== Optimal Policy and Action

We write $pi^ast_(t)$ to denote the _optimal policy_, that is, the solution to
@eq-sequence-problem. Correspondingly, we write $A^ast_t = pi^ast_(t)(X_t)$ or
$a^ast_t = pi^ast_(t)(x_t)$ for the optimal action.


== Value Function

The _value function_ in period $t$ is defined as the expected lifetime reward, given the
agent finds itself in state $X_t = x_t$ and follows the optimal policy thereafter:

#eq[$
  V_(t)(x_t) \
  &= bb(E)_(X_(r+1) ~ P_(r+1)(X_r, A_r^ast))[ sum_(r=t)^T beta^(r-t) u_(r)(X_r, A_r^ast) | x_t] \
  &= u_(t)(x_t, a_t^ast) + bb(E)_(X_(r+1) ~ P_(r+1)(X_r, A_r^ast))[ sum_(r=t+1)^T beta^(r-t) u_(r)(X_r, A_r^ast)  | x_t] \
  &= u_(t)(x_t, a_t^ast) + beta dot bb(E)_(X_(r+1) ~ P_(r+1)(X_r, A_r^ast))[ sum_(r=t+1)^T beta^(r-t-1) u_(r)(X_r, A_r^ast)  | x_t] \
  &= u_(t)(x_t, a_t^ast) + beta dot bb(E)_(X_(t+1)) [bb(E)_(X_(r+1) ~ P_(r+1)(X_r, A_r^ast))[ sum_(r=t+1)^T beta^(r-t-1) u_(r)(X_r, A_r^ast)  | X_(t+1), x_t]] \
  
  
  &= u_(t)(x_t, a_t^ast) + beta dot bb(E)_(X_(t+1))[ V_(t+1)(X_(t+1))] \ \
  &= u_(t)(x_t, a_t^ast) + beta dot integral_statespace_(t+1) V_(t+1)(x_(t+1)) dif P_(t+1)(x_(t+1) | x_t, a_t^ast).
$]


#lcm currently assumes that all value functions beyond the last period are zero. Using
this, the last period value function simplifies to
#eq[$
  V_(T)(X_T) = u_(T)(X_T, A_T^ast).
$]

#note[
  The above derivation used the structure of the lifetime reward specification. For other
  choices, different forms of the Bellman equations follow. Further, in comparison to
  infinite-horizon models, where there is only one value function, finite-horizon
  models require the solution to one value function per period.
]

== Recursive Problem

In the previous subsection, we have derived the _Bellman equation_ for the value function
from the #italic[sequence problem] (@eq-sequence-problem). The Bellman equation
is given by 

#numbered_eq[$
  V_(t)(x_t) 
  &= &&u_(t)(x_t, a_t^ast) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t^ast))[ V_(t+1)(X_(t+1))] \
  &= max_(a_t in FeasibleActionSpace_(t)(x_t)) {&&u_(t)(x_t, a_t) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t))[ V_(t+1)(X_(t+1))]}
$] <eq-bellman>

Because the problem has a finite-horizon, the last period $t=T$ is a boundary condition
that can be solved directly:

#numbered_eq[$
  V_(T)(x_T) = max_(a_T in FeasibleActionSpace_(T)(x_T)) u_(T)(x_T, a_T).
$] <eq-bellman-boundary>

This allows us to solve for the other value functions using backward induction.

Given the value functions $(V_1, dots, V_T)$, we can solve for the optimal policy

#numbered_eq[$
  pi^ast_(t)(x_t) = a_t^ast = argmax_(a_t in FeasibleActionSpace_(t)(x_t)) {u_(t)(x_t, a_t) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t))[ V_(t+1)(X_(t+1))]},
$] <eq-bellman-policy>

and for the last period

#numbered_eq[$
  pi^ast_(T)(x_T) = a_T^ast = argmax_(a_T in FeasibleActionSpace_(T)(x_T)) u_(T)(x_T, a_T).
$] <eq-bellman-boundary-policy>


#note[
  In #lcm, we require the optimal policy only when simulating the model. During the
  simulation, we do not need to compute the optimal policy function $pi^ast_(t)$ at all
  possible states, however. Instead, we iterate over a set of fixed states, starting
  with the user provided initial states, and only compute the optimal policy there.
]

== Additional Definitions <subsection-additional-definitions>

In this section, we introduce some additional definitions that are useful to
understand #lcm internals.

The _continuation value_ is the expected value from the next period onwards, given that
the agent is in state $x_t$ and takes action $a_t$:

#eq[$
  C_(t)(x_t, a_t) = bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t))[ V_(t+1)(X_(t+1))].
$]

The _action-value function_ $Q_t : statespace_t times actionspace_t -> bb(R)$ assigns a
value to each state-action pair $(x_t, a_t)$ considering the instantaneous reward and
the continuation value:

#eq[$
  Q_(t)(x_t, a_t) &= u_(t)(x_t, a_t) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t))[ V_(t+1)(X_(t+1))] \
  &= u_(t)(x_t, a_t) + beta dot C_(t)(x_t, a_t).
$]

It is related to the value function by

#eq[$
  V_(t)(x_t) = max_(a_t in FeasibleActionSpace_(t)(x_t)) Q_(t)(x_t, a_t).
$]

The _conditional-action-value function_
$Q_(t)^(c): statespace_t times actionspace_t^(d) -> bb(R)$ maps a state and a
discrete action to the maximum of the action-value function over the continuous actions:

#eq[$
  Q_(t)^(c)(x_t, a_t^d) = max_(a_t^c in FeasibleActionSpace_(t)^(c)(x_t)) Q_(t)(x_t, a_t^c, a_t^d).
$]




== Maximization <subsection-maximization>

In @eq-bellman to @eq-bellman-boundary-policy[] we are maximizing over the joint action
space of discrete and continuous actions. From a computational perspective, it is easier
to think of this problem as first finding the maximum over the continuous action
#underline[conditional] on the discrete actions, and then finding the discrete action
that achieves the overall maximum.

We can rewrite the Bellman equation (@eq-bellman) as

#eq[$
  V_(t)(x_t) 
  &= &&u_(t)(x_t, a_t^ast) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t^ast))[ V_(t+1)(X_(t+1))] \
  &= max_(a_t in FeasibleActionSpace_(t)(x_t)) {&&u_(t)(x_t, a_t) + beta dot bb(E)_(X_(t+1) ~ P_(t+1)(x_t, a_t))[ V_(t+1)(X_(t+1))]} \ 
  & = max_(a_t in FeasibleActionSpace_(t)(x_t)) {&&u_(t)(x_t, a_t) + beta dot C_(t)(x_t, a_t)} \
  & = max_(a_t in FeasibleActionSpace_(t)(x_t)) &&Q_(t)(x_t, a_t) \
  & = max_(a_t^d in FeasibleActionSpace_(t)^(d)(x_t)) &&max_(a_t^c in FeasibleActionSpace_(t)^(c)(x_t)) Q_(t)(x_t, a_t^c, a_t^d) \
  & = max_(a_t^d in FeasibleActionSpace_(t)^(d)(x_t)) &&Q_(t)^(c)(x_t, a_t^d).
$]

This restatement is important to understand the #lcm codebase, as the maximization over
discrete and continuous actions is handled as stated above.

// Glossary of Notations
// =====================================================================================
#pagebreak()
= Glossary of Notations



#table(
  columns: (auto, 1fr),
  stroke: none,
  table.header[*Symbol*][*Description*],
  table.hline(),
  [$X_t, x_t$], [The state (and realized state) in period $t$],
  [$A_t, a_t$], [The action (and realized action) in period $t$],
  [$A_t^ast, a_t^ast$], [The optimal action (and realized optimal action) in period $t$],
  [$R_t$], [The instantaneous reward in period $t$],
  [$c_t, d_t$], [The continuous and discrete actions in period $t$; $a_t = (c_t, d_t)$],
  table.hline(),
  [$statespace_t$], [The state space in period $t$; $X_t in statespace_t$],
  [$actionspace_t$], [The action space in period $t$; $A_t in actionspace_t$],
  [$actionspace_t^c$], [The action space for the continuous actions in period $t$; $c_t in actionspace_t^c$],
  [$actionspace_t^d$], [The action space for the discrete actions in period $t$; $d_t in actionspace_t^d$],
  [$FeasibleActionSpace_(t)(x_t)$], [The feasible action space in period $t$, given state $x_t$],
  [$FeasibleActionSpace_(t)^(c)(x_t)$], [The feasible continuous action space in period $t$, given state $x_t$],
  [$FeasibleActionSpace_(t)^(d)(x_t)$], [The feasible discrete action space in period $t$, given state $x_t$],
  table.hline(),
  [$u_t$], [The instantaneous utility function in period $t$; $u_t : statespace_t times actionspace_t -> bb(R)$],
  [$V_t$], [The value function in period $t$; $V_t : statespace_t -> bb(R)$],
  [$constraints_t$], [
    The constraint function in period $t$; $constraints_t : statespace_t times actionspace_t -> {"True", "False"}$
    ],
  [$P_t$], [The Markov transition kernel in period $t$; $X_(t+1) tilde.op P_(t+1)(X_t, A_t)$],
  [$pi_t$], [The policy in period $t$; $pi_t : statespace -> actionspace$],
  [$pi_t^ast$], [The optimal policy in period $t$],
  [$C_(t)$], [The continuation value in period $t$; $C_(t) : statespace_t times actionspace_t -> bb(R)$],
  [$Q_(t)$], [The action-value function in period $t$; $Q_(t) : statespace_t times actionspace_t -> bb(R)$],
  [$Q_(t)^(c)$], [The conditional-action-value function in period $t$; $Q_(t)^(c) : statespace_t times actionspace_t^(d) -> bb(R)$],
  table.hline(),
  [$beta$], [The discount factor],
  [$theta_constraints$], [The parameters for the constraints],
  [$theta_u$], [The parameters for the utility function],
  [$theta_P$], [The parameters for the transition kernel],
)


// Codebase
// =====================================================================================
#pagebreak()

= Codebase

#warning[
  This section is currently under development. The content is not yet finalized.
]

In this section, we relate the relevant functions of the #lcm codebase to the concepts
introduced in the previous sections. Each subsection corresponds to a module in the
codebase.

== `argmax.py`

The `argmax.py` module provides functions that are used to calculate the #italic[argmax]
in @eq-bellman-policy and @eq-bellman-boundary-policy[].

The `argmax()` function handles dense actions, while the `segment_argmax()` function
handles sparse actions.

== `create_params.py`

The `create_params.py` module provides functions that are used to create a parameter
template that can be filled by the user. The structure of the template is always
the following

```python
params_template = {
  "beta": jnp.nan,
  "utility": {"disutility_of_action": jnp.nan},
  ...
}
```

where in this case `"disutility_of_action"` is a placeholder for the utility parameter
$theta_u$.


== `discrete_problem.py`

The `discrete_problem.py` module provides a #italic[getter function] that returns the
discrete problem solver. This solver takes as input the conditional continuation values,
i.e. the value function evaluated at the optimal dense continuous action. The solver
returns the maximum value over the remaining sparse and discrete actions.

In @subsection-maximization we have shown that

#eq[$
  &V_(t)(x_t)
  = max_(c_t^(sans(s)), d_t^(sans(d))) "CCV"_(t)(d_t, c_t^(sans(s)), x_t).
$]

This problem is solved using the functions in `discrete_problem.py`.

#note[

If the utility function is deterministic, the solver simply uses a regular maximum
operation for the dense-discrete actions, and a segment maximum operation for the
remaining sparse actions (for these only specific combination of state and action
pairs are valid, which is handled via the segmentation).

This step is also known as calculating the #italic[expected maximum (emax)], because if
the utility function is stochastic, we have to compute the expectation of the maximum.

A common form of stochastics are additive utility shocks that are IID across actions
and Extreme Value Type-I distributed. In this case, the maximum and arg-maximum have a
closed form solution. This is, however, #underline[currently not implemented.]
]

#pagebreak()
#bibliography("bibliography.bib", style: "chicago-author-date")