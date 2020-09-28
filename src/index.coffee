#!/usr/bin/env coffee

import console from './console'
# import Lock from '@rmw/lock'
import Db from './db'

export default seed = new Proxy(
  {}
  get: (self, name)=>
    db = new Db(name)

    ({boot, seed})=>
      db.seed = seed
      db.boot = boot

      refresh = =>
        await db.refresh()
        setTimeout(refresh, 86400)

      setTimeout(
        refresh
        1000
      )

      db
      # (n, callback)->
      #   lock = Lock(
      #     n
      #   )
      #   exist = new Set()
      #   for await [ip,port] from db.iter()
      #     if exist.has ip
      #       continue
      #     # console.log "try connect ", ip, port
      #     exist.add ip
      #     if n < 0
      #       break
      #     await lock =>
      #       begin = new Date()
      #       try
      #         c = await conn(ip, port)
      #       catch err
      #         console.error ip, err
      #         # await db.rm ip, port
      #         return
      #       if c.isReady
      #         callback c
      #         --n
)


