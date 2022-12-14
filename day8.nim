import std/[
    sequtils,     # map
    sets,         # intersection, toHashSet
    strformat,    # echo &"{}"
    strutils,     # split
    tables,       # toTable
]


type
    DVector = seq[int]

    # a dynamic matric with self-adjustable size attributes
    DMatrix = object
        m, n: int  # m rows, n cols; like y, x
        data: seq[DVector]


proc `+=`(mtx: var DMatrix, data: DVector) =
    mtx.data.add(data)
    mtx.m += 1
    if mtx.n == 0:
        mtx.n = len(data)
    else:
        assert mtx.n == len(data), "A matrix must be a square or a rectangle!"


proc `[]`(mtx: DMatrix, m: int): DVector =
    mtx.data[m]


proc `[]`(mtx: DMatrix, m, n: int): int =
    mtx.data[m][n]


iterator items(mtx: DMatrix): DVector =
    for i in mtx.data:
        yield i


proc `$`(mtx: DMatrix): string =
    # still using `mtx.data` to make it faster, I guess
    # this proc is for educative and debugging purposes only, anyway
    for row in mtx.data:
        for i in row:
            result &= $i & " "
        result &= "\n"


# PUZZLE SOLVING -------------------------------------------


proc transformData(data: string): DMatrix =
    for line in data.splitlines():
        result += line.mapIt(int(it) - int('0'))


iterator innerForest(mtx: DMatrix): ((int, int), int) =
    for i in 1..<mtx.m - 1:
        for j in 1..<mtx.n - 1:
            yield ((i, j), mtx[i, j])


iterator forest(mtx: DMatrix): ((int, int), int) =
    for i in 0..<mtx.m:
        for j in 0..<mtx.n:
            yield ((i, j), mtx[i, j])


# TODO try with template
template isVisible(idxs: seq[int], tree: int, other_tree: untyped) =
    for k in idxs:
        if tree <= other_tree:
            return true
    return false


proc part1(data: DMatrix): int =
    # all trees are visible in the beginning
    result = data.m * data.n

    for (coor, tree) in innerForest(data):
        # coor[0]: i, m, y
        # coor[1]: j, n, x
        let (i, j) = coor
        var hidden_score = 0

        # let b: bool = isVisible(toSeq(countup(i + 1, data.m - 1)), tree, data[k][j])
        # echo b

        # down the forest
        for k in countup(i + 1, data.m - 1):
            if tree <= data[k][j]:
                hidden_score += 1
                break
        # up the forest
        for k in countdown(i - 1, 0):
            if tree <= data[k][j]:
                hidden_score += 1
                break
        # right the forest
        for k in countup(j + 1, data.n - 1):
            if tree <= data[i][k]:
                hidden_score += 1
                break
        # left the forest
        for k in countdown(j - 1, 0):
            if tree <= data[i][k]:
                hidden_score += 1
                break

        # the tree is hidden, so decrement the totalamount of visible trees
        if hidden_score == 4:
            dec result


template updateScore(rs: int, scores: seq[int]) =
    if rs > 0:
        scores.add(rs)
        rs = 0


proc part2(data: DMatrix): int =
    for (coor, tree) in forest(data):
        # coor[0]: i, m, y
        # coor[1]: j, n, x
        let (i, j) = coor
        var running_score = 0
        var scores: seq[int]

        # down the forest
        for k in countup(i + 1, data.m - 1):
            inc running_score
            if tree <= data[k][j]:
                break
        updateScore(running_score, scores)

        # up the forest
        for k in countdown(i - 1, 0):
            inc running_score
            if tree <= data[k][j]:
                break
        updateScore(running_score, scores)

        # right the forest
        for k in countup(j + 1, data.n - 1):
            inc running_score
            if tree <= data[i][k]:
                break
        updateScore(running_score, scores)

        # left the forest
        for k in countdown(j - 1, 0):
            inc running_score
            if tree <= data[i][k]:
                break
        updateScore(running_score, scores)

        let scenic_score = scores.foldl(a * b)
        if scenic_score > result:
            result = scenic_score


when isMainModule:
    let dataSample: DMatrix = transformData(readFile("samples/sample8.txt").strip())
    let dataInput: DMatrix = transformData(readFile("inputs/input8.txt").strip())

    # a showcase of `$DMatrix`
    echo dataSample

    echo &"Part 1 sample: {part1(dataSample)} (21)"
    echo &"Part 1 input:  {part1(dataInput)}"
    echo &"Part 2 sample: {part2(dataSample)} (16)"
    echo &"Part 2 input:  {part2(dataInput)}"
