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

# LP緩和問題を解くクラス
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
    # LP緩和問題を解いて、xCeiling, xFloor, optimalSolutionCeiling, optimalSolutionFloorを格納する
    def solve
        l = self.pickL()
        for i in 1 .. @itemCosts.length
            if i < l then
                @xCeiling.push(1)
                @xFloor.push(1)
            elsif i == l then
                xl = xL(l)
                @xCeiling.push(xl)
                @xFloor.push(xl.floor)
            else
                @xCeiling.push(0)
                @xFloor.push(0)
            end
        end
        @optimalSolutionCeiling = self.calculateOptimalSolution(@xCeiling)
        @optimalSolutionFloor = self.calculateOptimalSolution(@xFloor)
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
    # i == lのときのxの値を返す
    def xL(l)
        result = @knapsackWeight
        for i in 1 .. l-1
            result -= @itemWeights[i-1]
        end
        return result.to_f / @itemWeights[l-1]
    end
    #　最適解の配列xから目的関数値を返す
    def calculateOptimalSolution(x)
        result = 0
        for i in 0 .. x.length-1
            result += @itemCosts[i]*x[i]
        end
        return result
    end

    def printStatus
        puts "------"
        puts "itemCosts     : " + @itemCosts.to_s
        puts "itemWeights   : " + @itemWeights.to_s
        puts "knapsackWeight: " + @knapsackWeight.to_s
        puts "----"
        if @xCeiling.length == 0 then
            puts "this problem is not solved yet"
        else
            puts "this problem is solved"
        end
        puts "xCeiling: " + @xCeiling.to_s
        puts "xFloor  : " + @xFloor.to_s
        puts "optimalSolutionCeiling: " + @optimalSolutionCeiling.to_s
        puts "optimalSolutionFloor  : " + @optimalSolutionFloor.to_s
        puts "------"
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

    ps = ProblemSolve.new(itemCosts, itemWeights, knapsackWeight)
    ps.printStatus()
    ps.solve()
    ps.printStatus()
end



