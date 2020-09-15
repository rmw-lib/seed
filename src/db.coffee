import Lmdb from './lmdb'
import {join} from 'path'
import {ip_port_str, ip_port_bin, bin_ip_port} from '@rmw/ip-port-bin'
import sleep from 'await-sleep'
import {DIR} from './const.mjs'
import console from './console'

MAX_ID = 0xFFFF_FFFF
MAX_LENGTH = 0xFFFF
MAX_LENGTH_2 = MAX_LENGTH*2
COST_DEFAULT = 100*1000*1000

export default class Db

  constructor:(name)->
    [@trx,@ip_delay,@delay_ip] = Lmdb(join DIR,name)

  clear: =>
    {trx, ip_delay, delay_ip} = @
    len = delay_ip.length
    if len > MAX_LENGTH_2
      await trx =>
        n = 0
        for {key,value} in delay_ip(reverse:true)
          ip_delay.removeSync value
          delay_ip.removeSync key
          if ++n > MAX_LENGTH
            break

  put : (cost, ip, port)=>
    if not /^[\d\.\[\:\]]+$/.test(ip)
      return
    {trx, ip_delay, delay_ip} = @
    ip_port = ip_port_bin ip, port
    id = (ip_delay.get ip_port)
    if cost < 0
      if id
        return
      cost = COST_DEFAULT + parseInt(COST_DEFAULT*Math.random())
    trx =>
      if id
        cost = parseInt((cost + id)/2)
        delay_ip.removeSync id

      while ++cost
        if cost > MAX_ID
          if id
            ip_delay.removeSync ip_port
          return
        if not delay_ip.get(cost)
          break

      if cost % 1000 == 500
        @clear()

      # console.log ip, id/1000, "=>", cost/1000
      ip_delay.putSync ip_port, cost
      delay_ip.putSync cost, ip_port
      return

  rm : (ip, port)->
    {trx, ip_delay, delay_ip} = @
    trx =>
      ip_port = ip_port_bin ip, port
      id = ip_delay.get ip_port
      if id
        delay_ip.removeSync id
      ip_delay.removeSync ip_port

  @::[Symbol.asyncIterator] = ->
    for {key, value} from @delay_ip start:1
      yield bin_ip_port value
    for await i from @boot()
      yield i
    return

  refresh: ->
    {trx, seed, ip_delay, delay_ip} = @
    n = 0
    for await [ip,port] from @
      begin = new Date()
      try
        s = await seed(ip, port)
      catch err
        console.error err
        s = undefined
      if s
        cost = (new Date() - begin) * 1000 + parseInt(Math.random() * 1000)
        console.log n, cost/1000, ip_port_str(ip, port)
        await @put cost, ip, port
        await @put -1, ...s
      else
        await @put MAX_ID, ip, port
        continue
      await sleep(1000)
      if ++n > MAX_LENGTH
        break
