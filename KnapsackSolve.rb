# Knapsack Solver by branch and bound 
# developer : @PercevalNSC

class KnapackSolve
    def initialize(itemCosts, itemWeights, knapsackWeight)
        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsackWeight = knapsackWeight
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
    def differentFunction(subproblem)
        result = 0
        subproblem.each do |sub|
            result += @itemCosts[sub[0]-1] * sub[1]
        end
        return result
    end
end

class ProblemSolve
    attr_reader :xCeiling, :xFloor, :optimalSolutionCeiling, :optimalSolutionFloor
    def initialize(itemCosts, itemWeights, knapsacWeight)
        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsackWeight = knapsackWeight
        @xCeiling = Array.new()
        @xFloor = Array.new()
        @optimalSolutionCeiling = 0
        @optimalSolutionFloor = 0
    end
end

# ---- test ----
if __FILE__ == $0
    itemCosts = [3, 5, 7, 4, 10]
    itemWeights = [1, 2, 3, 2, 5]
    knapsackWeight = 9

    kpsolve = KnapackSolve.new(itemCosts, itemWeights, knapsackWeight)

    subproblem = [[1, 0], [2, 1]]
    puts kpsolve.selectval(subproblem)
    puts kpsolve.differentFunction(subproblem)
end



