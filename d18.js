const util = require('util')
const readFile = util.promisify(require('fs').readFile)

const file = 'd18_test.txt'

;(async () => {
    // const lines = (await readFile(file)).toString().split(/\n/)

    const lines = [
        '[[[[6,7],[6,7]],[[7,7],[0,7]]],[[[8,7],[7,7]],[[8,8],[8,0]]]]',
        '[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]'
    ]

    let curr = lines[0]
    for(let i=1; i<lines.length; ++i) {
        console.log(`=> ADD lines: [${curr},${lines[i]}]`)
        curr = reduce(`[${curr},${lines[i]}]`)
    }
    console.log(`Final reduced result: ${curr}`)
})();


// [
//     { start: '[1,1]', end: '[1,1]' },
//     { start: '[[[[[9,8],1],2],3],4]', end: '[[[[0,9],2],3],4]' },
//     { start: '[[0,13],[1,1]]', end: '[[0,[6,7]],[1,1]]' },
//     { start: '[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]', end: '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]' }
// ].forEach((test) => {
//     const result = reduce(test.start)
//     if (result === test.end) {
//         console.log('passed reduce test for', test.start)
//     } else {
//         console.log('FAILED reduce on input', test.start, 'got', result, 'but expected', test.end)
//     }
// })

function reduce(num) {
    let latest = num
    while (true) {
        let result = explode(latest)
        if (result === latest) {
            result = split(latest)
            if (result === latest) {
                return latest
            } else {
                // console.log('split')
                latest = result
            }
        } else {
            // console.log('explode')
            latest = result
        }
    }
}


// [
//     { start: '[1,1]', end: '[1,1]' },
//     { start: '[[[1,1],2],3]', end: '[[[1,1],2],3]' },
//     { start: '[[[[[9,8],1],2],3],4]', end: '[[[[0,9],2],3],4]' },
//     { start: '[7,[6,[5,[4,[3,2]]]]]', end: '[7,[6,[5,[7,0]]]]' },
//     { start: '[[6,[5,[4,[3,2]]]],1]', end: '[[6,[5,[7,0]]],3]' },
//     { start: '[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]', end: '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]' },
//     { start: '[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]', end: '[[3,[2,[8,0]]],[9,[5,[7,0]]]]' },
//     { start: '[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]', end: '[[[[0,7],4],[7,[[8,4],9]]],[1,1]]' },
//     { start: '[[[[0,7],4],[7,[[8,4],9]]],[1,1]]', end: '[[[[0,7],4],[15,[0,13]]],[1,1]]' },
//     { start: '[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]', end: '[[[[0,7],4],[[7,8],[6,0]]],[8,1]]' },
//     { start: '[[[[[9,8],1],2],3],[9,8]]', end: '[[[[0,9],2],3],[9,8]]' },
//     { start: '[[3,2],[6,[5,[4,[3,2]]]]]', end: '[[3,2],[6,[5,[7,0]]]]' }
// ].forEach((test) => {
//     const result = explode(test.start)
//     if (result === test.end) {
//         console.log('passed explode test for', test.start)
//     } else {
//         console.log('FAILED explode on input', test.start, 'got', result, 'but expected', test.end)
//     }
// })

function explode(num) {
    const pairs = num.match(/\[\d+,\d+\]/g)
    let startIndex = 0
    for (let i=0; i<pairs.length; ++i) {
        let matchIndex = num.indexOf(pairs[i], startIndex)
        let leftString = num.slice(0, matchIndex)
        let openers = leftString.match(/[\[]/g)
        openers = (openers) ? openers.length : 0
        let closers = leftString.match(/[\]]/g)
        closers = (closers) ? closers.length : 0
        // console.log('found regular pair:', pairs[i], 'at index', matchIndex, `with openers=${openers} and closers=${closers} (depth=${openers - closers})`)
        
        if (openers - closers >= 4) {
            let left = leftString.match(/\d+/g)
            if (left) { left = left.pop() }
            let rightString = num.slice(matchIndex + pairs[i].length)
            let right = rightString.match(/\d+/)
            if (right) { right = right[0] }
            console.log(`found pair at index ${matchIndex}: ${pairs[i]}, left=${left}, right=${right} ... ${num}`)

            const [ pairLeft, pairRight ] = eval(pairs[i])
            if (left) {
                left = Number(left) + pairLeft
                // console.log('for left, using', /\d+([^\d]+)$/, 'on', leftString, 'replacing with', left)
                leftString = leftString.replace(/\d+([^\d]+)$/, left + '$1')
            }
            if (right) {
                right = Number(right) + pairRight
                // console.log('for right, using', /^([^\d]+)\d+/, 'on', rightString, 'replacing with', right)
                rightString = rightString.replace(/^([^\d]+)\d+/, '$1' + right)
            }
            console.log(`exploded to: ${leftString}0${rightString}`)
            return leftString + '0' + rightString

        } else {
            startIndex += pairs[i].length
        }
    }
    return num
}


// [
//     { start: '[1,1]', end: '[1,1]' },
//     { start: '[[[[0,7],4],[8,[0,9]]],[1,1]]', end: '[[[[0,7],4],[8,[0,9]]],[1,1]]' },
//     { start: '[[[[0,7],4],[15,[0,13]]],[1,1]]', end: '[[[[0,7],4],[[7,8],[0,13]]],[1,1]]' },
//     { start: '[[[[0,7],4],[[7,8],[0,13]]],[1,1]]', end: '[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]' }
// ].forEach((test) => {
//     const result = split(test.start)
//     if (result === test.end) {
//         console.log('passed split test for', test.start)
//     } else {
//         console.log('FAILED split on input', test.start, 'got', result, 'but expected', test.end)
//     }
// })

function split(num) {
    const bigNumMatch = /\d{2}/.exec(num)
    if (bigNumMatch) {
        const bigNum = Number(bigNumMatch[0])
        let leftString = num.slice(0, bigNumMatch.index)
        let rightString = num.slice(bigNumMatch.index + bigNumMatch[0].length)
        console.log(`split ${bigNum} at ${bigNumMatch.index} to [${Math.floor(bigNum / 2)},${Math.ceil(bigNum / 2)}]`)
        return leftString + `[${Math.floor(bigNum / 2)},${Math.ceil(bigNum / 2)}]` + rightString
    }

    return num
}
