import Lmdb from '@rmw/lmdb'

export default (dirpath)=>
  db = Lmdb(dirpath)
  ip_delay = db.ip_delay({
    compression:false
    keyIsBuffer:true
  })
  delay_ip = db.delay_ip {
    compression:false
    encoding:'binary'
    keyIsUint32:true
  }
  [db, ip_delay, delay_ip]
