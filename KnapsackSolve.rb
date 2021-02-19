# Knapsack Solver by branch and bound 
# developer : @PercevalNSC

class KnapackSolve
    def initialize(itemCosts, itemWeights, knapsacWeight)
        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsacWeight = knapsacWeight
        @problems = Array.new()
    end
    def selectval(subproblem)
        for i in 1 .. @itemCosts.length 
            flag = 0
            subproblem.each do |sub|
                if i == sub[0] then
                    flag = 1
                    break
                end
            end
            if flag == 0 then
                return i
            end
        end
        puts "no selectable variable"
        return 0
    end

end

# ---- test ----

itemCosts = [3, 5, 7, 4, 10]
itemWeights = [1, 2, 3, 2, 5]
knapsacWeight = 9

kpsolve = KnapackSolve.new(itemCosts, itemWeights, itemWeights)
subproblem = [[1, 0], [2, 1], [3, 0], [4, 1], [5,1]]
puts kpsolve.selectval(subproblem)

