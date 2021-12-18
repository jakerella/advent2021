

// const target = { x: { min: 20, max: 30 }, y: { min: -10, max: -5 } }
// real...
const target = { x: { min: 150, max: 171 }, y: { min: -129, max: -70 } }


// ------------------------------------ Part 1

// sum = 1/2 * x * (x + 1)
let maxVx = Math.floor((Math.sqrt(((target.x.max * 2) * 4) + 1) - 1) / 2)
let maxVy = Math.abs(target.y.min) - 1

let maxY = 0
for (let vx=1; vx < (maxVx+1); ++vx) {
    for (let vy=1; vy < (maxVy+1); ++vy) {
        // console.log(`Trying v: ${vx}, ${vy}`)
        const archMaxY = tryInitialVelocity({ x: vx, y: vy })
        if (archMaxY !== null) {
            if (archMaxY > maxY) { maxY = archMaxY }
        }
    }
}
console.log('Part 1, biggest max y =', maxY)


// ------------------------------------ Part 2

maxVy = Math.abs(target.y.min) - 1
let countPaths = 0
for (let vx=1; vx < (target.x.max+1); ++vx) {
    for (let vy=target.y.min; vy < (maxVy+1); ++vy) {
        // console.log(`Trying v: ${vx}, ${vy}`)
        const archMaxY = tryInitialVelocity({ x: vx, y: vy })
        if (archMaxY !== null) { countPaths++ }
    }
}
console.log('Part 2, number of paths =', countPaths)
// 2207 too low


// tryInitialVelocity({ x:6, y:0 })


// ------------------------------------ Helpers

function tryInitialVelocity(v) {
    const pos = { x:0, y:0 }
    const initialV = { ...v }

    let maxY = 0
    let inTarget = false
    while (pos.x <= target.x.max && pos.y >= target.y.min) {
        const result = step(v, pos)
        pos.x = result.pos.x
        pos.y = result.pos.y
        v.x = result.v.x
        v.y = result.v.y

        if (pos.y > maxY) { maxY = pos.y }
        if (pos.x >= target.x.min && pos.x <= target.x.max && pos.y >= target.y.min && pos.y <= target.y.max) {
            inTarget = true
            console.log('Probe in target at', pos, 'with max y=', maxY, 'using initial v=', initialV)
            break
        }
    }
    return (inTarget) ? maxY : null
}

function step(v, pos) {
    const newPos = { ...pos }
    newPos.x += v.x
    newPos.y += v.y
    const newV = { ...v }
    if (newV.x < 0) { newV.x++ } else if (newV.x > 0) { newV.x-- }
    newV.y--
    // console.log(`new pos: ${newPos.x}, ${newPos.y}; new v: ${newV.x}, ${newV.y}`)
    return { v: newV, pos: newPos }
}
