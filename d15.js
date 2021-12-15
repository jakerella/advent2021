const util = require('util')
const readFile = util.promisify(require('fs').readFile)

const file = 'd15.txt'

;(async () => {
    const map = (await readFile(file)).toString().split(/\n/)
    
    const grid = {}
    for (let y=0; y<map.length; ++y) {
        grid[y] = []
        for (let x=0; x<map[0].length; ++x) {
            grid[y][x] = {c:{y, x}, f:0, g:0, h:0, p:null}
        }  
    }

    const risks = calculateRisks(grid, map)
    const end = { y: map.length-1, x: map[0].length-1 }
    console.log(`Part 1, smallest risk (at ${key(end)}): ${risks[key(end)]}`)


    const newMap = []
    const newGrid = {}
    for (let y=0; y<(map.length * 5); ++y) {
        newGrid[y] = []
        newMap[y] = []
        for (let x=0; x<(map[0].length * 5); ++x) {
            newGrid[y][x] = {c:{y, x}, f:0, g:0, h:0, p:null}
            if (y < 10 && x < 10) {
                newMap[y].push(map[y][x])
            } else {
                let newVal = Number(map[y % 10][x % 10]) + Math.floor(x / 10) + Math.floor(y / 10)
                // console.log(`newVal ${newVal} from [${y % 10}][${x % 10}]=${Number(map[y % 10][x % 10])} and adding ${Math.floor(x / 10)} and ${Math.floor(y / 10)}`)
                if (newVal > 9) {
                    newVal = (newVal % 10) + 1
                    if (newVal > 9) { newVal = 1 }
                }
                newMap[y].push(newVal)
            }
        }
        newMap[y] = newMap[y].join('')
    }

    const newRisks = calculateRisks(newGrid, newMap)
    const newEnd = { y: newMap.length-1, x: newMap[0].length-1 }
    console.log(`Part 2, smallest risk (at ${key(newEnd)}): ${newRisks[key(newEnd)]}`)
    // 2220 TOO LOW
    // 2532 TOO LOW
})()

function key(c) { return `${c.y},${c.x}` }

function calculateRisks(grid, map) {
    const openList = {'0,0': {c:{y:0, x:0}, f:0, g:0, h:0, p:null}}
    const closedList = {}
    const risks = {}

    while (Object.keys(openList).length) {
        // console.log('open:', Object.keys(openList))
        // console.log('closed:', Object.keys(closedList))
        
        let curr = {f:999999999999}
        for (let n in openList) {
            if (openList[n].f < curr.f) {
                curr = openList[n]
            }
        }
        // console.log('processing node:', curr)

        if (!curr.c) {
            console.log('could not find suitable node in openList')
            process.exit(1)
        }

        closedList[key(curr.c)] = curr
        delete openList[key(curr.c)]

        const next = []
        if (grid[curr.c.y - 1] && !closedList[key({y:curr.c.y-1, x:curr.c.x})]) { next.push(grid[curr.c.y - 1][curr.c.x]) }
        if (grid[curr.c.y][curr.c.x - 1] && !closedList[key({y:curr.c.y, x:curr.c.x-1})]) { next.push(grid[curr.c.y][curr.c.x - 1]) }
        if (grid[curr.c.y + 1] && !closedList[key({y:curr.c.y+1, x:curr.c.x})]) { next.push(grid[curr.c.y + 1][curr.c.x]) }
        if (grid[curr.c.y][curr.c.x + 1] && !closedList[key({y:curr.c.y, x:curr.c.x+1})]) { next.push(grid[curr.c.y][curr.c.x + 1]) }

        for(i=0; i<next.length; ++i) {
            const g = curr.g + Number(map[next[i].c.y][next[i].c.x])

            let betterG = false

            if (!openList[key(next[i].c)]) {
                betterG = true
                openList[key(next[i].c)] = next[i]

            } else if (g < next[i].g) {
                betterG = true
            }
            
            if (betterG) {
                risks[key(next[i].c)] = g
                next[i].p = key(curr.c)
                next[i].g = g
                next[i].f = next[i].g
            }
        }
    }

    return risks
}
