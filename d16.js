
const hexes = [
    // 'D2FE28', // 110 100 10111 11110 00101 000  (literal 2021)
    // '38006F45291200', // 001 110 0 000000000011011 [110 100 01010] [010 100 10001 00100] 0000000  (literal 10 and 20)
    // 'EE00D40C823060', // 111 011 1 00000000011 [010 100 00001] [100 100 00010] [001 100 00011] 00000  (literal 1, 2, 3)
    // '8A004A801A8002F478',
    // '620080001611562C8802118E34',
    // 'C0015000016115A2E0802F182340',
    // 'A0016C880162017C3686B18A3D4780'
    // 'C200B40A82',  // finds the sum of 1 and 2, resulting in the value 3.
    // '04005AC33890',  // finds the product of 6 and 9, resulting in the value 54.
    // '880086C3E88112',  // finds the minimum of 7, 8, and 9, resulting in the value 7.
    // 'CE00C43D881120',  // finds the maximum of 7, 8, and 9, resulting in the value 9.
    // 'D8005AC2A8F0',  // produces 1, because 5 is less than 15.
    // 'F600BC2D8F',  // produces 0, because 5 is not greater than 15.
    // '9C005AC2F8F0',  // produces 0, because 5 is not equal to 15.
    // '9C0141080250320F1802104A08'  // produces 1, because 1 + 3 = 2 * 2.
    
    // actual input...
    'E054831006016008CF01CED7CDB2D495A473336CF7B8C8318021C00FACFD3125B9FA624BD3DBB7968C0179DFDBD196FAE5400974A974B55C24DC580085925D5007E2D49C6579E49252E28600B580272379054AF57A54D65E1586A951D860400434E36080410926624D25458890A006CA251006573D2DFCBF4016919CC0A467302100565CF24B7A9C36B0402840002150CA3E46000042621C108F0200CC5C8551EA47F79FC28401C20042E0EC288D4600F42585F1F88010C8C709235180272B3DCAD95DC005F6671379988A1380372D8FF1127BDC0D834600BC9334EA5880333E7F3C6B2FBE1B98025600A8803F04E2E45700043E34C5F8A72DDC6B7E8E400C01797D02D002052637263CE016CE5E5C8CC9E4B369E7051304F3509627A907C97BCF66008500521395A62553A9CAD312A9CCCEAF63A500A2631CCD8065681D2479371E4A90E024AD69AAEBE20002A84ACA51EE0365B74A6BF4B2CC178153399F3BACC68CF3F50840095A33CBD7EF1393459E2C3004340109596AB6DEBF9A95CACB55B6F5FCD4A24580400A8586009C70C00D44401D8AB11A210002190DE1BC43872C006C45299463005EC0169AFFF6F9273269B89F4F80100507C00A84EB34B5F2772CB122D26016CA88C9BCC8BD4A05CA2CCABF90030534D3226B32D040147F802537B888CD59265C3CC01498A6B7BA7A1A08F005C401C86B10A358803D1FE24419300524F32AD2C6DA009080330DE2941B1006618450822A009C68998C1E0C017C0041A450A554A582D8034797FD73D4396C1848FC0A6F14503004340169D96BE1B11674A4804CD9DC26D006E20008747585D0AC001088550560F9019B0E004080160058798012804E4801232C0437B00F70A005100CFEE007A8010C02553007FC801A5100530C00F4B0027EE004CA64A480287C005E27EEE13DD83447D3009E754E29CDB5CD3C'
]

hexes.forEach((hex) => {
    console.log('=> Processing', hex)
    let source = []
    for (let i=0; i<hex.length; ++i) {
        source.push(parseInt(hex[i], 16).toString(2).padStart(4, '0'))
    }
    source = source.join('')

    const { versionSum, result } = processPackets(source)
    console.log(`Part 1: sum of versions: ${versionSum}`)
    console.log('result', result)
})

function log(msg, pad) {
    console.log((new Array(pad)).fill(' ', 0).join('') + msg)
}

function processPackets(bin, versionSum=0, values=[], pad=3, limit=999999) {
    const version = parseInt(bin.slice(0,3), 2)
    versionSum += version
    const type = parseInt(bin.slice(3,6), 2)
    log(`looking at packet v${version} (sum=${versionSum}), type=${type}, limit=${limit}: ${bin}`, pad)
    bin=bin.slice(6)
    
    let rest = ''
    let opResult = null
    if (type === 4) {
        const result = processLiteral(bin, '')
        rest = result.rest
        values.push(result.num)
        log(`found literal: ${result.num}`, pad)
    } else {
        const result = processOperator(bin, versionSum, [], pad, type)
        rest = result.rest
        opResult = result.result
        values.push(opResult)
        versionSum = result.versionSum
        pad += 3
    }

    if ((limit - 1) < 1) {
        // log(`end of opreator subpackets (count)`, pad)
        return { rest, versionSum, values, result: opResult }
    }
    if (/1/.test(rest)) {
        return processPackets(rest, versionSum, values, pad, limit - 1)
    } else {
        // log(`end of chain (sum=${versionSum})`, pad)
        return { rest, versionSum, values, result: opResult }
    }
}

function processLiteral(source, binary) {
    const end = source[0]
    binary += source.slice(1,5)
    const rest = source.slice(5)
    if (end === '1') {
        return processLiteral(rest, binary)
    } else {
        return { rest, num: parseInt(binary, 2) }
    }
}

function processOperator(source, versionSum, values, pad, type) {
    if (source[0] === '0') {
        const length = parseInt(source.slice(1, 16), 2)
        const result = processPackets(source.slice(16, 16+length), versionSum, values, pad+3)
        const opResult = completeOperation(type, result.values)
        // log(`end of opreator subpackets (length)`, pad)
        log(`performed op=${type} with result=${opResult} from values: ${result.values.join(', ')}`, pad)
        return {
            rest: source.slice(16+length),
            versionSum: result.versionSum,
            values: [],
            result: opResult
        }
    } else {
        const pCount = parseInt(source.slice(1, 12), 2)
        const result = processPackets(source.slice(12), versionSum, values, pad+3, pCount)
        const opResult = completeOperation(type, result.values)
        log(`performed op=${type} with result=${opResult} from values: ${result.values.join(', ')}`, pad)
        return { ...result, result: opResult, values: [] }
    }
}

function completeOperation(type, values) {
    if (type === 0) {
        return values.reduce((sum, val) => sum + val, 0)
    } else if (type === 1) {
        return values.reduce((prod, val) => prod * val, 1)
    } else if (type === 2) {
        return Math.min(...values)
    } else if (type === 3) {
        return Math.max(...values)
    } else if (type === 5) {
        return (values[0] > values[1]) ? 1 : 0
    } else if (type === 6) {
        return (values[0] < values[1]) ? 1 : 0
    } else if (type === 7) {
        return (values[0] == values[1]) ? 1 : 0
    }
}
