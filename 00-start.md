---
title: Abstract and Intent
author: Tim Mensinger
---

The following notes aim to showcase the mathematical problem that LCM solves,
and tries to connect the mathematical concepts to the codebase. We introduce the basic
concepts of dynamic programming and then derive the Bellman equation for the value
functions. LCM can be used to solve for these value functions numerically (*model
solution*) or to find the optimal policy (i.e., optimal choices) given such a model solution (*model
simulation*).

These notes are intended to be a reference for developers working on the
LCM codebase, and for users who want to improve their understanding of the connection
between the mathematical model and LCM.