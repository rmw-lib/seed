#!/usr/bin/env coffee
import {DIR} from './src/const.mjs'
import fs from 'fs'
import {promisify} from 'util'
import {join,dirname,resolve} from 'path'
import Lmdb from './src/lmdb'
import {bin_ip_port, ip_port_str} from '@rmw/ip-port-bin'
import {thisdir,thisfile} from '@rmw/thisfile'

PWD = resolve thisdir(`import.meta`), '../net-'

dump = (dirpath, name)=>
  [trx,ip_delay,delay_ip] = Lmdb(join dirpath, name)

  outpath = PWD+name+"/seed.csv"
  seed = fs.createWriteStream outpath

  for await {value} from delay_ip(limit:512)
    seed.write ip_port_str(...bin_ip_port(value))+"\n"

  console.log delay_ip.length, outpath

  new Promise(
    (resolve)=>
      seed.end(resolve)
  )

do =>
  console.log DIR
  if not fs.existsSync DIR
    return
  readdir = promisify fs.readdir
  for i in await readdir(DIR)
    await dump DIR,i
  process.exit()
