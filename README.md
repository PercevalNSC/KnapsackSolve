# KnapsackSolve
## Description
This program is to solve knapsack problem by branch and bound.

## Using Example
### input

~~~
itemCosts = [3, 5, 7, 4, 10]
itemWeights = [1, 2, 3, 2, 5]
knapsackWeight = 9
kpsolve = KnapackSolve.new(itemCosts, itemWeights, knapsackWeight)
kpsolve.solve()
kpsolve.printStatus()
~~~
### output
~~~
------
itemCosts     : [3, 5, 7, 4, 10]
itemWeights   : [1, 2, 3, 2, 5]
knapsackWeight: 9
---
x: [1, 1, 1, 1, 0]
optimalSolution: 19
------
~~~
