//
//  AILogic.swift
//  archess
//
//  Created by 张裕阳 on 2023/2/14.
//

import Foundation


struct AIChessInfo {
    static var indexDict = [[0,0]:0, [0,1]:0, [0,2]:0, [0,3]:0, [0,4]:0, [0,5]:0, [0,6]:0, [0,7]:0, [0,8]:0, [0,9]:0,
                            [1,0]:0, [1,1]:0, [1,2]:0, [1,3]:0, [1,4]:0, [1,5]:0, [1,6]:0, [1,7]:0, [1,8]:0, [1,9]:0,
                            [2,0]:0, [2,1]:0, [2,2]:0, [2,3]:0, [2,4]:0, [2,5]:0, [2,6]:0, [2,7]:0, [2,8]:0, [2,9]:0,
                            [3,0]:0, [3,1]:0, [3,2]:0, [3,3]:0, [3,4]:0, [3,5]:0, [3,6]:0, [3,7]:0, [3,8]:0, [3,9]:0,
                            [4,0]:0, [4,1]:0, [4,2]:0, [4,3]:0, [4,4]:0, [4,5]:0, [4,6]:0, [4,7]:0, [4,8]:0, [4,9]:0,
                            [5,0]:0, [5,1]:0, [5,2]:0, [5,3]:0, [5,4]:0, [5,5]:0, [5,6]:0, [5,7]:0, [5,8]:0, [5,9]:0,
                            [6,0]:0, [6,1]:0, [6,2]:0, [6,3]:0, [6,4]:0, [6,5]:0, [6,6]:0, [6,7]:0, [6,8]:0, [6,9]:0,
                            [7,0]:0, [7,1]:0, [7,2]:0, [7,3]:0, [7,4]:0, [7,5]:0, [7,6]:0, [7,7]:0, [7,8]:0, [7,9]:0,
                            [8,0]:0, [8,1]:0, [8,2]:0, [8,3]:0, [8,4]:0, [8,5]:0, [8,6]:0, [8,7]:0, [8,8]:0, [8,9]:0,
                            [9,0]:0, [9,1]:0, [9,2]:0, [9,3]:0, [9,4]:0, [9,5]:0, [9,6]:0, [9,7]:0, [9,8]:0, [9,9]:0,]
    static var IndexArray = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    
    static var nextStep: [Int] = [0, 0]
    
    static var level = 2 //1-简单，2-中等，3-困难
    
    static var AIChessColor = 0
    
    static let searchDepth = 3

}
//哈希表存放棋子信息

func resetAIChessInfo() {
    AIChessInfo.nextStep = [0,0]
    AIChessInfo.indexDict = [[0,0]:0, [0,1]:0, [0,2]:0, [0,3]:0, [0,4]:0, [0,5]:0, [0,6]:0, [0,7]:0, [0,8]:0, [0,9]:0,
                             [1,0]:0, [1,1]:0, [1,2]:0, [1,3]:0, [1,4]:0, [1,5]:0, [1,6]:0, [1,7]:0, [1,8]:0, [1,9]:0,
                             [2,0]:0, [2,1]:0, [2,2]:0, [2,3]:0, [2,4]:0, [2,5]:0, [2,6]:0, [2,7]:0, [2,8]:0, [2,9]:0,
                             [3,0]:0, [3,1]:0, [3,2]:0, [3,3]:0, [3,4]:0, [3,5]:0, [3,6]:0, [3,7]:0, [3,8]:0, [3,9]:0,
                             [4,0]:0, [4,1]:0, [4,2]:0, [4,3]:0, [4,4]:0, [4,5]:0, [4,6]:0, [4,7]:0, [4,8]:0, [4,9]:0,
                             [5,0]:0, [5,1]:0, [5,2]:0, [5,3]:0, [5,4]:0, [5,5]:0, [5,6]:0, [5,7]:0, [5,8]:0, [5,9]:0,
                             [6,0]:0, [6,1]:0, [6,2]:0, [6,3]:0, [6,4]:0, [6,5]:0, [6,6]:0, [6,7]:0, [6,8]:0, [6,9]:0,
                             [7,0]:0, [7,1]:0, [7,2]:0, [7,3]:0, [7,4]:0, [7,5]:0, [7,6]:0, [7,7]:0, [7,8]:0, [7,9]:0,
                             [8,0]:0, [8,1]:0, [8,2]:0, [8,3]:0, [8,4]:0, [8,5]:0, [8,6]:0, [8,7]:0, [8,8]:0, [8,9]:0,
                             [9,0]:0, [9,1]:0, [9,2]:0, [9,3]:0, [9,4]:0, [9,5]:0, [9,6]:0, [9,7]:0, [9,8]:0, [9,9]:0,]
    AIChessInfo.IndexArray = [[Int]](repeating: [Int](repeating: 0, count: 9), count: 9)
    AIChessInfo.AIChessColor = 0
}

func AIInitial(with level: Int) {
    //AI下棋思路
    //简单AI 只会堵祺
    //中等AI 极大极小值搜索+alphabeta剪枝算法
    //高级AI 会复杂的套路
    switch level {
    case 1:
        EasyAI()
        return
    case 2:
        MediumAI()
    case 3:
        HardAI()
    default:
        fatalError("cannot initial ai without a AIlevel")
    }
}

func EasyAI() {}
func HardAI() {}
func MediumAI() {
    if MyChessInfo.myChessColor == 1{
        AIChessInfo.AIChessColor = 2
    } else {
        AIChessInfo.AIChessColor = 1
    }
}


func AIstep() -> [Int]? {
    let value = negaMax(depth: AIChessInfo.searchDepth, alpha: -999999, beta: 999999)
    AIChessInfo.indexDict[AIChessInfo.nextStep] = AIChessInfo.AIChessColor
    AIChessInfo.IndexArray[AIChessInfo.nextStep[0]][AIChessInfo.nextStep[1]] = AIChessInfo.AIChessColor
    if isAIWin(AIChessInfo.IndexArray) {
        print("AI获胜！")
        return nil
    }
    return AIChessInfo.nextStep
}

func negaMax(depth: Int, alpha: Int, beta: Int) -> Int {
    var newAlpha: Int = alpha
    if depth == 0 {
        return evaluate()
    }
    //寻找空白点
    for (key, value) in AIChessInfo.indexDict {
        if value == 1 || value == 2 {
            continue
        }
        if hasNeibour(for: key) == false {
            continue
        }
        AIChessInfo.indexDict.updateValue(AIChessInfo.AIChessColor, forKey: key)
        AIChessInfo.IndexArray[key[0]][key[1]] = value
        let value = negaMax(depth: depth-1, alpha: -beta, beta: -newAlpha)
        AIChessInfo.indexDict.updateValue(0, forKey: key)
        AIChessInfo.IndexArray[key[0]][key[1]] = 0
        if value > beta {
            AIChessInfo.nextStep = key
            return beta
        }
        if value > newAlpha {
            AIChessInfo.nextStep = key
            newAlpha = value
        }
        
    }
    
    return newAlpha
}

//计算权重综合
func evaluate() -> Int {
    
    var AIScore: Int = 0
    //更新AI棋子权重
    
    var PlayerScore: Int = 0
    //更新玩家棋子权重
    
    let totalScore = AIScore - PlayerScore/10
    return totalScore
}

//判断棋子旁有没有邻居
func hasNeibour(for key: [Int]) -> Bool {
    for i in -1...1 {
        for j in -1...1 {
            if i==j && i==0 {
                continue
            } else {
                let newkey: [Int] = [key[0]+i,key[1]+j]
                if AIChessInfo.indexDict[newkey] == 1 || AIChessInfo.indexDict[newkey] == 2 {
                    return true
                }
            }
        }
    }
    return false
}

func isAIWin(_ indexArray: [[Int]]) -> Bool {
    for i in 0..<indexArray.count {
        for j in 0..<indexArray[i].count {
            if i < indexArray.count - 4 {
                if indexArray[i][j] == AIChessInfo.AIChessColor && indexArray[i+1][j] == indexArray[i+2][j]
                    && indexArray[i+2][j] == indexArray[i+3][j] && indexArray[i+3][j] == indexArray[i+4][j]
                    && indexArray[i+4][j] == indexArray[i][j] {
                    return true
                }
            }
            if j < indexArray.count - 4 {
                if indexArray[i][j] == AIChessInfo.AIChessColor && indexArray[i][j+1] == indexArray[i][j+2]
                    && indexArray[i][j+2] == indexArray[i][j+3] && indexArray[i][j+3] == indexArray[i][j+4]
                    && indexArray[i][j+4] == indexArray[i][j] {
                    return true
                }
            }
            if i < indexArray.count - 4 && j < indexArray.count - 4 {
                if indexArray[i][j] == AIChessInfo.AIChessColor && indexArray[i+1][j+1] == indexArray[i+2][j+2]
                    && indexArray[i+2][j+2] == indexArray[i+3][j+3] && indexArray[i+3][j+3] == indexArray[i+4][j+4]
                    && indexArray[i+4][j+4] == indexArray[i][j] {
                    return true
                }
            }
            if i >= 4 {
                if indexArray[i][j] == AIChessInfo.AIChessColor && indexArray[i-1][j+1] == indexArray[i-2][j+2]
                    && indexArray[i-2][j+2] == indexArray[i-3][j+3] && indexArray[i-3][j+3] == indexArray[i-4][j+4]
                    && indexArray[i-4][j+4] == indexArray[i][j] {
                    return true
                }
            }
        }
    }
    return false
}

func isMeWin(_ indexArray: [[Int]]) -> Bool {
    for i in 0..<indexArray.count {
        for j in 0..<indexArray[i].count {
            if i < indexArray.count - 4 {
                if indexArray[i][j] == MyChessInfo.myChessColor && indexArray[i+1][j] == indexArray[i+2][j]
                    && indexArray[i+2][j] == indexArray[i+3][j] && indexArray[i+3][j] == indexArray[i+4][j]
                    && indexArray[i+4][j] == indexArray[i][j] {
                    return true
                }
            }
            if j < indexArray.count - 4 {
                if indexArray[i][j] == MyChessInfo.myChessColor && indexArray[i][j+1] == indexArray[i][j+2]
                    && indexArray[i][j+2] == indexArray[i][j+3] && indexArray[i][j+3] == indexArray[i][j+4]
                    && indexArray[i][j+4] == indexArray[i][j] {
                    return true
                }
            }
            if i < indexArray.count - 4 && j < indexArray.count - 4 {
                if indexArray[i][j] == MyChessInfo.myChessColor && indexArray[i+1][j+1] == indexArray[i+2][j+2]
                    && indexArray[i+2][j+2] == indexArray[i+3][j+3] && indexArray[i+3][j+3] == indexArray[i+4][j+4]
                    && indexArray[i+4][j+4] == indexArray[i][j] {
                    return true
                }
            }
            if i >= 4 {
                if indexArray[i][j] == MyChessInfo.myChessColor && indexArray[i-1][j+1] == indexArray[i-2][j+2]
                    && indexArray[i-2][j+2] == indexArray[i-3][j+3] && indexArray[i-3][j+3] == indexArray[i-4][j+4]
                    && indexArray[i-4][j+4] == indexArray[i][j] {
                    return true
                }
            }
        }
    }
    return false
}


func updateAIIndexArray(indexOfX: Int, indexOfY: Int, with ChessColor: Int) {
    AIChessInfo.IndexArray[4+indexOfX][4+indexOfY] = ChessColor
    AIChessInfo.indexDict.updateValue(ChessColor, forKey: [indexOfX, indexOfY])
    MyChessInfo.myChessNum += 1
}
