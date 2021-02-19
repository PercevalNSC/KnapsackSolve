# Knapsack Solver by branch and bound 
# developer : @PercevalNSC

# complete basis function, but not enough checking and comment

# TODO: add comment for some methods
# FEATURE: fix searching subproblem in selectval and constructX
# FEATURE: merge @itemcosts and @itemweights to one array
# FEATURE: fix name of some variables and methods
# FEATURE: sorting input


class KnapackSolve
    def initialize(itemCosts, itemWeights, knapsackWeight)
        inputCheck(itemCosts, itemWeights, knapsackWeight)

        @itemCosts = itemCosts
        @itemWeights = itemWeights
        @knapsackWeight = knapsackWeight
        @problems = Array.new()
        @provisionalX = Array.new()
        @provisionalSolution = 0
    end
    def solve
        # step1: solve initial problem
        fp = LPsolve.new(@itemCosts, @itemWeights, @knapsackWeight)
        fp.solve()
        @provisionalX = fp.xFloor.clone
        @provisionalSolution = fp.optimalSolutionFloor

        # step2
        if fp.optimalSolutionFloor == fp.optimalSolutionCeiling then
            return
        else
            index = 1
            for i in 0..1
                newSubProblem = [[index, i]]
                @problems.push(newSubProblem)
            end
            puts @problems.to_s
        end

        # step3: pick subproblem
        while @problems.length != 0
            subproblem = @problems.pop
            puts "subproblem: " + subproblem.to_s

            sp = constructSubProblem(subproblem)
            sp.solve()

            # bound
            if sp.optimalSolutionCeiling <= @provisionalSolution then next end
            if sp.optimalSolutionFloor > @provisionalSolution then
                @provisionalX = constructX(subproblem, sp.xFloor)
                @constructSubProblem = sp.optimalSolutionFloor + self.differentFunction(subproblem)
            end
            if sp.optimalSolutionFloor == sp.optimalSolutionCeiling then next en

            self.branch(subproblem)
        end
        return
    end
    def inputCheck(itemCosts, itemWeights, knapsackWeight)
        if itemCosts.length != itemWeights.length then
            puts "Input Error: different length of itemCosts and itemWeights"
            exit
        end
        for i in 0 .. itemCosts.length - 1
            if itemCosts[i] <= 0 then
                puts "Input Error: itemCosts need number > 0"
            end
            if itemWeights[i] <= 0 then
                puts "Input Error: itemWeights need number > 0"
            end
            exit
        end
        if knapsackWeight < 0 then
            puts "Input Error: knapsack weight need > 0"
            exit
        end
    end

    # 分枝での変数選択
    # 選べないときには0を返す
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
    # subproblemで既知の変数を除いた小さいLP緩和問題を返す
    def constructSubProblem(subproblem)
        subcosts = @itemCosts.clone
        subweights = @itemWeights.clone
        subkpweight = @knapsackWeight
        subproblem.each do |sub|
            subkpweight -= subweights[sub[0]-1]*sub[1]
            subcosts.delete_at(sub[0]-1)
            subweights.delete_at(sub[0]-1)
        end
        return LPsolve.new(subcosts, subweights, subkpweight)
    end
    # 小問題では既知の変数が出てこないため、既知の変数とLP緩和問題の解を合わせて解を作成する
    def constructX(subproblem, subx)
        resultx = Array.new()
        for i in 0 .. @itemCosts.length-1
            flag = 0
            subproblem.each do |sub|
                if sub[0] == i then
                    resultx.push(sub[1])
                    flag = 1
                    break
                end
            end
            if flag == 0 then
                resultx.push(subx.shift)
            end
        end
        return resultx
    end
    # 分枝操作、変数を選んで0と1それぞれについて問題集合Problemsに格納する
    def branch(subproblem)
        index = selectval(subproblem)
        for i in 0..1
            newSubProblem = subproblem.clone
            newSubProblem.push([index, i])
            @problems.push(newSubProblem)
        end
    end
    def printStatus
        puts "------"
        puts "itemCosts     : " + @itemCosts.to_s
        puts "itemWeights   : " + @itemWeights.to_s
        puts "knapsackWeight: " + @knapsackWeight.to_s
        puts "---"
        puts "x: " + @provisionalX.to_s
        puts "optimalSolution: " + @provisionalSolution.to_s
        puts "------"
    end
end

# LP緩和問題を解くクラス
class LPsolve
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
        self.printStatus()
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
        return index+1
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
        puts "---"
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

    kpsolve.solve()
    kpsolve.printStatus()
end