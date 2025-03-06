---
title: "Codebase"
author: "Tim Mensinger"
---

```{warning}
This section is currently under development. The content is not yet finalized.
```

In this section, we relate the relevant functions of the LCM codebase to the concepts introduced in the previous sections. Each subsection corresponds to a module in the codebase.

## `argmax.py`

The `argmax.py` module provides functions that are used to calculate the *argmax* in {eq}`eq-bellman-policy` and {eq}`eq-bellman-boundary-policy`.

The `argmax()` function handles dense actions, while the `segment_argmax()` function handles sparse actions.

## `create_params.py`

The `create_params.py` module provides functions that are used to create a parameter template that can be filled by the user. The structure of the template is always the following

```python
params_template = {
  "beta": jnp.nan,
  "utility": {"disutility_of_action": jnp.nan},
  ...
}
```

where in this case `"disutility_of_action"` is a placeholder for the utility parameter $\theta_u$.

## `discrete_problem.py`

The `discrete_problem.py` module provides a *getter function* that returns the discrete problem solver. This solver takes as input the conditional continuation values, i.e. the value function evaluated at the optimal dense continuous action. The solver returns the maximum value over the remaining sparse and discrete actions.

In [Maximization](#subsection-maximization) we have shown that

$$V_{t}(x_t) = \max_{c_t^{(s)}, d_t^{(d)}} \text{CCV}_{t}(d_t, c_t^{(s)}, x_t).$$

This problem is solved using the functions in `discrete_problem.py`.

```{note}
If the utility function is deterministic, the solver simply uses a regular maximum operation for the dense-discrete actions, and a segment maximum operation for the remaining sparse actions (for these only specific combination of state and action pairs are valid, which is handled via the segmentation).

This step is also known as calculating the *expected maximum (emax)*, because if the utility function is stochastic, we have to compute the expectation of the maximum.

A common form of stochastics are additive utility shocks that are IID across actions and Extreme Value Type-I distributed. In this case, the maximum and arg-maximum have a closed form solution. This is, however, __currently not implemented.__
```
