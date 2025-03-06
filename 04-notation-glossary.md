---
title: Notation & Glossary
author: Tim Mensinger
---

## Variables

| Symbol | Description |
|--------|-------------|
| $X_t, x_t$ | The state (and realized state) in period $t$ |
| $A_t, a_t$ | The action (and realized action) in period $t$ |
| $A_t^*, a_t^*$ | The optimal action (and realized optimal action) in period $t$ |
| $R_t$ | The instantaneous reward in period $t$ |
| $c_t, d_t$ | The continuous and discrete actions in period $t$; $a_t = (c_t, d_t)$ |


## Spaces

| Symbol | Description |
|--------|-------------|
| $\mathbb{X}_t$ | The state space in period $t$; $X_t \in \mathbb{X}_t$ |
| $\mathbb{A}_t$ | The action space in period $t$; $A_t \in \mathbb{A}_t$ |
| $\mathbb{A}_t^c$ | The action space for the continuous actions in period $t$; $c_t \in \mathbb{A}_t^c$ |
| $\mathbb{A}_t^d$ | The action space for the discrete actions in period $t$; $d_t \in \mathbb{A}_t^d$ |
| $\Gamma_{t}(x_t)$ | The feasible action space in period $t$, given state $x_t$ |
| $\Gamma_{t}^{c}(x_t)$ | The feasible continuous action space in period $t$, given state $x_t$ |
| $\Gamma_{t}^{d}(x_t)$ | The feasible discrete action space in period $t$, given state $x_t$ |


## Functions

| Symbol | Description |
|--------|-------------|
| $u_t$ | The instantaneous utility function in period $t$; $u_t : \mathbb{X}_t \times \mathbb{A}_t \to \mathbb{R}$ |
| $V_t$ | The value function in period $t$; $V_t : \mathbb{X}_t \to \mathbb{R}$ |
| $\mathcal{C}_t$ | The constraint function in period $t$; $\mathcal{C}_t : \mathbb{X}_t \times \mathbb{A}_t \to \{\text{True}, \text{False}\}$ |
| $P_t$ | The Markov transition kernel in period $t$; $X_{t+1} \sim P_{t+1}(X_t, A_t)$ |
| $\pi_t$ | The policy in period $t$; $\pi_t : \mathbb{X} \to \mathbb{A}$ |
| $\pi_t^*$ | The optimal policy in period $t$ |
| $F_{t}$ | The continuation value in period $t$; $F_{t} : \mathbb{X}_t \times \mathbb{A}_t \to \mathbb{R}$ |
| $Q_{t}$ | The action-value function in period $t$; $Q_{t} : \mathbb{X}_t \times \mathbb{A}_t \to \mathbb{R}$ |
| $Q_{t}^{c}$ | The conditional-action-value function in period $t$; $Q_{t}^{c} : \mathbb{X}_t \times \mathbb{A}_t^{d} \to \mathbb{R}$ |

## Parameters

| Symbol | Description |
|--------|-------------|
| $\beta$ | The discount factor |
| $\theta_\mathcal{C}$ | The parameters for the constraints |
| $\theta_u$ | The parameters for the utility function |
| $\theta_P$ | The parameters for the transition kernel |