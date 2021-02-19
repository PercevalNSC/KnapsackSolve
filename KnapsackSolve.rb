# Knapsack Solver by branch and bound 
# developer : @PercevalNSC

class KnapackSolve
    def initialize(itemCosts, itemWeights, knapsackWeight)
        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsackWeight = knapsackWeight
        @problems = Array.new()
    end
    # 分枝での変数選択
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
    # subproblemで既知の変数から目的関数値の差を返す
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
    def initialize(itemCosts, itemWeights, knapsackWeight)
        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsackWeight = knapsackWeight
        @xCeiling = Array.new()
        @xFloor = Array.new()
        @optimalSolutionCeiling = 0
        @optimalSolutionFloor = 0
    end
    # アイテムの重量の和がナップサックの容量を初めて超える添え字を返す
    def pickL
        sum = 0
        index = 0
        @itemWeights.each do |item|
            sum += item
            index += 1
            if sum > @knapsackWeight then
                return index
            end
        end
        return 0
    end

end

# ---- test ----
if __FILE__ == $0
    itemCosts = [3, 5, 7, 4, 10]
    itemWeights = [1, 2, 3, 2, 5]
    knapsackWeight = 14

    kpsolve = KnapackSolve.new(itemCosts, itemWeights, knapsackWeight)

    subproblem = [[1, 0], [2, 1]]
    puts kpsolve.selectval(subproblem)
    puts kpsolve.differentFunction(subproblem)

    ps = ProblemSolve.new(itemCosts, itemWeights, knapsackWeight)
    puts ps.pickL()
end



